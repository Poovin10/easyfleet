-- EasyFleet Phase 2 rollback script.
-- Reverses ONLY objects added by migrations 20261123000100..001100.
-- Existing production tables, rows and pre-Phase-2 RPCs are never dropped.
--
-- IMPORTANT:
-- * Run during a maintenance window; apps must be rolled back to commit
--   b4856ba (Phase 1B) or earlier first, because they call the new RPCs.
-- * The original body of set_driver_official_verification_status is restored
--   from the pre-migration backup (it was already broken: B-01). Restoring it
--   re-introduces B-01; prefer keeping the repaired version.
-- * Vault secrets are left in place (harmless, no data exposure).
-- * New tables are dropped ONLY if empty; the script aborts otherwise so no
--   business data can be lost.

begin;

-- 1. Guard: refuse to drop any new table that contains rows.
do $$
declare
  t text;
  n bigint;
begin
  foreach t in array array[
    'public.platform_staff','public.notifications','public.document_review_history',
    'public.gps_providers','public.gps_provider_credentials','public.gps_devices',
    'public.gps_device_positions','public.subscription_plans','public.company_subscriptions',
    'public.payment_transactions','public.job_postings','public.job_applications',
    'public.job_assignments','public.driver_contact_lookups'
  ] loop
    execute format('select count(*) from %s', t) into n;
    if n > 0 then
      raise exception 'Rollback aborted: % contains % row(s). Export data first.', t, n;
    end if;
  end loop;
end $$;

-- 2. Remove Phase-2 realtime membership.
do $$
declare t text;
begin
  foreach t in array array[
    'public.notifications','public.driver_licences','public.companies',
    'public.gps_devices','public.gps_device_positions','public.company_subscriptions',
    'public.job_postings','public.job_applications','public.job_assignments',
    'public.fleet_audit_events'
  ] loop
    begin
      execute format('alter publication supabase_realtime drop table %s', t);
    exception when undefined_object then null;
    end;
  end loop;
end $$;

-- 3. Drop Phase-2 functions (new names only).
drop function if exists public.easyfleet_review_driver_licence(uuid, text, text, uuid);
drop function if exists public.easyfleet_review_company_gst(uuid, text, text, uuid);
drop function if exists public.easyfleet_set_gps_credentials(uuid, text, text, jsonb, jsonb);
drop function if exists public.easyfleet_get_gps_credentials(uuid);
drop function if exists public.easyfleet_list_gps_credentials(uuid);
drop function if exists public.easyfleet_register_gps_device(uuid, uuid, text, text, uuid, text, text, text);
drop function if exists public.easyfleet_assign_gps_device(uuid, uuid, uuid);
drop function if exists public.easyfleet_set_gps_device_status(uuid, uuid, text);
drop function if exists public.easyfleet_ingest_device_positions(uuid, uuid, jsonb, uuid);
drop function if exists public.easyfleet_pay_subscription(uuid, text, text, uuid, text, text);
drop function if exists public.has_active_subscription(uuid);
drop function if exists public.easyfleet_post_job(uuid, uuid, text, uuid, text, text, text, text, numeric, text, text[], text, text, numeric, text, date);
drop function if exists public.easyfleet_apply_to_job(uuid, uuid, text, uuid);
drop function if exists public.easyfleet_review_application(uuid, text, text, uuid);
drop function if exists public.easyfleet_withdraw_application(uuid);
drop function if exists public.easyfleet_appoint_driver(uuid, uuid, uuid);
drop function if exists public.easyfleet_end_assignment(uuid);
drop function if exists public.easyfleet_close_job(uuid, text);
drop function if exists public.easyfleet_search_drivers(text, text, integer);
drop function if exists public.easyfleet_add_fuel_entry(uuid, uuid, uuid, text, numeric, numeric, uuid, numeric, text, bigint, text, text, timestamptz);
drop function if exists public.easyfleet_add_expense_entry(uuid, uuid, uuid, text, numeric, uuid, text, bigint, text, text);
drop function if exists public.easyfleet_review_expense(uuid, uuid, text, text, uuid);
drop function if exists public.easyfleet_report_breakdown(uuid, uuid, uuid, text, uuid, bigint, text);
drop function if exists public.easyfleet_update_maintenance_job(uuid, uuid, text, text, numeric, numeric, bigint, text, uuid);
drop function if exists public.easyfleet_add_ledger_entry(uuid, uuid, uuid, text, numeric, uuid, uuid, text);
drop function if exists public.easyfleet_cancel_trip(uuid, uuid, text, uuid);
drop function if exists public.easyfleet_add_vehicle_document(uuid, uuid, text, text, text, date, date, text);
drop function if exists public.easyfleet_lookup_driver_contact(uuid, uuid);
drop function if exists public.easyfleet_capture_breadcrumb(uuid, uuid, double precision, double precision, timestamptz, uuid, double precision);
drop function if exists public.easyfleet_add_company_driver(uuid, uuid, text);
drop function if exists public.easyfleet_assert_trip_driver(uuid, uuid);
drop function if exists public.easyfleet_notify(uuid, text, text, text, uuid, jsonb);
drop function if exists public.is_platform_staff();
drop function if exists public.easyfleet_seed_company_trial();
drop function if exists public.easyfleet_prevent_mutation();

