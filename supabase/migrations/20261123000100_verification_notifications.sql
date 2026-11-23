-- EasyFleet Phase 2 migration 1: office-controlled DL/GST verification,
-- document review history, platform staff, notifications.
-- Additive only: no table drops, no data deletion, no policy removal.
-- Rollback: see supabase/rollback/20261123000100_rollback.sql

begin;

-- ---------------------------------------------------------------------------
-- 0. Encryption keys (vault). pgcrypto lives in the extensions schema.
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from vault.secrets where name = 'easyfleet_dl_encryption_key') then
    perform vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'hex'),
      'easyfleet_dl_encryption_key',
      'Symmetric key for encrypting driver licence numbers at rest'
    );
  end if;
  if not exists (select 1 from vault.secrets where name = 'easyfleet_gps_credentials_key') then
    perform vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'hex'),
      'easyfleet_gps_credentials_key',
      'Symmetric key for encrypting GPS provider API credentials at rest'
    );
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 1. Additive columns for document paths and office verification state.
-- ---------------------------------------------------------------------------
alter table public.driver_licences add column if not exists licence_document_path text;
alter table public.driver_licences add column if not exists rejection_reason text;

alter table public.companies add column if not exists gst_verification_status text not null default 'NOT_SUBMITTED';
alter table public.companies add column if not exists gst_rejection_reason text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'companies_gst_verification_status_check') then
    alter table public.companies add constraint companies_gst_verification_status_check
      check (gst_verification_status in ('NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'FAILED'));
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Platform staff (office). Managed only by postgres/service_role.
-- ---------------------------------------------------------------------------
create table if not exists public.platform_staff (
  user_id uuid primary key references auth.users (id),
  staff_role text not null default 'VERIFICATION_OFFICER'
    check (staff_role in ('VERIFICATION_OFFICER', 'SUPPORT_ADMIN')),
  created_by uuid references auth.users (id),
  created_at timestamptz not null default now()
);
alter table public.platform_staff enable row level security;
-- No policies for authenticated/anon: office roster is server-managed only.

create or replace function public.is_platform_staff()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.platform_staff ps where ps.user_id = (select auth.uid())
  );
$$;
revoke all on function public.is_platform_staff() from public;
grant execute on function public.is_platform_staff() to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Notifications (recipient-scoped, realtime).
-- ---------------------------------------------------------------------------
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id),
  company_id uuid references public.companies (id),
  kind text not null,
  title text not null,
  body text not null default '',
  data jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists notifications_user_created_idx
  on public.notifications (user_id, created_at desc);
