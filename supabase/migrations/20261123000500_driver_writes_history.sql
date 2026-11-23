-- EasyFleet Phase 2 migration 5: driver-facing reads and write RPCs,
-- driver trip history access, breadcrumb idempotent capture, audit realtime.
-- Additive only.

begin;

-- ---------------------------------------------------------------------------
-- 1. Missing read policies. driver_licences had RLS enabled with no policy,
--    which blocked the driver's own status reads. Owners and company
--    compliance reviewers may read; writes remain RPC-only.
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='driver_licences' and policyname='driver_licences_scoped_read') then
    create policy driver_licences_scoped_read on public.driver_licences
      for select to authenticated using (
        public.is_driver_account_owner(driver_account_id)
        or public.is_platform_staff()
        or exists (
          select 1 from public.driver_memberships dm
          where dm.driver_account_id = driver_licences.driver_account_id
            and dm.status = 'APPROVED'
            and public.is_company_history_reviewer(dm.company_id)
        )
      );
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='driver_verification_audit_logs' and policyname='driver_verification_audit_logs_scoped_read') then
    create policy driver_verification_audit_logs_scoped_read on public.driver_verification_audit_logs
      for select to authenticated using (
        public.is_driver_account_owner(driver_account_id)
        or public.is_platform_staff()
        or (company_id is not null and public.is_company_history_reviewer(company_id))
      );
  end if;
end $$;
grant select on public.driver_licences, public.driver_verification_audit_logs to authenticated;

-- Driver-scoped trip history reads (audit, fuel, expenses). Company policies
-- remain in place; these add the assigned-driver path.
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='fleet_audit_events' and policyname='fleet_audit_events_driver_read') then
    create policy fleet_audit_events_driver_read on public.fleet_audit_events
      for select to authenticated using (
        exists (
          select 1 from public.fleet_trips ft
          where ft.id = fleet_audit_events.entity_id
            and ft.company_id = fleet_audit_events.company_id
            and ft.driver_account_id is not null
            and public.is_driver_account_owner(ft.driver_account_id)
        )
      );
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='trip_fuel_entries' and policyname='trip_fuel_entries_driver_read') then
    create policy trip_fuel_entries_driver_read on public.trip_fuel_entries
      for select to authenticated using (
        exists (
          select 1 from public.fleet_trips ft
          where ft.id = trip_fuel_entries.trip_id
            and ft.driver_account_id is not null
            and public.is_driver_account_owner(ft.driver_account_id)
        )
      );
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='trip_expenses' and policyname='trip_expenses_driver_read') then
    create policy trip_expenses_driver_read on public.trip_expenses
      for select to authenticated using (
        exists (
          select 1 from public.fleet_trips ft
          where ft.id = trip_expenses.trip_id
            and ft.driver_account_id is not null
            and public.is_driver_account_owner(ft.driver_account_id)
        )
      );
  end if;
end $$;

-- Audit integrity: fleet_audit_events is append-only.
do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'fleet_audit_events_immutable') then
    create trigger fleet_audit_events_immutable
      before update or delete on public.fleet_audit_events
      for each row execute function public.easyfleet_prevent_mutation();
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Internal authorization helper for driver trip writes.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_assert_trip_driver(
  p_trip_id uuid,
  p_company_id uuid
)
returns public.fleet_trips
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into v_trip from public.fleet_trips
  where id = p_trip_id and company_id = p_company_id;
  if not found then raise exception 'Trip not found'; end if;
  if v_trip.driver_account_id is null
     or not public.is_driver_account_owner(v_trip.driver_account_id)
     or not public.is_approved_company_driver(p_company_id, v_trip.driver_account_id) then
    raise exception 'Assigned driver permission required';
  end if;
  return v_trip;
