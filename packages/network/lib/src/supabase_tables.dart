/// Table names that exist in the live EasyFleet Supabase backend.
abstract final class Tables {
  static const companies = 'companies';
  static const companyMemberships = 'company_memberships';
  static const driverAccounts = 'driver_accounts';
  static const driverLicences = 'driver_licences';
  static const companyDrivers = 'company_drivers';
  static const driverMemberships = 'driver_memberships';
  static const fleetTrips = 'fleet_trips';
  static const fleetVehicles = 'fleet_vehicles';
  static const vehicleDocuments = 'fleet_vehicle_documents';
  static const fleetAuditEvents = 'fleet_audit_events';
  static const tripLocationBreadcrumbs = 'trip_location_breadcrumbs';
  static const tripUnifiedLocations = 'trip_unified_locations';
  static const tripClosures = 'trip_closures';
  static const tripFuelEntries = 'trip_fuel_entries';
  static const tripExpenses = 'trip_expenses';
  static const driverLedgerEntries = 'driver_ledger_entries';
  static const fleetMaintenanceJobs = 'fleet_maintenance_jobs';
  static const documentReviewHistory = 'document_review_history';
  static const notifications = 'notifications';
  static const subscriptionPlans = 'subscription_plans';
  static const companySubscriptions = 'company_subscriptions';
  static const paymentTransactions = 'payment_transactions';
  static const gpsProviders = 'gps_providers';
  static const gpsDevices = 'gps_devices';
  static const gpsDevicePositions = 'gps_device_positions';
  static const jobPostings = 'job_postings';
  static const jobApplications = 'job_applications';
  static const jobAssignments = 'job_assignments';
  static const driverContactLookups = 'driver_contact_lookups';
}

/// RPC names that exist in the live public schema.
abstract final class RpcNames {
  static const createDriverAccount = 'easyfleet_create_driver_account';
  static const createCompany = 'easyfleet_create_company';
  static const createVehicle = 'easyfleet_create_vehicle';
  static const addVehicleDocument = 'easyfleet_add_vehicle_document';
  static const createTrip = 'easyfleet_create_trip';
  static const startTrip = 'easyfleet_start_trip';
  static const cancelTrip = 'easyfleet_cancel_trip';
  static const submitTripClosure = 'easyfleet_submit_trip_closure';
  static const reviewTripClosure = 'easyfleet_review_trip_closure';
  static const writeAuditEvent = 'easyfleet_write_audit_event';
  static const submitDriverLicence = 'easyfleet_submit_driver_licence';
  static const submitCompanyGst = 'easyfleet_submit_company_gst';
  static const reviewDriverLicence = 'easyfleet_review_driver_licence';
  static const reviewCompanyGst = 'easyfleet_review_company_gst';
  static const setDriverOfficialVerificationStatus =
      'set_driver_official_verification_status';
  static const addFuelEntry = 'easyfleet_add_fuel_entry';
  static const addExpenseEntry = 'easyfleet_add_expense_entry';
  static const reviewExpense = 'easyfleet_review_expense';
  static const reportBreakdown = 'easyfleet_report_breakdown';
  static const updateMaintenanceJob = 'easyfleet_update_maintenance_job';
  static const addLedgerEntry = 'easyfleet_add_ledger_entry';
  static const addCompanyDriver = 'easyfleet_add_company_driver';
  static const addManualCompanyDriver = 'easyfleet_add_manual_company_driver';
  static const captureBreadcrumb = 'easyfleet_capture_breadcrumb';
  static const paySubscription = 'easyfleet_pay_subscription';
  static const postJob = 'easyfleet_post_job';
  static const applyToJob = 'easyfleet_apply_to_job';
  static const reviewApplication = 'easyfleet_review_application';
  static const withdrawApplication = 'easyfleet_withdraw_application';
  static const appointDriver = 'easyfleet_appoint_driver';
  static const endAssignment = 'easyfleet_end_assignment';
  static const closeJob = 'easyfleet_close_job';
  static const searchDrivers = 'easyfleet_search_drivers';
  static const setGpsCredentials = 'easyfleet_set_gps_credentials';
  static const getGpsCredentials = 'easyfleet_get_gps_credentials';
  static const listGpsCredentials = 'easyfleet_list_gps_credentials';
  static const registerGpsDevice = 'easyfleet_register_gps_device';
  static const assignGpsDevice = 'easyfleet_assign_gps_device';
  static const setGpsDeviceStatus = 'easyfleet_set_gps_device_status';
  static const ingestDevicePositions = 'easyfleet_ingest_device_positions';
  static const lookupDriverContact = 'easyfleet_lookup_driver_contact';
}
