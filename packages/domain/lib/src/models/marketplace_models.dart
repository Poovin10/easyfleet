import 'parse.dart';

/// Row from `public.job_postings`.
class JobPosting {
  const JobPosting({
    required this.id,
    required this.companyId,
    required this.title,
    this.description,
    this.origin,
    this.destination,
    this.material,
    this.tonnes,
    this.vehicleType,
    this.requiredLicenceClasses = const [],
    this.city,
    this.state,
    this.rateAmount,
    this.rateUnit,
    this.scheduledDate,
    required this.status,
    this.createdAt,
    this.companyName,
  });

  factory JobPosting.fromJson(Map<String, dynamic> j) => JobPosting(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    title: strReq(j['title']),
    description: str(j['description']),
    origin: str(j['origin']),
    destination: str(j['destination']),
    material: str(j['material']),
    tonnes: dbl(j['tonnes']),
    vehicleType: str(j['vehicle_type']),
    requiredLicenceClasses: strList(j['required_licence_classes']),
    city: str(j['city']),
    state: str(j['state']),
    rateAmount: dbl(j['rate_amount']),
    rateUnit: str(j['rate_unit']),
    scheduledDate: dateOnly(j['scheduled_date']),
    status: strReq(j['status'], 'OPEN'),
    createdAt: dt(j['created_at']),
    companyName: str(j['companies'] is Map ? j['companies']['name'] : null),
  );

  final String id;
  final String companyId;
  final String title;
  final String? description;
  final String? origin;
  final String? destination;
  final String? material;
  final double? tonnes;
  final String? vehicleType;
  final List<String> requiredLicenceClasses;
  final String? city;
  final String? state;
  final double? rateAmount;
  final String? rateUnit;
  final DateTime? scheduledDate;
  final String status;
  final DateTime? createdAt;
  final String? companyName;

  bool get isOpen => status == 'OPEN';
}

/// Row from `public.job_applications`.
class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.driverAccountId,
    required this.applicantUserId,
    this.coverNote,
    required this.status,
    this.reviewNote,
    this.createdAt,
    this.jobTitle,
    this.driverName,
  });

  factory JobApplication.fromJson(Map<String, dynamic> j) => JobApplication(
    id: strReq(j['id']),
    jobId: strReq(j['job_id']),
    driverAccountId: strReq(j['driver_account_id']),
    applicantUserId: strReq(j['applicant_user_id']),
    coverNote: str(j['cover_note']),
    status: strReq(j['status'], 'APPLIED'),
    reviewNote: str(j['review_note']),
    createdAt: dt(j['created_at']),
    jobTitle: str(j['job_postings'] is Map ? j['job_postings']['title'] : null),
    driverName: str(
      j['driver_accounts'] is Map ? j['driver_accounts']['display_name'] : null,
    ),
  );

  final String id;
  final String jobId;
  final String driverAccountId;
  final String applicantUserId;
  final String? coverNote;
  final String status;
  final String? reviewNote;
  final DateTime? createdAt;
  final String? jobTitle;
  final String? driverName;
}

/// Row from `public.job_assignments`.
class JobAssignment {
  const JobAssignment({
    required this.id,
    required this.jobId,
    required this.applicationId,
    required this.companyId,
    required this.driverAccountId,
    required this.companyDriverId,
    required this.status,
    this.createdAt,
    this.endedAt,
    this.jobTitle,
    this.companyName,
    this.driverName,
  });

  factory JobAssignment.fromJson(Map<String, dynamic> j) => JobAssignment(
    id: strReq(j['id']),
    jobId: strReq(j['job_id']),
    applicationId: strReq(j['application_id']),
    companyId: strReq(j['company_id']),
    driverAccountId: strReq(j['driver_account_id']),
    companyDriverId: strReq(j['company_driver_id']),
    status: strReq(j['status'], 'ACTIVE'),
    createdAt: dt(j['created_at']),
    endedAt: dt(j['ended_at']),
    jobTitle: str(j['job_postings'] is Map ? j['job_postings']['title'] : null),
    companyName: str(j['companies'] is Map ? j['companies']['name'] : null),
    driverName: str(
      j['driver_accounts'] is Map ? j['driver_accounts']['display_name'] : null,
    ),
  );

  final String id;
  final String jobId;
  final String applicationId;
  final String companyId;
  final String driverAccountId;
  final String companyDriverId;
  final String status;
  final DateTime? createdAt;
  final DateTime? endedAt;
  final String? jobTitle;
  final String? companyName;
  final String? driverName;

  bool get isActive => status == 'ACTIVE';
}

/// Result row from `public.easyfleet_search_drivers`.
class DriverSearchResult {
  const DriverSearchResult({
    required this.driverAccountId,
    required this.displayName,
    this.licenceClass,
    this.issuingState,
    required this.verificationStatus,
    this.validUntil,
  });

  factory DriverSearchResult.fromJson(Map<String, dynamic> j) =>
      DriverSearchResult(
        driverAccountId: strReq(j['driver_account_id']),
        displayName: strReq(j['display_name']),
        licenceClass: str(j['licence_class']),
        issuingState: str(j['issuing_state']),
        verificationStatus: strReq(j['verification_status']),
        validUntil: dateOnly(j['valid_until']),
      );

  final String driverAccountId;
  final String displayName;
  final String? licenceClass;
  final String? issuingState;
  final String verificationStatus;
  final DateTime? validUntil;
}

/// Result of a billed driver contact unlock (Rs 100 per lookup).
class DriverContact {
  const DriverContact({
    required this.driverAccountId,
    required this.displayName,
    this.phoneE164,
    required this.amountInr,
    required this.lookupId,
    this.alreadyUnlocked = false,
  });

  factory DriverContact.fromJson(Map<String, dynamic> j) => DriverContact(
    driverAccountId: strReq(j['driver_account_id']),
    displayName: strReq(j['display_name']),
    phoneE164: str(j['phone_e164']),
    amountInr: dbl(j['amount_inr']) ?? 100,
    lookupId: strReq(j['lookup_id']),
    alreadyUnlocked: boolean(j['already_unlocked']),
  );

  final String driverAccountId;
  final String displayName;
  final String? phoneE164;
  final double amountInr;
  final String lookupId;
  final bool alreadyUnlocked;
}
