/// Table names that exist in the live EasyFleet Supabase backend.
///
/// The legacy job-marketplace table names were removed in Phase 1B because
/// they do not exist in the remote schema. See
/// `FLUTTER-DATABASE-REFERENCE-AUDIT.md` for the full mapping.
abstract final class Tables {
  static const companies = 'companies';
  static const companyMemberships = 'company_memberships';
  static const driverAccounts = 'driver_accounts';
  static const driverLicences = 'driver_licences';
  static const fleetTrips = 'fleet_trips';
  static const fleetVehicles = 'fleet_vehicles';
  static const fleetAuditEvents = 'fleet_audit_events';
  static const tripLocationBreadcrumbs = 'trip_location_breadcrumbs';
  static const tripClosures = 'trip_closures';
  static const tripFuelEntries = 'trip_fuel_entries';
  static const tripExpenses = 'trip_expenses';
  static const driverLedgerEntries = 'driver_ledger_entries';
  static const fleetMaintenanceJobs = 'fleet_maintenance_jobs';
}
