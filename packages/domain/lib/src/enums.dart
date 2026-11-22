/// Driver licence classes used by the job market filters.
enum LicenseClass { lmv, mmv, hmv, hmvPlus, tractorTrailer, hazardousGoods }

/// Vehicle categories a driver can declare experience in.
enum VehicleCategory {
  bulker,
  oilTanker,
  openTruck,
  trailer,
  lmcCab,
  container,
  tipper,
  flatbed,
}

/// Manual document approval state for DL and GST onboarding.
enum VerificationStatus { notSubmitted, pending, approved, rejected }

enum JobStatus { open, closed, filled, cancelled }

enum ApplicationStatus { applied, shortlisted, appointed, rejected, withdrawn }

enum AssignmentStatus { active, paused, ended }

enum GpsDeviceStatus { unbound, active, offline, faulty }

/// Trip lifecycle stages. Each transition appends a row to `trip_events`.
enum TripStage {
  assigned,
  reporting,
  loading,
  transit,
  unloading,
  podPending,
  completed,
  cancelled,
}
