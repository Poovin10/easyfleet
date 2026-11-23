import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>(
  (_) => MarketplaceService(),
);

/// Legacy job-marketplace API.
///
/// The live EasyFleet backend is a company-centric fleet operations schema and
/// does not provide `job_postings`, `job_applications`, or `assignments`.
/// Methods fail fast instead of issuing queries that would return 404.
/// See `MISSING-BACKEND-CAPABILITIES.md` (M-01).
class MarketplaceService {
  MarketplaceService();

  Never _unsupported(String feature) => throw UnsupportedError(
    '$feature is not available: the EasyFleet backend does not provide a '
    'job marketplace schema.',
  );

  Future<List<JobPosting>> searchJobs({
    Set<LicenseClass>? licenseClasses,
    VehicleCategory? vehicleCategory,
    String? location,
    int limit = 50,
  }) => _unsupported('Job search');

  Future<void> postJob(JobPosting job) => _unsupported('Job posting');

  Future<void> applyToJob(JobApplication application) =>
      _unsupported('Job application');

  Future<List<JobApplication>> applicantsForJob(String jobId) =>
      _unsupported('Applicant listing');

  Future<List<JobApplication>> applicationsForDriver(String driverId) =>
      _unsupported('Driver application listing');

  Future<Assignment> appointDriver({
    required String driverId,
    required String transporterId,
    String? jobId,
    String? applicationId,
    String? vehicleNumber,
  }) => _unsupported('Driver appointment');

  Stream<List<Map<String, dynamic>>> watchAssignments(String userId) =>
      _unsupported('Assignment stream');
}
