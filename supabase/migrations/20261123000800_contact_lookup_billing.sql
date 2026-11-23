-- EasyFleet Phase 2 migration 8: driver contact lookup billing.
-- Business rule: a transporter pays Rs 100 (INR) per driver contact unlock.
-- The price is server-authoritative; the mobile client never sends an amount.
-- One idempotency key bills at most once and returns the previously unlocked
-- contact on replay. Only office-verified drivers can be unlocked, and the
-- caller must belong to an actively subscribed company.

begin;

-- ---------------------------------------------------------------------------
-- 1. Billing ledger for contact unlocks.
-- ---------------------------------------------------------------------------
create table if not exists public.driver_contact_lookups (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  driver_account_id uuid not null references public.driver_accounts (id),
  looked_up_by uuid references auth.users (id),
  amount_inr numeric(10, 2) not null default 100.00
    check (amount_inr = 100.00),
  payment_transaction_id uuid references public.payment_transactions (id),
  idempotency_key uuid not null unique,
  created_at timestamptz not null default now()
);
create index if not exists driver_contact_lookups_company_idx
  on public.driver_contact_lookups (company_id, created_at desc);
create index if not exists driver_contact_lookups_driver_idx
  on public.driver_contact_lookups (driver_account_id);
alter table public.driver_contact_lookups enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public'
      and tablename = 'driver_contact_lookups' and policyname = 'driver_contact_lookups_select'
  ) then
    create policy driver_contact_lookups_select on public.driver_contact_lookups
      for select to authenticated using (public.is_company_member(company_id));
  end if;
end $$;

grant select on public.driver_contact_lookups to authenticated;

-- Extend the payment purpose enum without dropping or rewriting any rows.
alter table public.payment_transactions
  drop constraint if exists payment_transactions_purpose_check;
alter table public.payment_transactions
  add constraint payment_transactions_purpose_check
  check (purpose in ('SUBSCRIPTION', 'RENEWAL', 'CONTACT_LOOKUP'));

-- ---------------------------------------------------------------------------
-- 2. Server-authoritative unlock RPC.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_lookup_driver_contact(
  p_driver_account_id uuid,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_company_id uuid;
  v_existing public.driver_contact_lookups%rowtype;
  v_lookup_id uuid;
  v_payment_id uuid;
  v_phone text;
  v_name text;
begin
  if p_driver_account_id is null or p_idempotency_key is null then
    raise exception 'DRIVER_AND_IDEMPOTENCY_KEY_REQUIRED';
  end if;

  select cm.company_id into v_company_id
  from public.company_memberships cm
  where cm.user_id = (select auth.uid())
    and cm.status = 'ACTIVE'
    and cm.role in ('OWNER', 'ADMIN', 'COMPLIANCE', 'DISPATCHER')
  order by case cm.role when 'OWNER' then 0 when 'ADMIN' then 1 else 2 end
  limit 1;

  if v_company_id is null then
    raise exception 'NO_ACTIVE_COMPANY_MEMBERSHIP';
  end if;

  if not public.has_active_subscription(v_company_id) then
    raise exception 'SUBSCRIPTION_REQUIRED';
  end if;

  -- Replaying a key never double-bills and returns the same contact.
  select * into v_existing
  from public.driver_contact_lookups
  where idempotency_key = p_idempotency_key;

  if found then
    if v_existing.company_id <> v_company_id then
      raise exception 'IDEMPOTENCY_KEY_BELONGS_TO_OTHER_COMPANY';
    end if;
    select da.display_name, da.phone_e164 into v_name, v_phone
    from public.driver_accounts da where da.id = v_existing.driver_account_id;
    return jsonb_build_object(
      'driver_account_id', v_existing.driver_account_id,
      'display_name', v_name,
      'phone_e164', v_phone,
      'amount_inr', v_existing.amount_inr,
      'lookup_id', v_existing.id,
      'already_unlocked', true
    );
  end if;

  select da.display_name, da.phone_e164 into v_name, v_phone
  from public.driver_accounts da where da.id = p_driver_account_id;
  if not found then
    raise exception 'DRIVER_NOT_FOUND';
  end if;
  if not exists (
    select 1 from public.driver_licences dl
    where dl.driver_account_id = p_driver_account_id
      and dl.verification_status = 'VERIFIED'
  ) then
    raise exception 'DRIVER_NOT_VERIFIED';
  end if;

  v_lookup_id := gen_random_uuid();
  v_payment_id := gen_random_uuid();

  insert into public.payment_transactions (
    id, company_id, purpose, amount_inr, currency, method, provider_reference,
    status, notes, recorded_by, idempotency_key
  ) values (
    v_payment_id, v_company_id, 'CONTACT_LOOKUP', 100.00, 'INR', 'MANUAL',
    'driver_contact_lookup:' || p_driver_account_id::text, 'CAPTURED',
    'Driver contact unlock', (select auth.uid()), p_idempotency_key
  );

  insert into public.driver_contact_lookups (
    id, company_id, driver_account_id, looked_up_by, amount_inr,
    payment_transaction_id, idempotency_key
  ) values (
    v_lookup_id, v_company_id, p_driver_account_id, (select auth.uid()),
    100.00, v_payment_id, p_idempotency_key
  );

  perform public.easyfleet_write_audit_event(
    v_company_id, 'DRIVER_CONTACT_LOOKUP', v_lookup_id, 'CONTACT_UNLOCKED',
    p_idempotency_key,
    jsonb_build_object('driver_account_id', p_driver_account_id, 'amount_inr', 100)
  );

  return jsonb_build_object(
    'driver_account_id', p_driver_account_id,
    'display_name', v_name,
    'phone_e164', v_phone,
    'amount_inr', 100.00,
    'lookup_id', v_lookup_id,
    'already_unlocked', false
  );
end;
$$;

revoke all on function public.easyfleet_lookup_driver_contact(uuid, uuid) from public;
grant execute on function public.easyfleet_lookup_driver_contact(uuid, uuid) to authenticated;

commit;
