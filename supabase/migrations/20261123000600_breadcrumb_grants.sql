-- EasyFleet Phase 2 migration 6: repair inert breadcrumb policies.
-- trip_location_breadcrumbs had RLS policies but no table grants for
-- authenticated, so native/Flutter breadcrumb reads and writes were denied
-- with 42501. Row scope remains enforced by the existing policies.

begin;
grant select, insert on public.trip_location_breadcrumbs to authenticated;
commit;
