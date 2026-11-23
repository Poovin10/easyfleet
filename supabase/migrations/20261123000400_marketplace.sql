-- EasyFleet Phase 2 migration 4: job marketplace.
-- Separate from core fleet operations: marketplace tables reference companies
-- and driver_accounts but never modify fleet_trips directly. Appointment
-- atomically creates the company-driver relationship used by fleet operations.

begin;

-- ---------------------------------------------------------------------------
-- 1. Tables.
-- ---------------------------------------------------------------------------
create table if not exists public.job_postings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  posted_by uuid references auth.users (id),
  title text not null,
  description text,
  origin text,
  destination text,
  material text,
  tonnes numeric(12, 3),
  vehicle_type text,
  required_licence_classes text[] not null default '{}',
  city text,
  state text,
  rate_amount numeric(14, 2),
  rate_unit text check (rate_unit in ('PER_TRIP', 'PER_TONNE', 'MONTHLY_SALARY')),
  scheduled_date date,
  status text not null default 'OPEN'
    check (status in ('OPEN', 'FILLED', 'CLOSED', 'CANCELLED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists job_postings_status_idx on public.job_postings (status, created_at desc);
create index if not exists job_postings_company_idx on public.job_postings (company_id);
alter table public.job_postings enable row level security;

create table if not exists public.job_applications (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.job_postings (id),
  driver_account_id uuid not null references public.driver_accounts (id),
  applicant_user_id uuid not null references auth.users (id),
  cover_note text,
  status text not null default 'APPLIED'
    check (status in ('APPLIED', 'SHORTLISTED', 'APPOINTED', 'REJECTED', 'WITHDRAWN')),
  reviewed_by uuid references auth.users (id),
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (job_id, driver_account_id)
);
create index if not exists job_applications_driver_idx on public.job_applications (driver_account_id, created_at desc);
alter table public.job_applications enable row level security;

create table if not exists public.job_assignments (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null unique references public.job_postings (id),
  application_id uuid not null unique references public.job_applications (id),
  company_id uuid not null references public.companies (id),
  driver_account_id uuid not null references public.driver_accounts (id),
  company_driver_id uuid not null references public.company_drivers (id),
  status text not null default 'ACTIVE' check (status in ('ACTIVE', 'ENDED')),
  appointed_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  ended_at timestamptz
);
create index if not exists job_assignments_driver_idx on public.job_assignments (driver_account_id);
alter table public.job_assignments enable row level security;

-- ---------------------------------------------------------------------------
-- 2. RLS: open jobs are discoverable by any authenticated user; everything
--    else is scoped to the posting company or the applying driver.
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='job_postings' and policyname='job_postings_select') then
    create policy job_postings_select on public.job_postings
      for select to authenticated using (
        status = 'OPEN' or public.is_company_member(company_id)
      );
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='job_applications' and policyname='job_applications_select') then
    create policy job_applications_select on public.job_applications
      for select to authenticated using (
        applicant_user_id = (select auth.uid())
        or public.is_driver_account_owner(driver_account_id)
        or exists (
          select 1 from public.job_postings jp
          where jp.id = job_applications.job_id and public.is_company_member(jp.company_id)
        )
      );
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='job_assignments' and policyname='job_assignments_select') then
    create policy job_assignments_select on public.job_assignments
      for select to authenticated using (
        public.is_company_member(company_id) or public.is_driver_account_owner(driver_account_id)
      );
  end if;
end $$;

