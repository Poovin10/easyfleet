-- EasyFleet Phase 2 migration 11: restore PostgREST embedded relationships.
--
-- The mobile clients embed driver_accounts(display_name) when reading
-- fleet_trips and driver_ledger_entries. Those tables only had a composite
-- foreign key to company_drivers(id, company_id, driver_account_id), which
-- PostgREST cannot use to infer a direct trips/ledger -> driver_accounts
-- relationship. It responded with:
--   "could not find a relationship between 'fleet_trips' and
--    'driver_accounts' in the schema cache"
-- Add explicit single-column foreign keys (mirroring the existing one on
-- company_drivers.driver_account_id) so the embedded selects resolve again.
-- No data, columns, grants or functions change.

begin;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.fleet_trips'::regclass
      and conname = 'fleet_trips_driver_account_fkey'
  ) then
    alter table public.fleet_trips
      add constraint fleet_trips_driver_account_fkey
      foreign key (driver_account_id) references public.driver_accounts(id)
      on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.driver_ledger_entries'::regclass
      and conname = 'driver_ledger_entries_driver_account_fkey'
  ) then
    alter table public.driver_ledger_entries
      add constraint driver_ledger_entries_driver_account_fkey
      foreign key (driver_account_id) references public.driver_accounts(id)
      on delete restrict;
  end if;
end $$;

-- Ask PostgREST to refresh its cached schema immediately.
notify pgrst, 'reload schema';

commit;
