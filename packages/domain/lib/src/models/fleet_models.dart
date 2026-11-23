import 'parse.dart';

/// Company row from `public.companies`.
class Company {
  const Company({
    required this.id,
    required this.name,
    required this.legalName,
    required this.status,
    required this.gstin,
    required this.gstCertificatePath,
    required this.gstVerificationStatus,
    this.gstRejectionReason,
  });

  factory Company.fromJson(Map<String, dynamic> j) => Company(
    id: strReq(j['id']),
    name: strReq(j['name']),
    legalName: strReq(j['legal_name']),
    status: strReq(j['status'], 'ACTIVE'),
    gstin: strReq(j['gstin']),
    gstCertificatePath: strReq(j['gst_certificate_path']),
    gstVerificationStatus: strReq(
      j['gst_verification_status'],
      'NOT_SUBMITTED',
    ),
    gstRejectionReason: str(j['gst_rejection_reason']),
  );

  final String id;
  final String name;
  final String legalName;
  final String status;
  final String gstin;
  final String gstCertificatePath;
  final String gstVerificationStatus;
  final String? gstRejectionReason;

  bool get gstSubmitted => gstCertificatePath.isNotEmpty;
}

/// Row from `public.company_memberships`, optionally joined with company name.
class CompanyMembership {
  const CompanyMembership({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.role,
    required this.status,
    this.companyName,
  });

  factory CompanyMembership.fromJson(Map<String, dynamic> j) =>
      CompanyMembership(
        id: strReq(j['id']),
        companyId: strReq(j['company_id']),
        userId: strReq(j['user_id']),
        role: strReq(j['role']),
        status: strReq(j['status'], 'PENDING'),
        companyName: str(j['companies'] is Map ? j['companies']['name'] : null),
      );

  final String id;
  final String companyId;
  final String userId;
  final String role;
  final String status;
  final String? companyName;

  bool get isActive => status == 'ACTIVE';
  bool get isManager => role == 'OWNER' || role == 'ADMIN';
  bool get isOperator => isManager || role == 'DISPATCHER';
}

/// Row from `public.driver_accounts`.
class DriverAccount {
  const DriverAccount({
    required this.id,
    required this.authUserId,
    required this.displayName,
    this.phoneE164,
    required this.identityStatus,
  });

  factory DriverAccount.fromJson(Map<String, dynamic> j) => DriverAccount(
    id: strReq(j['id']),
    authUserId: strReq(j['auth_user_id']),
    displayName: strReq(j['display_name']),
    phoneE164: str(j['phone_e164']),
    identityStatus: strReq(j['identity_status'], 'PENDING'),
  );

  final String id;
  final String authUserId;
  final String displayName;
  final String? phoneE164;
  final String identityStatus;
}

/// Row from `public.driver_licences`.
class DriverLicence {
  const DriverLicence({
    required this.id,
    required this.driverAccountId,
    this.licenceClass,
    this.issuingState,
    this.validFrom,
    this.validUntil,
    required this.verificationStatus,
    this.verificationSource,
    this.rejectionReason,
    this.licenceDocumentPath,
    this.verifiedAt,
  });

  factory DriverLicence.fromJson(Map<String, dynamic> j) => DriverLicence(
    id: strReq(j['id']),
    driverAccountId: strReq(j['driver_account_id']),
    licenceClass: str(j['licence_class']),
    issuingState: str(j['issuing_state']),
    validFrom: dateOnly(j['valid_from']),
    validUntil: dateOnly(j['valid_until']),
    verificationStatus: strReq(j['verification_status'], 'PENDING'),
    verificationSource: str(j['verification_source']),
    rejectionReason: str(j['rejection_reason']),
    licenceDocumentPath: str(j['licence_document_path']),
    verifiedAt: dt(j['verified_at']),
  );

  final String id;
  final String driverAccountId;
  final String? licenceClass;
  final String? issuingState;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String verificationStatus;
  final String? verificationSource;
  final String? rejectionReason;
  final String? licenceDocumentPath;
  final DateTime? verifiedAt;

  bool get isVerified => verificationStatus == 'VERIFIED';
}

/// Row from `public.company_drivers`, optionally joined with driver name.
class CompanyDriver {
  const CompanyDriver({
    required this.id,
    required this.companyId,
    required this.driverAccountId,
    required this.localDriverCode,
    required this.employmentRole,
    this.displayName,
    this.membershipStatus,
  });

  factory CompanyDriver.fromJson(Map<String, dynamic> j) => CompanyDriver(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    driverAccountId: strReq(j['driver_account_id']),
    localDriverCode: strReq(j['local_driver_code']),
    employmentRole: strReq(j['employment_role'], 'DRIVER'),
    displayName: str(
      j['driver_accounts'] is Map ? j['driver_accounts']['display_name'] : null,
    ),
    membershipStatus: str(j['membership_status']),
  );

