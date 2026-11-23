-- EasyFleet Phase 2 migration 3: transporter subscription monetization.
-- Agreed pricing: INR 1500 / 30 days. No transaction fees.
-- Additive: existing companies receive a 30-day trial so current trip
-- creation functionality is preserved.

begin;

-- ---------------------------------------------------------------------------
-- 1. Plans, subscriptions, payment transactions.
-- ---------------------------------------------------------------------------
create table if not exists public.subscription_plans (
  id text primary key,
  name text not null,
  price_inr numeric(14, 2) not null check (price_inr >= 0),
  duration_days integer not null check (duration_days > 0),
  currency text not null default 'INR',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.subscription_plans enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='subscription_plans' and policyname='subscription_plans_select') then
    create policy subscription_plans_select on public.subscription_plans
      for select to authenticated using (is_active);
  end if;
end $$;
grant select on public.subscription_plans to authenticated;

insert into public.subscription_plans (id, name, price_inr, duration_days)
values ('TRANSPORTER_MONTHLY', 'EasyFleet Transporter Monthly', 1500.00, 30)
on conflict (id) do nothing;

create table if not exists public.company_subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null unique references public.companies (id),
  plan_id text not null references public.subscription_plans (id),
  status text not null default 'TRIAL'
    check (status in ('TRIAL', 'ACTIVE', 'EXPIRED', 'CANCELLED')),
  started_at timestamptz not null default now(),
  valid_until timestamptz not null,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.company_subscriptions enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='company_subscriptions' and policyname='company_subscriptions_select') then
    create policy company_subscriptions_select on public.company_subscriptions
      for select to authenticated using (public.is_company_member(company_id));
  end if;
end $$;
grant select on public.company_subscriptions to authenticated;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'company_subscriptions_updated_at') then
    create trigger company_subscriptions_updated_at
      before update on public.company_subscriptions
      for each row execute function public.easyfleet_set_updated_at();
  end if;
end $$;

create table if not exists public.payment_transactions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  subscription_id uuid references public.company_subscriptions (id),
  purpose text not null check (purpose in ('SUBSCRIPTION', 'RENEWAL')),
  amount_inr numeric(14, 2) not null check (amount_inr >= 0),
  currency text not null default 'INR',
  method text not null check (method in ('MANUAL', 'UPI', 'RAZORPAY', 'OTHER')),
  provider_reference text,
  status text not null default 'CAPTURED'
    check (status in ('PENDING', 'CAPTURED', 'FAILED', 'REFUNDED')),
  notes text,
  recorded_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  idempotency_key uuid unique
);
create index if not exists payment_transactions_company_idx
  on public.payment_transactions (company_id, created_at desc);
alter table public.payment_transactions enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='payment_transactions' and policyname='payment_transactions_select') then
    create policy payment_transactions_select on public.payment_transactions
      for select to authenticated using (public.is_company_member(company_id));
  end if;
end $$;
grant select on public.payment_transactions to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Trial seeding: every new company gets 30 days so existing registration
--    and trip workflows keep working. Backfill existing companies likewise.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_seed_company_trial()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.company_subscriptions (company_id, plan_id, status, started_at, valid_until)
  values (new.id, 'TRANSPORTER_MONTHLY', 'TRIAL', now(), now() + interval '30 days')
  on conflict (company_id) do nothing;
  return new;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'companies_seed_trial') then
    create trigger companies_seed_trial
      after insert on public.companies
      for each row execute function public.easyfleet_seed_company_trial();
  end if;
end $$;

insert into public.company_subscriptions (company_id, plan_id, status, started_at, valid_until)
select c.id, 'TRANSPORTER_MONTHLY', 'TRIAL', now(), now() + interval '30 days'
from public.companies c
on conflict (company_id) do nothing;

create or replace function public.has_active_subscription(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.company_subscriptions cs
    where cs.company_id = p_company_id
      and cs.status in ('TRIAL', 'ACTIVE')
      and cs.valid_until > now()
  );