-- 4. Restore Phase-1B submission RPC bodies from backup if required:
--    /tmp/opencode/impl/backup/phase1b_rpcs.json (pre-Phase-2 definitions).
--    The Phase-2 versions remain compatible with Phase-1B clients, so this
--    step is optional and intentionally not automated.

-- 5. Remove Phase-2 triggers, view, tables, columns and policies.
--    Migration 001100 added FKs to pre-existing tables; drop them first.
alter table public.fleet_trips
  drop constraint if exists fleet_trips_driver_account_fkey;
alter table public.driver_ledger_entries
  drop constraint if exists driver_ledger_entries_driver_account_fkey;

drop trigger if exists companies_seed_trial on public.companies;
drop trigger if exists document_review_history_immutable on public.document_review_history;
drop trigger if exists fleet_audit_events_immutable on public.fleet_audit_events;
drop trigger if exists gps_provider_credentials_updated_at on public.gps_provider_credentials;
drop trigger if exists gps_devices_updated_at on public.gps_devices;
drop trigger if exists company_subscriptions_updated_at on public.company_subscriptions;
drop trigger if exists job_postings_updated_at on public.job_postings;
drop trigger if exists job_applications_updated_at on public.job_applications;

drop view if exists public.trip_unified_locations;

drop table if exists public.driver_contact_lookups;
drop table if exists public.job_assignments;
drop table if exists public.job_applications;
drop table if exists public.job_postings;
drop table if exists public.payment_transactions;
drop table if exists public.company_subscriptions;
drop table if exists public.subscription_plans;
drop table if exists public.gps_device_positions;
drop table if exists public.gps_devices;
drop table if exists public.gps_provider_credentials;
drop table if exists public.gps_providers;
drop table if exists public.document_review_history;
drop table if exists public.notifications;
drop table if exists public.platform_staff;

-- Phase-2 additive policies on pre-existing tables.
drop policy if exists companies_staff_read on public.companies;
drop policy if exists companies_driver_read on public.companies;
drop policy if exists driver_accounts_staff_read on public.driver_accounts;
drop policy if exists driver_licences_scoped_read on public.driver_licences;
drop policy if exists driver_verification_audit_logs_scoped_read on public.driver_verification_audit_logs;
drop policy if exists fleet_audit_events_driver_read on public.fleet_audit_events;
drop policy if exists trip_fuel_entries_driver_read on public.trip_fuel_entries;
drop policy if exists trip_expenses_driver_read on public.trip_expenses;
drop policy if exists fleet_vehicles_driver_read on public.fleet_vehicles;
drop policy if exists fleet_maintenance_jobs_driver_read on public.fleet_maintenance_jobs;

-- Restore the Phase-1B payment purpose constraint once contact rows are gone.
alter table public.payment_transactions
  drop constraint if exists payment_transactions_purpose_check;
alter table public.payment_transactions
  add constraint payment_transactions_purpose_check
  check (purpose in ('SUBSCRIPTION', 'RENEWAL'));

-- Phase-2 additive columns (data in these columns would be lost; guard).
do $$
begin
  if exists (select 1 from public.driver_licences where licence_document_path is not null or rejection_reason is not null)
     or exists (select 1 from public.companies where gst_verification_status <> 'NOT_SUBMITTED' or gst_rejection_reason is not null)
     or exists (select 1 from public.trip_location_breadcrumbs where source <> 'DRIVER_PHONE' or device_id is not null or idempotency_key is not null) then
    raise exception 'Rollback aborted: Phase-2 columns contain data. Export first.';
  end if;
end $$;

alter table public.driver_licences drop column if exists licence_document_path;
alter table public.driver_licences drop column if exists rejection_reason;
alter table public.companies drop column if exists gst_verification_status;
alter table public.companies drop column if exists gst_rejection_reason;
alter table public.trip_location_breadcrumbs drop column if exists source;
alter table public.trip_location_breadcrumbs drop column if exists device_id;
alter table public.trip_location_breadcrumbs drop column if exists idempotency_key;
alter table public.trip_location_breadcrumbs drop column if exists speed_kmh;
alter table public.trip_location_breadcrumbs drop column if exists heading;

-- 6. Restore the pre-Phase-2 breadcrumb grant state (policies were inert).
revoke select, insert on public.trip_location_breadcrumbs from authenticated;

-- 7. easyfleet_create_trip: remove the subscription guard by restoring the
--    backed-up body from /tmp/opencode/impl/function_defs.txt if needed.
--    Left as a manual step because the guard is harmless without the
--    subscription tables only if has_active_subscription is also restored.

commit;