  final String id;
  final String companyId;
  final String driverAccountId;
  final String localDriverCode;
  final String employmentRole;
  final String? displayName;
  final String? membershipStatus;
}

/// Row from `public.driver_memberships`.
class DriverMembership {
  const DriverMembership({
    required this.id,
    required this.companyId,
    required this.driverAccountId,
    this.companyDriverId,
    required this.status,
    this.joinedAt,
    this.companyName,
  });

  factory DriverMembership.fromJson(Map<String, dynamic> j) => DriverMembership(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    driverAccountId: strReq(j['driver_account_id']),
    companyDriverId: str(j['company_driver_id']),
    status: strReq(j['status'], 'INVITED'),
    joinedAt: dt(j['joined_at']),
    companyName: str(j['companies'] is Map ? j['companies']['name'] : null),
  );

  final String id;
  final String companyId;
  final String driverAccountId;
  final String? companyDriverId;
  final String status;
  final DateTime? joinedAt;
  final String? companyName;

  bool get isApproved => status == 'APPROVED';
}

/// Row from `public.fleet_vehicles`.
class FleetVehicle {
  const FleetVehicle({
    required this.id,
    required this.companyId,
    required this.registrationNumber,
    required this.vehicleType,
    this.make,
    this.model,
    this.manufacturingYear,
    this.capacityTonnes,
    this.odometerKm,
    required this.status,
    this.notes,
  });

  factory FleetVehicle.fromJson(Map<String, dynamic> j) => FleetVehicle(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    registrationNumber: strReq(j['registration_number']),
    vehicleType: strReq(j['vehicle_type'], 'TRUCK'),
    make: str(j['make']),
    model: str(j['model']),
    manufacturingYear: integer(j['manufacturing_year']),
    capacityTonnes: dbl(j['capacity_tonnes']),
    odometerKm: integer(j['odometer_km']),
    status: strReq(j['status'], 'AVAILABLE'),
    notes: str(j['notes']),
  );

  final String id;
  final String companyId;
  final String registrationNumber;
  final String vehicleType;
  final String? make;
  final String? model;
  final int? manufacturingYear;
  final double? capacityTonnes;
  final int? odometerKm;
  final String status;
  final String? notes;
}

/// Row from `public.fleet_trips` with optional joined labels.
class FleetTrip {
  const FleetTrip({
    required this.id,
    required this.companyId,
    this.gcNumber,
    required this.origin,
    required this.destination,
    this.scheduledDate,
    this.vehicleId,
    this.companyDriverId,
    this.driverAccountId,
    this.material,
    this.tonnes,
    this.freightRate,
    required this.bataAdvance,
    this.plannedDistanceKm,
    this.startingOdometerKm,
    required this.status,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.vehicleNumber,
    this.driverName,
    this.companyName,
  });

  factory FleetTrip.fromJson(Map<String, dynamic> j) => FleetTrip(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    gcNumber: str(j['gc_number']),
    origin: strReq(j['origin']),
    destination: strReq(j['destination']),
    scheduledDate: dateOnly(j['scheduled_date']),
    vehicleId: str(j['vehicle_id']),
    companyDriverId: str(j['company_driver_id']),
    driverAccountId: str(j['driver_account_id']),
    material: str(j['material']),
    tonnes: dbl(j['tonnes']),
    freightRate: dbl(j['freight_rate']),
    bataAdvance: dbl(j['bata_advance']) ?? 0,
    plannedDistanceKm: dbl(j['planned_distance_km']),
    startingOdometerKm: integer(j['starting_odometer_km']),
    status: strReq(j['status'], 'PLANNED'),
    assignedAt: dt(j['assigned_at']),
    startedAt: dt(j['started_at']),
    completedAt: dt(j['completed_at']),
    cancelledAt: dt(j['cancelled_at']),
    cancellationReason: str(j['cancellation_reason']),
    vehicleNumber: str(
      j['fleet_vehicles'] is Map
          ? j['fleet_vehicles']['registration_number']
          : null,
    ),
    driverName: str(
      j['driver_accounts'] is Map ? j['driver_accounts']['display_name'] : null,
    ),
    companyName: str(j['companies'] is Map ? j['companies']['name'] : null),
  );

  final String id;
  final String companyId;
  final String? gcNumber;
  final String origin;
  final String destination;
  final DateTime? scheduledDate;
  final String? vehicleId;
  final String? companyDriverId;
  final String? driverAccountId;
  final String? material;
  final double? tonnes;
  final double? freightRate;
  final double bataAdvance;
  final double? plannedDistanceKm;
  final int? startingOdometerKm;
  final String status;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? vehicleNumber;
  final String? driverName;
  final String? companyName;