$$;
revoke all on function public.has_active_subscription(uuid) from public;
grant execute on function public.has_active_subscription(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Payment / renewal RPC. Server-side plan price is authoritative.
--    Payment capture is recorded against a provider reference; gateway
--    webhook verification is an extension point (see docs).
-- ---------------------------------------------------------------------------
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

  v_purpose := case when v_sub.id is null or v_sub.status = 'TRIAL' then 'SUBSCRIPTION' else 'RENEWAL' end;
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

-- ---------------------------------------------------------------------------
-- 4. Subscription access enforcement on trip creation. The existing RPC body
--    is preserved exactly; only a guard is added after the operator check.
--    Existing companies hold trials, so current functionality is unchanged.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.easyfleet_create_trip(p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid DEFAULT NULL::uuid, p_company_driver_id uuid DEFAULT NULL::uuid, p_driver_account_id uuid DEFAULT NULL::uuid, p_gc_number text DEFAULT NULL::text, p_material text DEFAULT NULL::text, p_tonnes numeric DEFAULT NULL::numeric, p_freight_rate numeric DEFAULT NULL::numeric, p_bata_advance numeric DEFAULT 0, p_planned_distance_km numeric DEFAULT NULL::numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_existing uuid;
    v_existing_trip public.fleet_trips%ROWTYPE;
    v_status text := 'PLANNED';
    v_request jsonb;
BEGIN
    IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
    IF NOT public.is_company_operator(p_company_id) THEN
        RAISE EXCEPTION 'Company operator permission required';
    END IF;
    IF NOT public.has_active_subscription(p_company_id) THEN
        RAISE EXCEPTION 'SUBSCRIPTION_REQUIRED: an active EasyFleet subscription is required to create trips';
    END IF;
    IF p_company_id IS NULL OR p_trip_id IS NULL OR p_idempotency_key IS NULL
       OR p_origin IS NULL OR length(trim(p_origin)) = 0
       OR p_destination IS NULL OR length(trim(p_destination)) = 0
       OR p_scheduled_date IS NULL THEN
        RAISE EXCEPTION 'Trip ID, idempotency key, route and date required';
    END IF;
    IF (p_company_driver_id IS NULL) <> (p_driver_account_id IS NULL) THEN
        RAISE EXCEPTION 'Company driver and driver account must be supplied together';
    END IF;
    IF COALESCE(p_bata_advance, 0) < 0
       OR (p_tonnes IS NOT NULL AND p_tonnes <= 0)
       OR (p_freight_rate IS NOT NULL AND p_freight_rate < 0)
       OR (p_planned_distance_km IS NOT NULL AND p_planned_distance_km < 0) THEN
        RAISE EXCEPTION 'Invalid trip quantity, rate, advance or distance';
    END IF;

    v_request := jsonb_build_object(
        'trip_id', p_trip_id, 'origin', trim(p_origin), 'destination', trim(p_destination),
        'scheduled_date', p_scheduled_date, 'vehicle_id', p_vehicle_id,
        'company_driver_id', p_company_driver_id, 'driver_account_id', p_driver_account_id,
        'gc_number', nullif(trim(p_gc_number), ''), 'material', nullif(trim(p_material), ''),
        'tonnes', p_tonnes, 'freight_rate', p_freight_rate,
        'bata_advance', COALESCE(p_bata_advance, 0),
        'planned_distance_km', p_planned_distance_km
    );

    PERFORM pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
    IF public.easyfleet_request_replay(
        p_company_id, p_idempotency_key, 'TRIP', p_trip_id, 'TRIP_CREATED', v_request
    ) THEN
        SELECT id INTO v_existing FROM public.fleet_trips
        WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key;
        IF v_existing IS NULL THEN RAISE EXCEPTION 'Idempotency record exists without its trip'; END IF;
        RETURN v_existing;
    END IF;

    SELECT * INTO v_existing_trip FROM public.fleet_trips
    WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key
    FOR UPDATE;
    IF FOUND THEN
        RAISE EXCEPTION 'Trip exists without a matching v2 audit fingerprint; manual reconciliation required'
            USING ERRCODE = '23505';
    END IF;

    IF p_vehicle_id IS NOT NULL THEN
        PERFORM 1 FROM public.fleet_vehicles
        WHERE id = p_vehicle_id AND company_id = p_company_id AND status = 'AVAILABLE'
        FOR UPDATE;
        IF NOT FOUND THEN RAISE EXCEPTION 'Vehicle unavailable or not in this company'; END IF;
    END IF;

    IF p_driver_account_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.company_drivers cd
            WHERE cd.id = p_company_driver_id AND cd.company_id = p_company_id
              AND cd.driver_account_id = p_driver_account_id
        ) THEN RAISE EXCEPTION 'Driver mapping does not belong to this company'; END IF;
        IF NOT EXISTS (
            SELECT 1
            FROM public.driver_memberships dm
            JOIN public.companies c ON c.id = dm.company_id
            WHERE dm.company_id = p_company_id
              AND dm.driver_account_id = p_driver_account_id
              AND dm.status = 'APPROVED'
              AND c.status = 'ACTIVE'
        ) THEN
            RAISE EXCEPTION 'Driver must have approved membership in an active company';
        END IF;
    END IF;

    IF p_vehicle_id IS NOT NULL OR p_driver_account_id IS NOT NULL THEN v_status := 'ASSIGNED'; END IF;
    INSERT INTO public.fleet_trips(
        id, company_id, gc_number, origin, destination, scheduled_date, vehicle_id,
        company_driver_id, driver_account_id, material, tonnes, freight_rate, bata_advance,
        planned_distance_km, status, assigned_at, created_by, idempotency_key
    ) VALUES (
        p_trip_id, p_company_id, nullif(trim(p_gc_number), ''), trim(p_origin), trim(p_destination),
        p_scheduled_date, p_vehicle_id, p_company_driver_id, p_driver_account_id,
        nullif(trim(p_material), ''), p_tonnes, p_freight_rate, COALESCE(p_bata_advance, 0),
        p_planned_distance_km, v_status, CASE WHEN v_status = 'ASSIGNED' THEN now() END,
        (SELECT auth.uid()), p_idempotency_key
    );

    IF p_vehicle_id IS NOT NULL THEN
        UPDATE public.fleet_vehicles SET status = 'ASSIGNED'
        WHERE id = p_vehicle_id AND company_id = p_company_id;
    END IF;

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'TRIP', p_trip_id, 'TRIP_CREATED', p_idempotency_key,
        jsonb_build_object('request', v_request, 'status', v_status)
    );
    RETURN p_trip_id;
END;
$function$;

-- ---------------------------------------------------------------------------
-- 5. Realtime for subscription status.
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.company_subscriptions;
  exception when duplicate_object then null;
  end;
end $$;

commit;