alter table public.notifications enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='notifications' and policyname='notifications_select_own') then
    create policy notifications_select_own on public.notifications
      for select to authenticated using (user_id = (select auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='notifications' and policyname='notifications_mark_read_own') then
    create policy notifications_mark_read_own on public.notifications
      for update to authenticated
      using (user_id = (select auth.uid()))
      with check (user_id = (select auth.uid()));
  end if;
end $$;

grant select, update (read_at) on public.notifications to authenticated;

-- Internal helper: only SECURITY DEFINER owners may insert notifications.
create or replace function public.easyfleet_notify(
  p_user_id uuid,
  p_kind text,
  p_title text,
  p_body text default '',
  p_company_id uuid default null,
  p_data jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if p_user_id is null then
    return null;
  end if;
  insert into public.notifications (user_id, company_id, kind, title, body, data)
  values (p_user_id, p_company_id, p_kind, p_title, coalesce(p_body, ''), coalesce(p_data, '{}'::jsonb))
  returning id into v_id;
  return v_id;
end;
$$;
revoke all on function public.easyfleet_notify(uuid, text, text, text, uuid, jsonb) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 4. Document review history (append-only).
-- ---------------------------------------------------------------------------
create table if not exists public.document_review_history (
  id uuid primary key default gen_random_uuid(),
  subject_type text not null check (subject_type in ('DRIVER_LICENCE', 'COMPANY_GST')),
  driver_account_id uuid references public.driver_accounts (id),
  company_id uuid references public.companies (id),
  decision text not null check (decision in ('SUBMITTED', 'APPROVED', 'REJECTED', 'REVIEW_REQUIRED')),
  reason text,
  storage_path text,
  acted_by uuid references auth.users (id),
  acted_at timestamptz not null default now(),
  idempotency_key uuid unique,
  check (
    (subject_type = 'DRIVER_LICENCE' and driver_account_id is not null)
    or (subject_type = 'COMPANY_GST' and company_id is not null)
  )
);
create index if not exists document_review_history_driver_idx
  on public.document_review_history (driver_account_id, acted_at desc);
create index if not exists document_review_history_company_idx
  on public.document_review_history (company_id, acted_at desc);
alter table public.document_review_history enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='document_review_history' and policyname='document_review_history_select') then
    create policy document_review_history_select on public.document_review_history
      for select to authenticated using (
        public.is_platform_staff()
        or (driver_account_id is not null and public.is_driver_account_owner(driver_account_id))
        or (company_id is not null and public.is_company_manager(company_id))
      );
  end if;
end $$;
grant select on public.document_review_history to authenticated;

create or replace function public.easyfleet_prevent_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception '% is append-only and cannot be modified or deleted.', tg_table_name;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'document_review_history_immutable') then
    create trigger document_review_history_immutable
      before update or delete on public.document_review_history
      for each row execute function public.easyfleet_prevent_mutation();
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 5. B-01 repair: set_driver_official_verification_status now targets the
--    authoritative driver_licences table. Signature and office authorization
--    model preserved; legacy company-compliance path retained.
-- ---------------------------------------------------------------------------
create or replace function public.set_driver_official_verification_status(
  p_driver_account_id uuid,
  p_new_status text,
  p_verification_notes text default ''::text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_old_status text;
  v_company_id uuid;
  v_mapped text;
  v_auth_user uuid;
begin
  if auth.uid() is null then
    raise exception 'Unauthenticated caller.';
  end if;

  if p_new_status not in ('OFFICIALLY_VERIFIED', 'REJECTED', 'MANUAL_REVIEW_REQUIRED') then
    raise exception 'Invalid verification status requested: %', p_new_status;
  end if;

  v_mapped := case p_new_status
    when 'OFFICIALLY_VERIFIED' then 'VERIFIED'
    when 'REJECTED' then 'FAILED'
    else 'REVIEW_REQUIRED'
  end;

  select dl.verification_status into v_old_status
  from public.driver_licences dl
  where dl.driver_account_id = p_driver_account_id;

  if v_old_status is null then
    raise exception 'Driver licence not found for account %', p_driver_account_id;
  end if;

  -- Legacy authorization: compliance operators of a company with an APPROVED
  -- driver membership. Office (platform staff) and service_role also allowed.
  select cm.company_id into v_company_id
  from public.company_memberships cm
  join public.driver_memberships dm on dm.company_id = cm.company_id
  where cm.user_id = auth.uid()
    and cm.status = 'ACTIVE'
    and cm.role in ('OWNER', 'ADMIN', 'COMPLIANCE')
    and dm.driver_account_id = p_driver_account_id
    and dm.status = 'APPROVED'
  limit 1;

  if v_company_id is null
     and not public.is_platform_staff()
     and current_setting('role', true) <> 'service_role' then
    raise exception 'Unauthorized: Only compliance operators of a company with APPROVED driver membership can verify licence status.';
  end if;

  update public.driver_licences
  set verification_status = v_mapped,
      verified_at = case when v_mapped = 'VERIFIED' then now() else verified_at end,
      verification_source = 'OFFICE_REVIEW',
      rejection_reason = case when v_mapped = 'FAILED' then nullif(trim(p_verification_notes), '') else null end,
      updated_at = now()
  where driver_account_id = p_driver_account_id;

  insert into public.driver_verification_audit_logs (
    driver_account_id, verified_by_user_id, company_id, old_status, new_status, verification_notes
  ) values (
    p_driver_account_id, auth.uid(), v_company_id,
    coalesce(v_old_status, 'NOT_UPLOADED'), p_new_status, coalesce(p_verification_notes, '')
  );

  insert into public.document_review_history (
    subject_type, driver_account_id, company_id, decision, reason, acted_by
  ) values (
    'DRIVER_LICENCE', p_driver_account_id, v_company_id,
    case v_mapped when 'VERIFIED' then 'APPROVED' when 'FAILED' then 'REJECTED' else 'REVIEW_REQUIRED' end,
    nullif(trim(p_verification_notes), ''), auth.uid()
  );

  select da.auth_user_id into v_auth_user
  from public.driver_accounts da where da.id = p_driver_account_id;

  perform public.easyfleet_notify(
    v_auth_user,
    'DL_VERIFICATION',
    case v_mapped
      when 'VERIFIED' then 'Driving licence verified'
      when 'FAILED' then 'Driving licence rejected'
      else 'Driving licence needs review'
    end,
    coalesce(nullif(trim(p_verification_notes), ''), 'Your licence verification status was updated.'),
    v_company_id,
    jsonb_build_object('driver_account_id', p_driver_account_id, 'status', v_mapped)
  );

  if v_company_id is not null then
    perform public.easyfleet_write_audit_event(
      v_company_id, 'DRIVER_LICENCE', p_driver_account_id, 'DL_VERIFICATION_UPDATED',
      gen_random_uuid(),
      jsonb_build_object('old_status', v_old_status, 'new_status', v_mapped)
    );
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. Office review RPCs with idempotency.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_review_driver_licence(
  p_driver_account_id uuid,
  p_decision text,
  p_reason text default null,
  p_idempotency_key uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_licence public.driver_licences%rowtype;
  v_company_id uuid;
  v_key uuid := coalesce(p_idempotency_key, gen_random_uuid());
  v_status text;
  v_auth_user uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if p_decision not in ('APPROVED', 'REJECTED', 'REVIEW_REQUIRED') then
    raise exception 'Decision must be APPROVED, REJECTED or REVIEW_REQUIRED';
  end if;
  if p_decision = 'REJECTED' and nullif(trim(p_reason), '') is null then
    raise exception 'A rejection reason is required';
  end if;

  select * into v_licence from public.driver_licences
  where driver_account_id = p_driver_account_id for update;
  if not found then
    raise exception 'Driver licence not found';
  end if;

  select cm.company_id into v_company_id
  from public.company_memberships cm
  join public.driver_memberships dm on dm.company_id = cm.company_id
  where cm.user_id = auth.uid()
    and cm.status = 'ACTIVE'
    and cm.role in ('OWNER', 'ADMIN', 'COMPLIANCE')
    and dm.driver_account_id = p_driver_account_id
    and dm.status = 'APPROVED'
  limit 1;

  if v_company_id is null
     and not public.is_platform_staff()
     and current_setting('role', true) <> 'service_role' then
    raise exception 'Office verification permission required';
  end if;

  if exists (
    select 1 from public.document_review_history
    where idempotency_key = v_key
  ) then
    return v_licence.id;
  end if;

  v_status := case p_decision
    when 'APPROVED' then 'VERIFIED'
    when 'REJECTED' then 'FAILED'
    else 'REVIEW_REQUIRED'
  end;

  update public.driver_licences
  set verification_status = v_status,
      verified_at = case when v_status = 'VERIFIED' then now() else verified_at end,
      verification_source = 'OFFICE_REVIEW',
      rejection_reason = case when v_status = 'FAILED' then trim(p_reason) else null end,
      updated_at = now()
  where id = v_licence.id;

  insert into public.document_review_history (
    subject_type, driver_account_id, company_id, decision, reason, storage_path, acted_by, idempotency_key
  ) values (
    'DRIVER_LICENCE', p_driver_account_id, v_company_id, p_decision,
    nullif(trim(p_reason), ''), v_licence.licence_document_path, auth.uid(), v_key
  );

  insert into public.driver_verification_audit_logs (
    driver_account_id, verified_by_user_id, company_id, old_status, new_status, verification_notes
  ) values (
    p_driver_account_id, auth.uid(), v_company_id, v_licence.verification_status,
    case p_decision when 'APPROVED' then 'OFFICIALLY_VERIFIED' when 'REJECTED' then 'REJECTED' else 'MANUAL_REVIEW_REQUIRED' end,
    coalesce(p_reason, '')
  );

  select da.auth_user_id into v_auth_user
  from public.driver_accounts da where da.id = p_driver_account_id;

  perform public.easyfleet_notify(
    v_auth_user, 'DL_VERIFICATION',
    case p_decision
      when 'APPROVED' then 'Driving licence verified'
      when 'REJECTED' then 'Driving licence rejected'
      else 'Driving licence needs review'
    end,
    coalesce(nullif(trim(p_reason), ''), 'Your licence verification status was updated.'),
    v_company_id,
    jsonb_build_object('driver_account_id', p_driver_account_id, 'status', v_status)
  );

  if v_company_id is not null then
    perform public.easyfleet_write_audit_event(
      v_company_id, 'DRIVER_LICENCE', p_driver_account_id, 'DL_VERIFICATION_UPDATED',
      v_key, jsonb_build_object('decision', p_decision, 'old_status', v_licence.verification_status)
    );
  end if;

  return v_licence.id;
end;
$$;
revoke all on function public.easyfleet_review_driver_licence(uuid, text, text, uuid) from public;
grant execute on function public.easyfleet_review_driver_licence(uuid, text, text, uuid) to authenticated;

create or replace function public.easyfleet_review_company_gst(
  p_company_id uuid,
  p_decision text,
  p_reason text default null,
  p_idempotency_key uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_company public.companies%rowtype;
  v_key uuid := coalesce(p_idempotency_key, gen_random_uuid());
  v_status text;
  v_owner record;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  -- GST approval is office-controlled: platform staff or service_role only.
  if not public.is_platform_staff() and current_setting('role', true) <> 'service_role' then
    raise exception 'Office verification permission required';
  end if;
  if p_decision not in ('APPROVED', 'REJECTED', 'REVIEW_REQUIRED') then
    raise exception 'Decision must be APPROVED, REJECTED or REVIEW_REQUIRED';
  end if;
  if p_decision = 'REJECTED' and nullif(trim(p_reason), '') is null then
    raise exception 'A rejection reason is required';
  end if;

  select * into v_company from public.companies where id = p_company_id for update;
  if not found then
    raise exception 'Company not found';
  end if;

  if exists (select 1 from public.document_review_history where idempotency_key = v_key) then
    return p_company_id;
  end if;

  v_status := case p_decision when 'APPROVED' then 'VERIFIED' when 'REJECTED' then 'FAILED' else 'PENDING' end;

  update public.companies
  set gst_verification_status = v_status,
      gst_rejection_reason = case when v_status = 'FAILED' then trim(p_reason) else null end,
      updated_at = now()
  where id = p_company_id;

  insert into public.document_review_history (
    subject_type, company_id, decision, reason, storage_path, acted_by, idempotency_key
  ) values (
    'COMPANY_GST', p_company_id, p_decision, nullif(trim(p_reason), ''),
    v_company.gst_certificate_path, auth.uid(), v_key
  );

  for v_owner in
    select user_id from public.company_memberships
    where company_id = p_company_id and status = 'ACTIVE' and role in ('OWNER', 'ADMIN')
  loop
    perform public.easyfleet_notify(
      v_owner.user_id, 'GST_VERIFICATION',
      case p_decision
        when 'APPROVED' then 'GST verification approved'
        when 'REJECTED' then 'GST verification rejected'
        else 'GST verification under review'
      end,
      coalesce(nullif(trim(p_reason), ''), 'Your company GST verification status was updated.'),
      p_company_id,
      jsonb_build_object('company_id', p_company_id, 'status', v_status)
    );
  end loop;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'COMPANY', p_company_id, 'GST_VERIFICATION_UPDATED',
    v_key, jsonb_build_object('decision', p_decision, 'old_status', v_company.gst_verification_status)
  );

  return p_company_id;
end;
$$;
revoke all on function public.easyfleet_review_company_gst(uuid, text, text, uuid) from public;
grant execute on function public.easyfleet_review_company_gst(uuid, text, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Corrected submission RPCs (fix encrypted_dl NOT NULL and audit company
--    scope; store document paths; record submission history; notify office).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_submit_driver_licence(
  p_driver_account_id uuid,
  p_licence_class text,
  p_licence_fingerprint text,
  p_storage_path text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_licence_id uuid;
  v_fingerprint text := upper(trim(p_licence_fingerprint));
  v_class text := upper(trim(p_licence_class));
  v_key text;
  v_company_id uuid;
  v_staff record;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if p_driver_account_id is null or not public.is_driver_account_owner(p_driver_account_id) then
    raise exception 'Not authorized for this driver account';
  end if;
  if v_fingerprint is null or length(v_fingerprint) = 0
     or v_class is null or length(v_class) = 0 then
    raise exception 'Licence class and DL number are required';
  end if;
  if nullif(trim(p_storage_path), '') is null then
    raise exception 'Licence document storage path is required';
  end if;
  if exists (
    select 1 from public.driver_licences
    where dl_fingerprint = v_fingerprint and driver_account_id <> p_driver_account_id
  ) then
    raise exception 'Licence number already registered' using errcode = '23505';
  end if;

  select decrypted_secret into v_key
  from vault.decrypted_secrets where name = 'easyfleet_dl_encryption_key';

  insert into public.driver_licences (
    id, driver_account_id, dl_fingerprint, encrypted_dl, licence_class,
    issuing_state, valid_from, valid_until, verification_status,
    verification_source, licence_document_path, rejection_reason, created_at, updated_at
  ) values (
    gen_random_uuid(), p_driver_account_id, v_fingerprint,
    extensions.pgp_sym_encrypt(v_fingerprint, v_key),
    v_class, 'UNKNOWN', current_date, (current_date + interval '10 years')::date,
    'PENDING', 'APP_SUBMISSION', trim(p_storage_path), null, now(), now()
  )
  on conflict (driver_account_id) do update set
    dl_fingerprint = excluded.dl_fingerprint,
    encrypted_dl = excluded.encrypted_dl,
    licence_class = excluded.licence_class,
    verification_status = 'PENDING',
    verification_source = 'APP_SUBMISSION',
    licence_document_path = excluded.licence_document_path,
    rejection_reason = null,
    updated_at = now()
  returning id into v_licence_id;

  insert into public.document_review_history (
    subject_type, driver_account_id, decision, storage_path, acted_by
  ) values (
    'DRIVER_LICENCE', p_driver_account_id, 'SUBMITTED', trim(p_storage_path), auth.uid()
  );

  for v_staff in select user_id from public.platform_staff loop
    perform public.easyfleet_notify(
      v_staff.user_id, 'DL_SUBMISSION', 'New driving licence submitted',
      'A driver submitted a licence for office verification.', null,
      jsonb_build_object('driver_account_id', p_driver_account_id)
    );
  end loop;

  -- fleet_audit_events.company_id is NOT NULL; only write when the driver
  -- already belongs to a company. Review history is the authoritative log.
  select dm.company_id into v_company_id
  from public.driver_memberships dm
  where dm.driver_account_id = p_driver_account_id and dm.status = 'APPROVED'
  limit 1;
  if v_company_id is not null then
    perform public.easyfleet_write_audit_event(
      v_company_id, 'DRIVER_LICENCE', p_driver_account_id, 'LICENCE_SUBMITTED',
      gen_random_uuid(),
      jsonb_build_object('storage_path', trim(p_storage_path), 'licence_class', v_class)
    );
  end if;

  return v_licence_id;
end;
$$;
revoke all on function public.easyfleet_submit_driver_licence(uuid, text, text, text) from public;
grant execute on function public.easyfleet_submit_driver_licence(uuid, text, text, text) to authenticated;

create or replace function public.easyfleet_submit_company_gst(
  p_company_id uuid,
  p_gstin text,
  p_legal_name text,
  p_storage_path text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_gstin text := upper(trim(p_gstin));
  v_staff record;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if p_company_id is null or not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if v_gstin is null or length(v_gstin) = 0 then
    raise exception 'GSTIN is required';
  end if;
  if nullif(trim(p_storage_path), '') is null then
    raise exception 'GST certificate storage path is required';
  end if;

  update public.companies
  set gstin = v_gstin,
      legal_name = coalesce(nullif(trim(p_legal_name), ''), legal_name),
      gst_certificate_path = trim(p_storage_path),
      gst_verification_status = 'PENDING',
      gst_rejection_reason = null,
      updated_at = now()
  where id = p_company_id;

  insert into public.document_review_history (
    subject_type, company_id, decision, storage_path, acted_by
  ) values (
    'COMPANY_GST', p_company_id, 'SUBMITTED', trim(p_storage_path), auth.uid()
  );

  for v_staff in select user_id from public.platform_staff loop
    perform public.easyfleet_notify(
      v_staff.user_id, 'GST_SUBMISSION', 'New GST certificate submitted',
      'A company submitted GST documents for office verification.', p_company_id,
      jsonb_build_object('company_id', p_company_id)
    );
  end loop;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'COMPANY', p_company_id, 'GST_SUBMITTED',
    gen_random_uuid(),
    jsonb_build_object('storage_path', trim(p_storage_path), 'gstin', v_gstin)
  );

  return p_company_id;
end;
$$;
revoke all on function public.easyfleet_submit_company_gst(uuid, text, text, text) from public;
grant execute on function public.easyfleet_submit_company_gst(uuid, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 8. Realtime publication for status synchronization.
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.notifications;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.driver_licences;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.companies;
  exception when duplicate_object then null;
  end;
end $$;

commit;