grant select on public.job_postings, public.job_applications, public.job_assignments to authenticated;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'job_postings_updated_at') then
    create trigger job_postings_updated_at before update on public.job_postings
      for each row execute function public.easyfleet_set_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname = 'job_applications_updated_at') then
    create trigger job_applications_updated_at before update on public.job_applications
      for each row execute function public.easyfleet_set_updated_at();
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 3. Posting RPC (operator + subscription enforced).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_post_job(
  p_company_id uuid,
  p_job_id uuid,
  p_title text,
  p_idempotency_key uuid,
  p_description text default null,
  p_origin text default null,
  p_destination text default null,
  p_material text default null,
  p_tonnes numeric default null,
  p_vehicle_type text default null,
  p_required_licence_classes text[] default '{}',
  p_city text default null,
  p_state text default null,
  p_rate_amount numeric default null,
  p_rate_unit text default null,
  p_scheduled_date date default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_existing public.job_postings%rowtype;
  v_request jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if not public.has_active_subscription(p_company_id) then
    raise exception 'SUBSCRIPTION_REQUIRED: an active EasyFleet subscription is required to post jobs';
  end if;
  if p_job_id is null or p_idempotency_key is null or nullif(trim(p_title), '') is null then
    raise exception 'Job ID, title and idempotency key are required';
  end if;
  if p_rate_unit is not null and p_rate_unit not in ('PER_TRIP', 'PER_TONNE', 'MONTHLY_SALARY') then
    raise exception 'Invalid rate unit';
  end if;
  if p_rate_amount is not null and p_rate_amount < 0 then
    raise exception 'Rate cannot be negative';
  end if;

  v_request := jsonb_build_object(
    'title', trim(p_title), 'origin', p_origin, 'destination', p_destination,
    'material', p_material, 'tonnes', p_tonnes, 'vehicle_type', p_vehicle_type,
    'required_licence_classes', to_jsonb(p_required_licence_classes),
    'city', p_city, 'state', p_state, 'rate_amount', p_rate_amount,
    'rate_unit', p_rate_unit, 'scheduled_date', p_scheduled_date
  );

  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'JOB', p_job_id, 'JOB_POSTED', v_request
  ) then
    return p_job_id;
  end if;

  select * into v_existing from public.job_postings where id = p_job_id for update;
  if found then
    raise exception 'Job already exists' using errcode = '23505';
  end if;

  insert into public.job_postings (
    id, company_id, posted_by, title, description, origin, destination, material,
    tonnes, vehicle_type, required_licence_classes, city, state,
    rate_amount, rate_unit, scheduled_date
  ) values (
    p_job_id, p_company_id, auth.uid(), trim(p_title), nullif(trim(p_description), ''),
    nullif(trim(p_origin), ''), nullif(trim(p_destination), ''), nullif(trim(p_material), ''),
    p_tonnes, nullif(trim(p_vehicle_type), ''), coalesce(p_required_licence_classes, '{}'),
    nullif(trim(p_city), ''), nullif(trim(p_state), ''),
    p_rate_amount, p_rate_unit, p_scheduled_date
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'JOB', p_job_id, 'JOB_POSTED', p_idempotency_key,
    jsonb_build_object('request', v_request)
  );
  return p_job_id;