end;
$$;
revoke all on function public.easyfleet_assert_trip_driver(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. Fuel entry (DIESEL / ADBLUE share this table, matching native contract).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_add_fuel_entry(
  p_company_id uuid,
  p_trip_id uuid,
  p_entry_id uuid,
  p_fuel_type text,
  p_litres numeric,
  p_amount numeric,
  p_idempotency_key uuid,
  p_rate_per_litre numeric default null,
  p_pump_name text default null,
  p_odometer_km bigint default null,
  p_bill_reference text default null,
  p_notes text default null,
  p_entry_time timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
  v_existing public.trip_fuel_entries%rowtype;
  v_request jsonb;
begin
  v_trip := public.easyfleet_assert_trip_driver(p_trip_id, p_company_id);
  if p_entry_id is null or p_idempotency_key is null then
    raise exception 'Entry ID and idempotency key required';
  end if;
  if p_fuel_type not in ('DIESEL', 'ADBLUE') then
    raise exception 'Fuel type must be DIESEL or ADBLUE';
  end if;
  if p_litres is null or p_litres <= 0 or p_amount is null or p_amount < 0 then
    raise exception 'Litres must be positive and amount non-negative';
  end if;
  if p_rate_per_litre is not null and p_rate_per_litre < 0 then
    raise exception 'Rate cannot be negative';
  end if;
  if p_odometer_km is not null and p_odometer_km < 0 then
    raise exception 'Odometer cannot be negative';
  end if;

  v_request := jsonb_build_object(
    'trip_id', p_trip_id, 'fuel_type', p_fuel_type, 'litres', p_litres,
    'amount', p_amount, 'rate_per_litre', p_rate_per_litre,
    'pump_name', nullif(trim(p_pump_name), ''), 'odometer_km', p_odometer_km,
    'entry_time', coalesce(p_entry_time, now())
  );
  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'FUEL_ENTRY', p_entry_id, 'FUEL_ENTRY_ADDED', v_request
  ) then
    return p_entry_id;
  end if;

  select * into v_existing from public.trip_fuel_entries where id = p_entry_id for update;
  if found then raise exception 'Fuel entry already exists' using errcode = '23505'; end if;

  insert into public.trip_fuel_entries (
    id, company_id, trip_id, fuel_type, litres, rate_per_litre, amount,
    pump_name, odometer_km, bill_reference, entry_time, entered_by, notes, idempotency_key
  ) values (
    p_entry_id, p_company_id, p_trip_id, p_fuel_type, p_litres, p_rate_per_litre, p_amount,
    nullif(trim(p_pump_name), ''), p_odometer_km, nullif(trim(p_bill_reference), ''),
    coalesce(p_entry_time, now()), auth.uid(), nullif(trim(p_notes), ''), p_idempotency_key
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'FUEL_ENTRY', p_entry_id, 'FUEL_ENTRY_ADDED', p_idempotency_key,
    jsonb_build_object('request', v_request), v_trip.driver_account_id
  );
  return p_entry_id;
end;
$$;
revoke all on function public.easyfleet_add_fuel_entry(uuid, uuid, uuid, text, numeric, numeric, uuid, numeric, text, bigint, text, text, timestamptz) from public;
grant execute on function public.easyfleet_add_fuel_entry(uuid, uuid, uuid, text, numeric, numeric, uuid, numeric, text, bigint, text, text, timestamptz) to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Expense entry + manager review.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_add_expense_entry(
  p_company_id uuid,
  p_trip_id uuid,
  p_entry_id uuid,
  p_category text,
  p_amount numeric,
  p_idempotency_key uuid,
  p_description text default null,
  p_odometer_km bigint default null,
  p_bill_reference text default null,
  p_receipt_object_path text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
  v_request jsonb;
begin
  v_trip := public.easyfleet_assert_trip_driver(p_trip_id, p_company_id);
  if p_entry_id is null or p_idempotency_key is null
     or nullif(trim(p_category), '') is null then
    raise exception 'Entry ID, category and idempotency key required';
  end if;
  if p_amount is null or p_amount < 0 then
    raise exception 'Amount cannot be negative';
  end if;
  if p_receipt_object_path is not null then
    if p_receipt_object_path !~ ('^' || p_company_id::text || '/trips/' || p_trip_id::text || '/receipts/[^/]+$') then
      raise exception 'Receipt path must be company/trips/trip-id/receipts/file';
    end if;
    if not exists (
      select 1 from storage.objects o
      where o.bucket_id = 'easyfleet-private-documents' and o.name = p_receipt_object_path
    ) then
      raise exception 'Receipt object does not exist in private document storage';
    end if;
  end if;

  v_request := jsonb_build_object(
    'trip_id', p_trip_id, 'category', trim(p_category), 'amount', p_amount,
    'description', nullif(trim(p_description), ''), 'odometer_km', p_odometer_km,
    'receipt_object_path', p_receipt_object_path
  );
  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'EXPENSE_ENTRY', p_entry_id, 'EXPENSE_ENTRY_ADDED', v_request
  ) then
    return p_entry_id;
  end if;

  insert into public.trip_expenses (
    id, company_id, trip_id, category, description, amount, odometer_km,
    bill_reference, receipt_object_path, entered_by, idempotency_key
  ) values (
    p_entry_id, p_company_id, p_trip_id, trim(p_category), nullif(trim(p_description), ''),
    p_amount, p_odometer_km, nullif(trim(p_bill_reference), ''),
    p_receipt_object_path, auth.uid(), p_idempotency_key
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'EXPENSE_ENTRY', p_entry_id, 'EXPENSE_ENTRY_ADDED', p_idempotency_key,
    jsonb_build_object('request', v_request), v_trip.driver_account_id
  );
  return p_entry_id;
end;
$$;
revoke all on function public.easyfleet_add_expense_entry(uuid, uuid, uuid, text, numeric, uuid, text, bigint, text, text) from public;
grant execute on function public.easyfleet_add_expense_entry(uuid, uuid, uuid, text, numeric, uuid, text, bigint, text, text) to authenticated;

create or replace function public.easyfleet_review_expense(
  p_company_id uuid,
  p_entry_id uuid,
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
  v_entry public.trip_expenses%rowtype;
  v_driver_user uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if p_decision not in ('APPROVED', 'REJECTED') then
    raise exception 'Decision must be APPROVED or REJECTED';
  end if;
  select * into v_entry from public.trip_expenses
  where id = p_entry_id and company_id = p_company_id for update;
  if not found then raise exception 'Expense not found'; end if;
  if v_entry.approval_status <> 'PENDING' then
    raise exception 'Only pending expenses can be reviewed';
  end if;
  update public.trip_expenses
  set approval_status = p_decision, reviewed_by = auth.uid(), reviewed_at = now(),
      reviewer_note = nullif(trim(p_note), '')
  where id = p_entry_id;

  select da.auth_user_id into v_driver_user
  from public.driver_accounts da
  join public.fleet_trips ft on ft.driver_account_id = da.id
  where ft.id = v_entry.trip_id;
  perform public.easyfleet_notify(
    v_driver_user, 'EXPENSE_REVIEW',
    case p_decision when 'APPROVED' then 'Expense approved' else 'Expense rejected' end,
    coalesce(nullif(trim(p_note), ''), 'Your trip expense was reviewed.'),
    p_company_id, jsonb_build_object('entry_id', p_entry_id, 'status', p_decision)
  );
  perform public.easyfleet_write_audit_event(
    p_company_id, 'EXPENSE_ENTRY', p_entry_id, 'EXPENSE_REVIEWED',
    coalesce(p_idempotency_key, gen_random_uuid()), jsonb_build_object('decision', p_decision)
  );
  return p_entry_id;
end;
$$;
revoke all on function public.easyfleet_review_expense(uuid, uuid, text, text, uuid) from public;
grant execute on function public.easyfleet_review_expense(uuid, uuid, text, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Breakdown reports -> fleet_maintenance_jobs.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_report_breakdown(
  p_company_id uuid,
  p_trip_id uuid,
  p_job_id uuid,
  p_issue_description text,
  p_idempotency_key uuid,
  p_odometer_km bigint default null,
  p_workshop_location text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
  v_request jsonb;
  v_member record;
begin
  v_trip := public.easyfleet_assert_trip_driver(p_trip_id, p_company_id);
  if p_job_id is null or p_idempotency_key is null
     or nullif(trim(p_issue_description), '') is null then
    raise exception 'Job ID, issue description and idempotency key required';
  end if;
  if v_trip.vehicle_id is null then
    raise exception 'Trip has no assigned vehicle to report against';
  end if;

  v_request := jsonb_build_object(
    'trip_id', p_trip_id, 'vehicle_id', v_trip.vehicle_id,
    'issue_description', trim(p_issue_description), 'odometer_km', p_odometer_km,
    'workshop_location', nullif(trim(p_workshop_location), '')
  );
  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'MAINTENANCE_JOB', p_job_id, 'BREAKDOWN_REPORTED', v_request
  ) then
    return p_job_id;
  end if;

  insert into public.fleet_maintenance_jobs (
    id, company_id, vehicle_id, odometer_km, issue_description,
    workshop_location, status, created_by
  ) values (
    p_job_id, p_company_id, v_trip.vehicle_id, p_odometer_km,
    trim(p_issue_description), nullif(trim(p_workshop_location), ''), 'REPORTED', auth.uid()
  );

  for v_member in
    select user_id from public.company_memberships
    where company_id = p_company_id and status = 'ACTIVE'
      and role in ('OWNER', 'ADMIN', 'DISPATCHER')
  loop
    perform public.easyfleet_notify(
      v_member.user_id, 'BREAKDOWN', 'Breakdown reported',
      trim(p_issue_description), p_company_id,
      jsonb_build_object('job_id', p_job_id, 'trip_id', p_trip_id, 'vehicle_id', v_trip.vehicle_id)
    );
  end loop;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'MAINTENANCE_JOB', p_job_id, 'BREAKDOWN_REPORTED', p_idempotency_key,
    jsonb_build_object('request', v_request), v_trip.driver_account_id
  );
  return p_job_id;
end;
$$;
revoke all on function public.easyfleet_report_breakdown(uuid, uuid, uuid, text, uuid, bigint, text) from public;
grant execute on function public.easyfleet_report_breakdown(uuid, uuid, uuid, text, uuid, bigint, text) to authenticated;

create or replace function public.easyfleet_update_maintenance_job(
  p_company_id uuid,
  p_job_id uuid,
  p_status text,
  p_workshop_name text default null,
  p_estimated_cost numeric default null,
  p_service_bill_amount numeric default null,
  p_release_odometer_km bigint default null,
  p_notes text default null,
  p_idempotency_key uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_job public.fleet_maintenance_jobs%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if p_status not in ('REPORTED', 'SENT', 'IN_PROGRESS', 'READY', 'RELEASED', 'CANCELLED') then
    raise exception 'Invalid maintenance status';
  end if;
  select * into v_job from public.fleet_maintenance_jobs
  where id = p_job_id and company_id = p_company_id for update;
  if not found then raise exception 'Maintenance job not found'; end if;

  update public.fleet_maintenance_jobs
  set status = p_status,
      workshop_name = coalesce(nullif(trim(p_workshop_name), ''), workshop_name),
      estimated_cost = coalesce(p_estimated_cost, estimated_cost),
      service_bill_amount = coalesce(p_service_bill_amount, service_bill_amount),
      release_odometer_km = coalesce(p_release_odometer_km, release_odometer_km),
      notes = coalesce(nullif(trim(p_notes), ''), notes),
      sent_at = case when p_status = 'SENT' and sent_at is null then now() else sent_at end,
      released_at = case when p_status = 'RELEASED' and released_at is null then now() else released_at end,
      updated_at = now()
  where id = p_job_id;

  if p_status = 'RELEASED' then
    update public.fleet_vehicles
    set odometer_km = case
          when p_release_odometer_km is null then odometer_km
          when odometer_km is null then p_release_odometer_km
          else greatest(odometer_km, p_release_odometer_km)
        end,
        status = case when status = 'IN_MAINTENANCE' then 'AVAILABLE' else status end,
        updated_at = now()
    where id = v_job.vehicle_id and company_id = p_company_id;
  elsif p_status in ('SENT', 'IN_PROGRESS') then
    update public.fleet_vehicles set status = 'IN_MAINTENANCE', updated_at = now()
    where id = v_job.vehicle_id and company_id = p_company_id and status in ('AVAILABLE', 'INACTIVE');
  end if;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'MAINTENANCE_JOB', p_job_id, 'MAINTENANCE_UPDATED',
    coalesce(p_idempotency_key, gen_random_uuid()), jsonb_build_object('status', p_status)
  );
  return p_job_id;
end;
$$;
revoke all on function public.easyfleet_update_maintenance_job(uuid, uuid, text, text, numeric, numeric, bigint, text, uuid) from public;
grant execute on function public.easyfleet_update_maintenance_job(uuid, uuid, text, text, numeric, numeric, bigint, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Driver ledger payments (accounting records, manager-only writes).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_add_ledger_entry(
  p_company_id uuid,
  p_entry_id uuid,
  p_driver_account_id uuid,
  p_entry_type text,
  p_amount numeric,
  p_idempotency_key uuid,
  p_trip_id uuid default null,
  p_description text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_company_driver uuid;
  v_driver_user uuid;
  v_request jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if p_entry_id is null or p_idempotency_key is null then
    raise exception 'Entry ID and idempotency key required';
  end if;
  if p_entry_type not in ('BATA_EARNED', 'ADVANCE', 'APPROVED_DEDUCTION', 'PAYMENT', 'ADJUSTMENT') then
    raise exception 'Invalid ledger entry type';
  end if;
  if p_amount is null or p_amount < 0 then
    raise exception 'Amount cannot be negative';
  end if;

  select cd.id into v_company_driver
  from public.company_drivers cd
  where cd.company_id = p_company_id and cd.driver_account_id = p_driver_account_id;
  if v_company_driver is null then
    raise exception 'Driver is not registered in this company';
  end if;
  if p_trip_id is not null and not exists (
    select 1 from public.fleet_trips
    where id = p_trip_id and company_id = p_company_id and driver_account_id = p_driver_account_id
  ) then
    raise exception 'Trip does not belong to this driver and company';
  end if;

  v_request := jsonb_build_object(
    'driver_account_id', p_driver_account_id, 'entry_type', p_entry_type,
    'amount', p_amount, 'trip_id', p_trip_id, 'description', nullif(trim(p_description), '')
  );
  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'LEDGER_ENTRY', p_entry_id, 'LEDGER_ENTRY_ADDED', v_request
  ) then
    return p_entry_id;
  end if;

  insert into public.driver_ledger_entries (
    id, company_id, driver_account_id, company_driver_id, trip_id,
    entry_type, amount, description, approval_status, created_by, idempotency_key
  ) values (
    p_entry_id, p_company_id, p_driver_account_id, v_company_driver, p_trip_id,
    p_entry_type, p_amount, nullif(trim(p_description), ''), 'APPROVED', auth.uid(), p_idempotency_key
  );

  select da.auth_user_id into v_driver_user
  from public.driver_accounts da where da.id = p_driver_account_id;
  perform public.easyfleet_notify(
    v_driver_user, 'LEDGER', 'Wallet updated',
    initcap(replace(lower(p_entry_type), '_', ' ')) || ': ₹' || p_amount::text,
    p_company_id, jsonb_build_object('entry_id', p_entry_id, 'entry_type', p_entry_type, 'amount', p_amount)
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'LEDGER_ENTRY', p_entry_id, 'LEDGER_ENTRY_ADDED', p_idempotency_key,
    jsonb_build_object('request', v_request)
  );
  return p_entry_id;
end;
$$;
revoke all on function public.easyfleet_add_ledger_entry(uuid, uuid, uuid, text, numeric, uuid, uuid, text) from public;
grant execute on function public.easyfleet_add_ledger_entry(uuid, uuid, uuid, text, numeric, uuid, uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Trip cancellation (operator) with reason.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_cancel_trip(
  p_company_id uuid,
  p_trip_id uuid,
  p_reason text,
  p_idempotency_key uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
  v_driver_user uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if p_idempotency_key is null or nullif(trim(p_reason), '') is null then
    raise exception 'Idempotency key and cancellation reason required';
  end if;
  select * into v_trip from public.fleet_trips
  where id = p_trip_id and company_id = p_company_id for update;
  if not found then raise exception 'Trip not found'; end if;

  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'TRIP', p_trip_id, 'TRIP_CANCELLED',
    jsonb_build_object('reason', trim(p_reason))
  ) then
    return p_trip_id;
  end if;
  if v_trip.status not in ('PLANNED', 'ASSIGNED') then
    raise exception 'Only planned or assigned trips can be cancelled';
  end if;

  update public.fleet_trips
  set status = 'CANCELLED', cancelled_at = now(), cancellation_reason = trim(p_reason), updated_at = now()
  where id = p_trip_id;

  if v_trip.vehicle_id is not null then
    update public.fleet_vehicles set status = 'AVAILABLE', updated_at = now()
    where id = v_trip.vehicle_id and company_id = p_company_id and status = 'ASSIGNED';
  end if;

  if v_trip.driver_account_id is not null then
    select da.auth_user_id into v_driver_user
    from public.driver_accounts da where da.id = v_trip.driver_account_id;
    perform public.easyfleet_notify(
      v_driver_user, 'TRIP_CANCELLED', 'Trip cancelled',
      trim(p_reason), p_company_id, jsonb_build_object('trip_id', p_trip_id)
    );
  end if;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'TRIP', p_trip_id, 'TRIP_CANCELLED', p_idempotency_key,
    jsonb_build_object('reason', trim(p_reason))
  );
  return p_trip_id;
end;
$$;
revoke all on function public.easyfleet_cancel_trip(uuid, uuid, text, uuid) from public;
grant execute on function public.easyfleet_cancel_trip(uuid, uuid, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 8. Idempotent breadcrumb capture (preserves native queue contract:
--    client-generated id + idempotency_key; duplicate keys are no-ops).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_capture_breadcrumb(
  p_trip_id uuid,
  p_breadcrumb_id uuid,
  p_latitude double precision,
  p_longitude double precision,
  p_recorded_at timestamptz,
  p_idempotency_key uuid,
  p_accuracy_meters double precision default 0
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trip public.fleet_trips%rowtype;
  v_existing uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_breadcrumb_id is null or p_idempotency_key is null then
    raise exception 'Breadcrumb ID and idempotency key required';
  end if;
  if p_latitude is null or p_latitude < -90 or p_latitude > 90
     or p_longitude is null or p_longitude < -180 or p_longitude > 180 then
    raise exception 'Invalid coordinates';
  end if;

  select * into v_trip from public.fleet_trips where id = p_trip_id;
  if not found then raise exception 'Trip not found'; end if;
  if v_trip.driver_account_id is null or not public.is_driver_account_owner(v_trip.driver_account_id) then
    raise exception 'Assigned driver permission required';
  end if;

  select id into v_existing from public.trip_location_breadcrumbs
  where idempotency_key = p_idempotency_key;
  if v_existing is not null then
    return v_existing;
  end if;

  insert into public.trip_location_breadcrumbs (
    id, trip_id, latitude, longitude, accuracy_meters, recorded_at,
    source, idempotency_key
  ) values (
    p_breadcrumb_id, p_trip_id, p_latitude, p_longitude,
    coalesce(p_accuracy_meters, 0), coalesce(p_recorded_at, now()),
    'DRIVER_PHONE', p_idempotency_key
  )
  on conflict (id) do nothing;
  return p_breadcrumb_id;
end;
$$;
revoke all on function public.easyfleet_capture_breadcrumb(uuid, uuid, double precision, double precision, timestamptz, uuid, double precision) from public;
grant execute on function public.easyfleet_capture_breadcrumb(uuid, uuid, double precision, double precision, timestamptz, uuid, double precision) to authenticated;

-- ---------------------------------------------------------------------------
-- 9. Direct company-driver registration (transporter hires outside the
--    marketplace) with invite/approval flow.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_add_company_driver(
  p_company_id uuid,
  p_driver_account_id uuid,
  p_local_driver_code text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_company_driver uuid;
  v_driver_user uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if not exists (select 1 from public.driver_accounts where id = p_driver_account_id) then
    raise exception 'Driver account not found';
  end if;

  insert into public.company_drivers (company_id, driver_account_id, local_driver_code, created_by)
  values (
    p_company_id, p_driver_account_id,
    coalesce(nullif(trim(p_local_driver_code), ''),
             'DRV-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))),
    auth.uid()
  )
  on conflict (company_id, driver_account_id) do update set
    local_driver_code = public.company_drivers.local_driver_code
  returning id into v_company_driver;

  insert into public.driver_memberships (
    company_id, driver_account_id, company_driver_id, status,
    invited_by, approved_by, approved_at, joined_at
  ) values (
    p_company_id, p_driver_account_id, v_company_driver, 'APPROVED',
    auth.uid(), auth.uid(), now(), now()
  )
  on conflict (company_id, driver_account_id) do update set
    status = 'APPROVED', approved_by = auth.uid(), approved_at = now(),
    joined_at = coalesce(public.driver_memberships.joined_at, now()),
    left_at = null, updated_at = now();

  select da.auth_user_id into v_driver_user
  from public.driver_accounts da where da.id = p_driver_account_id;
  perform public.easyfleet_notify(
    v_driver_user, 'COMPANY_MEMBERSHIP', 'Added to a company',
    'A transporter added you as a company driver.', p_company_id,
    jsonb_build_object('company_id', p_company_id)
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'COMPANY_DRIVER', v_company_driver, 'COMPANY_DRIVER_ADDED',
    gen_random_uuid(), jsonb_build_object('driver_account_id', p_driver_account_id)
  );
  return v_company_driver;
end;
$$;
revoke all on function public.easyfleet_add_company_driver(uuid, uuid, text) from public;
grant execute on function public.easyfleet_add_company_driver(uuid, uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 10. Realtime for audit events (RLS still applies per subscriber).
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.fleet_audit_events;
  exception when duplicate_object then null;
  end;
end $$;

commit;