  bool get isActive =>
      status == 'ASSIGNED' ||
      status == 'IN_TRANSIT' ||
      status == 'CLOSURE_PENDING';
  bool get isAssigned => status == 'ASSIGNED';
  bool get isInTransit => status == 'IN_TRANSIT';
  bool get isClosurePending => status == 'CLOSURE_PENDING';
  bool get isCompleted => status == 'COMPLETED';
}

/// Row from `public.trip_closures`.
class TripClosure {
  const TripClosure({
    required this.id,
    required this.companyId,
    required this.tripId,
    required this.submissionNumber,
    required this.status,
    this.startingOdometerKm,
    this.closingOdometerKm,
    this.actualDistanceKm,
    required this.bataEarned,
    required this.bataAdvance,
    required this.deliveryConfirmed,
    this.podObjectPath,
    this.closureNotes,
    this.submittedAt,
    this.reviewedAt,
    this.reviewerNote,
  });

  factory TripClosure.fromJson(Map<String, dynamic> j) => TripClosure(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    tripId: strReq(j['trip_id']),
    submissionNumber: integer(j['submission_number']) ?? 1,
    status: strReq(j['status'], 'SUBMITTED'),
    startingOdometerKm: integer(j['starting_odometer_km']),
    closingOdometerKm: integer(j['closing_odometer_km']),
    actualDistanceKm: dbl(j['actual_distance_km']),
    bataEarned: dbl(j['bata_earned']) ?? 0,
    bataAdvance: dbl(j['bata_advance']) ?? 0,
    deliveryConfirmed: boolean(j['delivery_confirmed']),
    podObjectPath: str(j['pod_object_path']),
    closureNotes: str(j['closure_notes']),
    submittedAt: dt(j['submitted_at']),
    reviewedAt: dt(j['reviewed_at']),
    reviewerNote: str(j['reviewer_note']),
  );

  final String id;
  final String companyId;
  final String tripId;
  final int submissionNumber;
  final String status;
  final int? startingOdometerKm;
  final int? closingOdometerKm;
  final double? actualDistanceKm;
  final double bataEarned;
  final double bataAdvance;
  final bool deliveryConfirmed;
  final String? podObjectPath;
  final String? closureNotes;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerNote;
}

/// Row from `public.trip_fuel_entries`.
class FuelEntry {
  const FuelEntry({
    required this.id,
    required this.tripId,
    required this.fuelType,
    required this.litres,
    required this.amount,
    this.ratePerLitre,
    this.pumpName,
    this.odometerKm,
    this.entryTime,
  });

  factory FuelEntry.fromJson(Map<String, dynamic> j) => FuelEntry(
    id: strReq(j['id']),
    tripId: strReq(j['trip_id']),
    fuelType: strReq(j['fuel_type'], 'DIESEL'),
    litres: dbl(j['litres']) ?? 0,
    amount: dbl(j['amount']) ?? 0,
    ratePerLitre: dbl(j['rate_per_litre']),
    pumpName: str(j['pump_name']),
    odometerKm: integer(j['odometer_km']),
    entryTime: dt(j['entry_time']),
  );

  final String id;
  final String tripId;
  final String fuelType;
  final double litres;
  final double amount;
  final double? ratePerLitre;
  final String? pumpName;
  final int? odometerKm;
  final DateTime? entryTime;
}

/// Row from `public.trip_expenses`.
class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    required this.companyId,
    this.description,
    this.odometerKm,
    this.receiptObjectPath,
    required this.approvalStatus,
    this.reviewerNote,
    this.createdAt,
  });

  factory ExpenseEntry.fromJson(Map<String, dynamic> j) => ExpenseEntry(
    id: strReq(j['id']),
    tripId: strReq(j['trip_id']),
    category: strReq(j['category']),
    amount: dbl(j['amount']) ?? 0,
    companyId: strReq(j['company_id']),
    description: str(j['description']),
    odometerKm: integer(j['odometer_km']),
    receiptObjectPath: str(j['receipt_object_path']),
    approvalStatus: strReq(j['approval_status'], 'PENDING'),
    reviewerNote: str(j['reviewer_note']),
    createdAt: dt(j['created_at']),
  );

  final String id;
  final String tripId;
  final String category;
  final double amount;
  final String companyId;
  final String? description;
  final int? odometerKm;
  final String? receiptObjectPath;
  final String approvalStatus;
  final String? reviewerNote;
  final DateTime? createdAt;
}

/// Row from `public.fleet_maintenance_jobs`.
class MaintenanceJob {
  const MaintenanceJob({
    required this.id,
    required this.companyId,
    required this.vehicleId,
    required this.issueDescription,
    required this.status,
    this.odometerKm,
    this.workshopName,
    this.estimatedCost,
    this.serviceBillAmount,
    this.reportedAt,
    this.vehicleNumber,
  });