end;
$$;
revoke all on function public.easyfleet_post_job(uuid, uuid, text, uuid, text, text, text, text, numeric, text, text[], text, text, numeric, text, date) from public;
grant execute on function public.easyfleet_post_job(uuid, uuid, text, uuid, text, text, text, text, numeric, text, text[], text, text, numeric, text, date) to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Application RPCs.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_apply_to_job(
  p_job_id uuid,
  p_application_id uuid,
  p_cover_note text default null,
  p_idempotency_key uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_job public.job_postings%rowtype;
  v_driver_account uuid;
  v_existing public.job_applications%rowtype;
  v_member record;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_application_id is null then raise exception 'Application ID required'; end if;

  select id into v_driver_account from public.driver_accounts where auth_user_id = auth.uid();
  if v_driver_account is null then
    raise exception 'Driver account required. Complete driver signup first.';
  end if;

  select * into v_job from public.job_postings where id = p_job_id for update;
  if not found then raise exception 'Job not found'; end if;
  if v_job.status <> 'OPEN' then raise exception 'Job is not open for applications'; end if;

  select * into v_existing from public.job_applications
  where job_id = p_job_id and driver_account_id = v_driver_account for update;
  if found then
    if v_existing.status = 'WITHDRAWN' then
      update public.job_applications
      set status = 'APPLIED', cover_note = nullif(trim(p_cover_note), ''), updated_at = now()
      where id = v_existing.id;
      return v_existing.id;
    end if;
    return v_existing.id;
  end if;

  insert into public.job_applications (id, job_id, driver_account_id, applicant_user_id, cover_note)
  values (p_application_id, p_job_id, v_driver_account, auth.uid(), nullif(trim(p_cover_note), ''))
  returning * into v_existing;

  for v_member in
    select user_id from public.company_memberships
    where company_id = v_job.company_id and status = 'ACTIVE'
      and role in ('OWNER', 'ADMIN', 'DISPATCHER')
  loop
    perform public.easyfleet_notify(
      v_member.user_id, 'JOB_APPLICATION', 'New job application',
      'A driver applied to "' || v_job.title || '".', v_job.company_id,
      jsonb_build_object('job_id', p_job_id, 'application_id', v_existing.id)
    );
  end loop;

  perform public.easyfleet_write_audit_event(
    v_job.company_id, 'JOB_APPLICATION', v_existing.id, 'JOB_APPLIED',
    coalesce(p_idempotency_key, gen_random_uuid()),
    jsonb_build_object('job_id', p_job_id), v_driver_account
  );
  return v_existing.id;
end;
$$;
revoke all on function public.easyfleet_apply_to_job(uuid, uuid, text, uuid) from public;
grant execute on function public.easyfleet_apply_to_job(uuid, uuid, text, uuid) to authenticated;

create or replace function public.easyfleet_review_application(
  p_application_id uuid,
  p_decision text,
  p_note text default null,
  p_idempotency_key uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_app public.job_applications%rowtype;
  v_job public.job_postings%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_decision not in ('SHORTLISTED', 'REJECTED') then
    raise exception 'Decision must be SHORTLISTED or REJECTED';
  end if;

  select * into v_app from public.job_applications where id = p_application_id for update;
  if not found then raise exception 'Application not found'; end if;
  select * into v_job from public.job_postings where id = v_app.job_id;
  if not public.is_company_operator(v_job.company_id) then
    raise exception 'Company operator permission required';
  end if;
  if v_app.status not in ('APPLIED', 'SHORTLISTED') then
    raise exception 'Only active applications can be reviewed';
  end if;

  update public.job_applications
  set status = p_decision, reviewed_by = auth.uid(), reviewed_at = now(),
      review_note = nullif(trim(p_note), ''), updated_at = now()
  where id = p_application_id;

  perform public.easyfleet_notify(
    v_app.applicant_user_id, 'JOB_APPLICATION',
    case p_decision when 'SHORTLISTED' then 'You were shortlisted' else 'Application update' end,
    'Your application to "' || v_job.title || '" was ' || lower(p_decision) || '.',
    v_job.company_id,
    jsonb_build_object('job_id', v_job.id, 'application_id', p_application_id, 'status', p_decision)
  );

  perform public.easyfleet_write_audit_event(
    v_job.company_id, 'JOB_APPLICATION', p_application_id, 'JOB_APPLICATION_REVIEWED',
    coalesce(p_idempotency_key, gen_random_uuid()),
    jsonb_build_object('decision', p_decision)
  );
  return p_application_id;
end;
$$;
revoke all on function public.easyfleet_review_application(uuid, text, text, uuid) from public;
grant execute on function public.easyfleet_review_application(uuid, text, text, uuid) to authenticated;

create or replace function public.easyfleet_withdraw_application(p_application_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_app public.job_applications%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into v_app from public.job_applications where id = p_application_id for update;
  if not found then raise exception 'Application not found'; end if;
  if v_app.applicant_user_id <> auth.uid() then
    raise exception 'Only the applicant can withdraw';
  end if;
  if v_app.status not in ('APPLIED', 'SHORTLISTED') then
    raise exception 'Only active applications can be withdrawn';
  end if;
  update public.job_applications set status = 'WITHDRAWN', updated_at = now()
  where id = p_application_id;
  return p_application_id;
end;
$$;
revoke all on function public.easyfleet_withdraw_application(uuid) from public;
grant execute on function public.easyfleet_withdraw_application(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Atomic appointment: company driver + approved membership + assignment.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_appoint_driver(
  p_application_id uuid,
  p_assignment_id uuid,
  p_idempotency_key uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_app public.job_applications%rowtype;
  v_job public.job_postings%rowtype;
  v_company_driver uuid;
  v_request jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_assignment_id is null or p_idempotency_key is null then
    raise exception 'Assignment ID and idempotency key required';
  end if;

  select * into v_app from public.job_applications where id = p_application_id for update;
  if not found then raise exception 'Application not found'; end if;
  select * into v_job from public.job_postings where id = v_app.job_id for update;
  if not public.is_company_manager(v_job.company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;

  v_request := jsonb_build_object('application_id', p_application_id, 'assignment_id', p_assignment_id);
  perform pg_advisory_xact_lock(hashtextextended(v_job.company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    v_job.company_id, p_idempotency_key, 'JOB_ASSIGNMENT', p_assignment_id, 'DRIVER_APPOINTED', v_request
  ) then
    return p_assignment_id;
  end if;

  if v_app.status not in ('APPLIED', 'SHORTLISTED') then
    raise exception 'Only active applications can be appointed';
  end if;
  if v_job.status <> 'OPEN' then raise exception 'Job is not open'; end if;

  insert into public.company_drivers (
    company_id, driver_account_id, local_driver_code, employment_role, created_by
  ) values (
    v_job.company_id, v_app.driver_account_id,
    'MKT-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
    'DRIVER', auth.uid()
  )
  on conflict (company_id, driver_account_id) do update set
    employment_role = public.company_drivers.employment_role
  returning id into v_company_driver;

  insert into public.driver_memberships (
    company_id, driver_account_id, company_driver_id, status,
    invited_by, approved_by, approved_at, joined_at
  ) values (
    v_job.company_id, v_app.driver_account_id, v_company_driver, 'APPROVED',
    auth.uid(), auth.uid(), now(), now()
  )
  on conflict (company_id, driver_account_id) do update set
    status = 'APPROVED',
    company_driver_id = excluded.company_driver_id,
    approved_by = auth.uid(),
    approved_at = now(),
    joined_at = coalesce(public.driver_memberships.joined_at, now()),
    left_at = null,
    updated_at = now();

  insert into public.job_assignments (
    id, job_id, application_id, company_id, driver_account_id, company_driver_id, appointed_by
  ) values (
    p_assignment_id, v_job.id, p_application_id, v_job.company_id,
    v_app.driver_account_id, v_company_driver, auth.uid()
  );

  update public.job_applications
  set status = 'APPOINTED', reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now()
  where id = p_application_id;

  update public.job_postings set status = 'FILLED', updated_at = now() where id = v_job.id;

  perform public.easyfleet_notify(
    v_app.applicant_user_id, 'JOB_APPOINTMENT', 'You have been appointed',
    'You were appointed to "' || v_job.title || '". Open the app to view your assignment.',
    v_job.company_id,
    jsonb_build_object('job_id', v_job.id, 'assignment_id', p_assignment_id, 'company_id', v_job.company_id)
  );

  perform public.easyfleet_write_audit_event(
    v_job.company_id, 'JOB_ASSIGNMENT', p_assignment_id, 'DRIVER_APPOINTED',
    p_idempotency_key, jsonb_build_object('request', v_request, 'driver_account_id', v_app.driver_account_id)
  );
  return p_assignment_id;
end;
$$;
revoke all on function public.easyfleet_appoint_driver(uuid, uuid, uuid) from public;
grant execute on function public.easyfleet_appoint_driver(uuid, uuid, uuid) to authenticated;

create or replace function public.easyfleet_end_assignment(p_assignment_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_assignment public.job_assignments%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into v_assignment from public.job_assignments where id = p_assignment_id for update;
  if not found then raise exception 'Assignment not found'; end if;
  if not public.is_company_manager(v_assignment.company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if v_assignment.status <> 'ACTIVE' then raise exception 'Assignment already ended'; end if;
  update public.job_assignments set status = 'ENDED', ended_at = now() where id = p_assignment_id;
  perform public.easyfleet_write_audit_event(
    v_assignment.company_id, 'JOB_ASSIGNMENT', p_assignment_id, 'ASSIGNMENT_ENDED',
    gen_random_uuid(), '{}'::jsonb
  );
  return p_assignment_id;
end;
$$;
revoke all on function public.easyfleet_end_assignment(uuid) from public;
grant execute on function public.easyfleet_end_assignment(uuid) to authenticated;

create or replace function public.easyfleet_close_job(p_job_id uuid, p_status text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_job public.job_postings%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_status not in ('CLOSED', 'CANCELLED') then
    raise exception 'Status must be CLOSED or CANCELLED';
  end if;
  select * into v_job from public.job_postings where id = p_job_id for update;
  if not found then raise exception 'Job not found'; end if;
  if not public.is_company_operator(v_job.company_id) then
    raise exception 'Company operator permission required';
  end if;
  if v_job.status <> 'OPEN' then raise exception 'Only open jobs can be closed'; end if;
  update public.job_postings set status = p_status, updated_at = now() where id = p_job_id;
  perform public.easyfleet_write_audit_event(
    v_job.company_id, 'JOB', p_job_id, 'JOB_CLOSED', gen_random_uuid(),
    jsonb_build_object('status', p_status)
  );
  return p_job_id;
end;
$$;
revoke all on function public.easyfleet_close_job(uuid, text) from public;
grant execute on function public.easyfleet_close_job(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Driver discovery for transporters (verified drivers only, no PII beyond
--    display name and licence class; phone numbers are never exposed).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_search_drivers(
  p_licence_class text default null,
  p_state text default null,
  p_limit integer default 50
)
returns table (
  driver_account_id uuid,
  display_name text,
  licence_class text,
  issuing_state text,
  verification_status text,
  valid_until date
)
language sql
stable
security definer
set search_path = ''
as $$
  select da.id, da.display_name, dl.licence_class, dl.issuing_state,
         dl.verification_status, dl.valid_until
  from public.driver_accounts da
  join public.driver_licences dl on dl.driver_account_id = da.id
  where dl.verification_status = 'VERIFIED'
    and (p_licence_class is null or dl.licence_class = upper(trim(p_licence_class)))
    and (p_state is null or dl.issuing_state ilike '%' || trim(p_state) || '%')
    and exists (
      select 1 from public.company_memberships cm
      where cm.user_id = (select auth.uid()) and cm.status = 'ACTIVE'
    )
  order by da.display_name
  limit least(coalesce(p_limit, 50), 100);
$$;
revoke all on function public.easyfleet_search_drivers(text, text, integer) from public;
grant execute on function public.easyfleet_search_drivers(text, text, integer) to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Realtime for marketplace status tracking.
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.job_postings;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.job_applications;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.job_assignments;
  exception when duplicate_object then null;
  end;
end $$;

commit;
