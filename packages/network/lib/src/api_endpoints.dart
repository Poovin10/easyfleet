/// Supabase REST paths and RPC names observed in the existing native EasyFleet apps.
abstract final class ApiEndpoints {
  static const rest = '/rest/v1';
  static const rpc = '/rest/v1/rpc';

  // Auth / account
  static const createDriverAccount = '$rpc/create_driver_account';
  static const getMyDriverAccount = '$rpc/get_my_driver_account';

  // Trips and location
  static const trips = '$rest/trips';
  static const driverTrips = '$rest/driver_trips';
  static const tripLocationBreadcrumbs = '$rest/trip_location_breadcrumbs';
  static const driverLocationBreadcrumbs = '$rest/driver_location_breadcrumbs';
  static const driverJobVacancies = '$rest/driver_job_vacancies';
  static const driverJobApplications = '$rest/driver_job_applications';

  // Driver operations
  static const driverFuelEntries = '$rest/driver_fuel_entries';
  static const driverAdblueEntries = '$rest/driver_adblue_entries';
  static const driverExpenses = '$rest/driver_expenses';
  static const driverPodEntries = '$rest/driver_pod_entries';
  static const driverBreakdownReports = '$rest/driver_breakdown_reports';
  static const driverBankDetails = '$rest/driver_bank_details';
  static const driverEarningsLedger = '$rest/driver_earnings_ledger';

  // Storage
  static const storageObject = '/storage/v1/object';
}

/// RPC names used by both apps.
abstract final class RpcNames {
  static const createDriverAccount = 'create_driver_account';
  static const getMyDriverAccount = 'get_my_driver_account';
  static const captureDriverLocation = 'capture_driver_location';
  static const getDriverCurrentTrip = 'get_driver_current_trip';
  static const getDriverHistory = 'get_driver_history';
}
