/// Supabase REST paths that correspond to the live EasyFleet schema.
abstract final class ApiEndpoints {
  static const rest = '/rest/v1';
  static const rpc = '$rest/rpc';

  // Identity and onboarding.
  static const driverAccounts = '$rest/driver_accounts';
  static const driverLicences = '$rest/driver_licences';
  static const createDriverAccount = '$rpc/easyfleet_create_driver_account';
  static const submitDriverLicence = '$rpc/easyfleet_submit_driver_licence';
  static const submitCompanyGst = '$rpc/easyfleet_submit_company_gst';

  // Company and fleet operations.
  static const companies = '$rest/companies';
  static const companyMemberships = '$rest/company_memberships';
  static const fleetVehicles = '$rest/fleet_vehicles';
  static const fleetTrips = '$rest/fleet_trips';

  // Trip operations.
  static const tripLocationBreadcrumbs = '$rest/trip_location_breadcrumbs';
  static const tripFuelEntries = '$rest/trip_fuel_entries';
  static const tripExpenses = '$rest/trip_expenses';
  static const tripClosures = '$rest/trip_closures';
  static const fleetAuditEvents = '$rest/fleet_audit_events';
  static const driverLedgerEntries = '$rest/driver_ledger_entries';
  static const fleetMaintenanceJobs = '$rest/fleet_maintenance_jobs';
}
