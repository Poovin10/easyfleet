-- EasyFleet Phase 2 migration 7: office and driver read paths discovered by
-- the backend test suite, plus first-payment purpose correction.
-- Additive policies only; no existing policy is removed or weakened.

begin;

-- Office staff must be able to review company and driver records.
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='companies' and policyname='companies_staff_read') then
    create policy companies_staff_read on public.companies
      for select to authenticated using (public.is_platform_staff());
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='driver_accounts' and policyname='driver_accounts_staff_read') then
    create policy driver_accounts_staff_read on public.driver_accounts
      for select to authenticated using (public.is_platform_staff());
  end if;
  -- Drivers see companies they hold an approved membership in.
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='companies' and policyname='companies_driver_read') then
    create policy companies_driver_read on public.companies
      for select to authenticated using (
        exists (
          select 1 from public.driver_memberships dm
          where dm.company_id = companies.id
            and dm.status = 'APPROVED'
            and public.is_driver_account_owner(dm.driver_account_id)
        )
      );
  end if;
  -- Drivers see vehicles assigned to their trips.
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='fleet_vehicles' and policyname='fleet_vehicles_driver_read') then
    create policy fleet_vehicles_driver_read on public.fleet_vehicles
      for select to authenticated using (
        exists (
          select 1 from public.fleet_trips ft
          where ft.vehicle_id = fleet_vehicles.id
            and ft.driver_account_id is not null
            and public.is_driver_account_owner(ft.driver_account_id)
        )
      );
  end if;
  -- Drivers see maintenance jobs for vehicles they have driven.
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='fleet_maintenance_jobs' and policyname='fleet_maintenance_jobs_driver_read') then
    create policy fleet_maintenance_jobs_driver_read on public.fleet_maintenance_jobs
      for select to authenticated using (
        exists (
          select 1 from public.fleet_trips ft
          where ft.vehicle_id = fleet_maintenance_jobs.vehicle_id
            and ft.driver_account_id is not null
            and public.is_driver_account_owner(ft.driver_account_id)
        )
      );
  end if;
end $$;

-- First paid purchase is SUBSCRIPTION even if the trial already expired;
-- subsequent purchases are RENEWAL. Body otherwise unchanged.
create or replace function public.easyfleet_pay_subscription(
  p_company_id uuid,
  p_plan_id text,
  p_method text,
  p_idempotency_key uuid,
  p_provider_reference text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan public.subscription_plans%rowtype;
  v_sub public.company_subscriptions%rowtype;
  v_existing public.payment_transactions%rowtype;
  v_payment_id uuid;
  v_purpose text;
  v_base timestamptz;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if p_idempotency_key is null then raise exception 'Idempotency key required'; end if;
  if p_method not in ('MANUAL', 'UPI', 'RAZORPAY', 'OTHER') then
    raise exception 'Invalid payment method';
  end if;
  if p_method in ('UPI', 'RAZORPAY') and nullif(trim(p_provider_reference), '') is null then
    raise exception 'A payment provider reference is required for % payments', p_method;
  end if;

  select * into v_plan from public.subscription_plans where id = p_plan_id and is_active;
  if not found then raise exception 'Unknown subscription plan'; end if;

  perform pg_advisory_xact_lock(hashtextextended('subscription:' || p_company_id::text, 0));

  select * into v_existing from public.payment_transactions
  where idempotency_key = p_idempotency_key for update;
  if found then
    if v_existing.company_id <> p_company_id or v_existing.amount_inr <> v_plan.price_inr then
      raise exception 'Idempotency key conflict' using errcode = '23505';
    end if;
    return v_existing.subscription_id;
  end if;

  select * into v_sub from public.company_subscriptions
  where company_id = p_company_id for update;

  v_purpose := case
    when exists (
      select 1 from public.payment_transactions
      where company_id = p_company_id and status = 'CAPTURED'
    ) then 'RENEWAL'
    else 'SUBSCRIPTION'
  end;
  v_base := greatest(now(), coalesce(v_sub.valid_until, now()));

  if v_sub.id is null then
    insert into public.company_subscriptions (company_id, plan_id, status, started_at, valid_until)
    values (p_company_id, p_plan_id, 'ACTIVE', now(), v_base + make_interval(days => v_plan.duration_days))
    returning * into v_sub;
  else
    update public.company_subscriptions
    set plan_id = p_plan_id,
        status = 'ACTIVE',
        cancelled_at = null,
        valid_until = v_base + make_interval(days => v_plan.duration_days),
        updated_at = now()
    where id = v_sub.id
    returning * into v_sub;
  end if;

  insert into public.payment_transactions (
    company_id, subscription_id, purpose, amount_inr, currency, method,
    provider_reference, status, notes, recorded_by, idempotency_key
  ) values (
    p_company_id, v_sub.id, v_purpose, v_plan.price_inr, v_plan.currency, p_method,
    nullif(trim(p_provider_reference), ''), 'CAPTURED', nullif(trim(p_notes), ''),
    auth.uid(), p_idempotency_key
  )
  returning id into v_payment_id;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'SUBSCRIPTION', v_sub.id, 'SUBSCRIPTION_PAID',
    p_idempotency_key,
    jsonb_build_object('plan_id', p_plan_id, 'amount_inr', v_plan.price_inr,
                       'method', p_method, 'purpose', v_purpose, 'valid_until', v_sub.valid_until)
  );
  return v_sub.id;
end;
$$;
revoke all on function public.easyfleet_pay_subscription(uuid, text, text, uuid, text, text) from public;
grant execute on function public.easyfleet_pay_subscription(uuid, text, text, uuid, text, text) to authenticated;

commit;
