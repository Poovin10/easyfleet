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

/// RPC names that exist in the live public schema.
abstract final class RpcNames {
  static const createDriverAccount = 'easyfleet_create_driver_account';
  static const submitDriverLicence = 'easyfleet_submit_driver_licence';
  static const submitCompanyGst = 'easyfleet_submit_company_gst';
  static const createCompany = 'easyfleet_create_company';
  static const createVehicle = 'easyfleet_create_vehicle';
  static const createTrip = 'easyfleet_create_trip';
  static const startTrip = 'easyfleet_start_trip';
  static const submitTripClosure = 'easyfleet_submit_trip_closure';
  static const reviewTripClosure = 'easyfleet_review_trip_closure';
  static const writeAuditEvent = 'easyfleet_write_audit_event';
  static const isCompanyMember = 'is_company_member';
  static const isCompanyManager = 'is_company_manager';
  static const isCompanyOperator = 'is_company_operator';
  static const isApprovedCompanyDriver = 'is_approved_company_driver';
}