  factory MaintenanceJob.fromJson(Map<String, dynamic> j) => MaintenanceJob(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    vehicleId: strReq(j['vehicle_id']),
    issueDescription: strReq(j['issue_description']),
    status: strReq(j['status'], 'REPORTED'),
    odometerKm: integer(j['odometer_km']),
    workshopName: str(j['workshop_name']),
    estimatedCost: dbl(j['estimated_cost']),
    serviceBillAmount: dbl(j['service_bill_amount']),
    reportedAt: dt(j['reported_at']),
    vehicleNumber: str(
      j['fleet_vehicles'] is Map
          ? j['fleet_vehicles']['registration_number']
          : null,
    ),
  );

  final String id;
  final String companyId;
  final String vehicleId;
  final String issueDescription;
  final String status;
  final int? odometerKm;
  final String? workshopName;
  final double? estimatedCost;
  final double? serviceBillAmount;
  final DateTime? reportedAt;
  final String? vehicleNumber;
}

/// Row from `public.driver_ledger_entries`.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.companyId,
    required this.driverAccountId,
    this.tripId,
    required this.entryType,
    required this.amount,
    this.description,
    required this.approvalStatus,
    this.createdAt,
    this.driverName,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    driverAccountId: strReq(j['driver_account_id']),
    tripId: str(j['trip_id']),
    entryType: strReq(j['entry_type']),
    amount: dbl(j['amount']) ?? 0,
    description: str(j['description']),
    approvalStatus: strReq(j['approval_status'], 'PENDING'),
    createdAt: dt(j['created_at']),
    driverName: str(
      j['driver_accounts'] is Map ? j['driver_accounts']['display_name'] : null,
    ),
  );

  final String id;
  final String companyId;
  final String driverAccountId;
  final String? tripId;
  final String entryType;
  final double amount;
  final String? description;
  final String approvalStatus;
  final DateTime? createdAt;
  final String? driverName;

  /// Credits increase the driver's balance; debits reduce it.
  bool get isCredit =>
      entryType == 'BATA_EARNED' ||
      entryType == 'PAYMENT' ||
      entryType == 'ADJUSTMENT';
}

/// Row from `public.fleet_audit_events`.
class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.eventType,
    required this.eventTime,
    this.actorUserId,
    this.details = const {},
  });

  factory AuditEvent.fromJson(Map<String, dynamic> j) => AuditEvent(
    id: strReq(j['id']),
    entityType: strReq(j['entity_type']),
    entityId: strReq(j['entity_id']),
    eventType: strReq(j['event_type']),
    eventTime: dtReq(j['event_time']),
    actorUserId: str(j['actor_user_id']),
    details: jsonMap(j['details']),
  );

  final String id;
  final String entityType;
  final String entityId;
  final String eventType;
  final DateTime eventTime;
  final String? actorUserId;
  final Map<String, dynamic> details;
}

/// Row from `public.document_review_history`.
class DocumentReview {
  const DocumentReview({
    required this.id,
    required this.subjectType,
    required this.decision,
    this.reason,
    this.storagePath,
    required this.actedAt,
  });

  factory DocumentReview.fromJson(Map<String, dynamic> j) => DocumentReview(
    id: strReq(j['id']),
    subjectType: strReq(j['subject_type']),
    decision: strReq(j['decision']),
    reason: str(j['reason']),
    storagePath: str(j['storage_path']),
    actedAt: dtReq(j['acted_at']),
  );

  final String id;
  final String subjectType;
  final String decision;
  final String? reason;
  final String? storagePath;
  final DateTime actedAt;
}

/// Row from `public.trip_location_breadcrumbs` / `trip_unified_locations`.
class BreadcrumbPoint {
  const BreadcrumbPoint({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracyMeters,
    this.speedKmh,
    this.heading,
    this.source = 'DRIVER_PHONE',
    this.deviceId,
  });

  factory BreadcrumbPoint.fromJson(Map<String, dynamic> j) => BreadcrumbPoint(
    id: strReq(j['id']),
    tripId: strReq(j['trip_id']),
    latitude: dbl(j['latitude']) ?? 0,
    longitude: dbl(j['longitude']) ?? 0,
    recordedAt: dtReq(j['recorded_at']),
    accuracyMeters: dbl(j['accuracy_meters']),
    speedKmh: dbl(j['speed_kmh']),
    heading: dbl(j['heading']),
    source: strReq(j['source'], 'DRIVER_PHONE'),
    deviceId: str(j['device_id']),
  );

  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracyMeters;
  final double? speedKmh;
  final double? heading;
  final String source;
  final String? deviceId;
}
