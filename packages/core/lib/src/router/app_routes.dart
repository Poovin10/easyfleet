/// Route names shared by Driver and Transporter.
///
/// App-specific routes are defined in each app's router using these as a base.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const alerts = '/alerts';

  // Core marketplace loop (both apps)
  static const driverProfile = '/profile/dl';
  static const companyProfile = '/profile/gst';
  static const jobs = '/jobs';
  static const jobDetail = '/jobs/:jobId';
  static const myApplications = '/applications';
  static const candidates = '/candidates';
  static const assignments = '/assignments';
  static const gpsDevices = '/gps-devices';

  // Driver
  static const trips = '/trips';
  static const tripDetail = '/trips/:tripId';
  static const logbook = '/logbook';
  static const liveTracking = '/live-tracking';
  static const inspections = '/inspections';
  static const loadingReceipts = '/loading-receipts';
  static const unloadTrips = '/unload-trips';
  static const fuel = '/fuel';
  static const wallet = '/wallet';
  static const payouts = '/payouts';

  // Transporter
  static const fleetMap = '/fleet-map';
  static const vehicles = '/vehicles';
  static const vehicleStatus = '/vehicle-status';
  static const parties = '/parties';
  static const accounting = '/accounting';
  static const onboardingApprovals = '/onboarding-approvals';
  static const recruitment = '/recruitment';
}
