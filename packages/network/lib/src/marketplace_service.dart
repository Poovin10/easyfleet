import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'company_service.dart';
import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ref.watch(supabaseClientProvider));
});

/// Job marketplace backed by `job_postings`, `job_applications` and
/// `job_assignments`. Kept separate from core fleet operations; appointment
/// atomically creates the company-driver relationship server-side.
class MarketplaceService {
  MarketplaceService(this._client);

  final SupabaseClient _client;

  static const _jobSelect = '*, companies(name)';

  /// Open jobs discoverable by any authenticated driver.
  Future<List<JobPosting>> searchJobs({
    String? licenceClass,
    String? location,
    int limit = 50,
  }) async {
    var query = _client
        .from(Tables.jobPostings)
        .select(_jobSelect)
        .eq('status', 'OPEN');
    if (licenceClass != null && licenceClass.isNotEmpty) {
      query = query.contains('required_licence_classes', [licenceClass]);
    }
    if (location != null && location.trim().isNotEmpty) {
      query = query.or(
        'city.ilike.%${location.trim()}%,state.ilike.%${location.trim()}%',
      );
    }
    final rows = await query.order('created_at', ascending: false).limit(limit);
    return rows.map(JobPosting.fromJson).toList();
  }

  Future<List<JobPosting>> companyJobs(String companyId) async {
    final rows = await _client
        .from(Tables.jobPostings)
        .select(_jobSelect)
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return rows.map(JobPosting.fromJson).toList();
  }

  Future<JobPosting?> job(String jobId) async {
    final row = await _client
        .from(Tables.jobPostings)
        .select(_jobSelect)
        .eq('id', jobId)
        .maybeSingle();
    return row == null ? null : JobPosting.fromJson(row);
  }

  Future<String> postJob({
    required String companyId,
    required String title,
    String? description,
    String? origin,
    String? destination,
    String? material,
    double? tonnes,
    String? vehicleType,
    List<String> requiredLicenceClasses = const [],
    String? city,
    String? state,
    double? rateAmount,
    String? rateUnit,
    DateTime? scheduledDate,
    String? idempotencyKey,
  }) async {
    final jobId = newId();
    await _client.rpc<dynamic>(
      RpcNames.postJob,
      params: {
        'p_company_id': companyId,
        'p_job_id': jobId,
        'p_title': title.trim(),
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_description': description,
        'p_origin': origin,
        'p_destination': destination,
        'p_material': material,
        'p_tonnes': tonnes,
        'p_vehicle_type': vehicleType,
        'p_required_licence_classes': requiredLicenceClasses,
        'p_city': city,
        'p_state': state,
        'p_rate_amount': rateAmount,
        'p_rate_unit': rateUnit,
        'p_scheduled_date': scheduledDate?.toIso8601String().split('T').first,
      },
    );
    return jobId;
  }

  Future<void> closeJob({required String jobId, required String status}) async {
    await _client.rpc<dynamic>(
      RpcNames.closeJob,
      params: {'p_job_id': jobId, 'p_status': status},
    );
  }

  // -- Applications -----------------------------------------------------------

  Future<String> applyToJob({
    required String jobId,
    String? coverNote,
    String? idempotencyKey,
  }) async {
    final applicationId = newId();
    final result = await _client.rpc<dynamic>(
      RpcNames.applyToJob,
      params: {
        'p_job_id': jobId,
        'p_application_id': applicationId,
        'p_cover_note': coverNote,
        'p_idempotency_key': idempotencyKey ?? newId(),
      },
    );
    return result.toString();
  }

  Future<List<JobApplication>> applicantsForJob(String jobId) async {
    final rows = await _client
        .from(Tables.jobApplications)
        .select('*, driver_accounts(display_name), job_postings(title)')
        .eq('job_id', jobId)
        .order('created_at');
    return rows.map(JobApplication.fromJson).toList();
  }

  Future<List<JobApplication>> myApplications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(Tables.jobApplications)
        .select('*, job_postings(title, companies(name))')
        .eq('applicant_user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(JobApplication.fromJson).toList();
  }

  Future<void> reviewApplication({
    required String applicationId,
    required String decision,
    String? note,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.reviewApplication,
      params: {
        'p_application_id': applicationId,
        'p_decision': decision,
        'p_note': note,
        'p_idempotency_key': newId(),
      },
    );
  }

  Future<void> withdrawApplication(String applicationId) async {
    await _client.rpc<dynamic>(
      RpcNames.withdrawApplication,
      params: {'p_application_id': applicationId},
    );
  }

  // -- Appointment --------------------------------------------------------------

  Future<String> appointDriver({
    required String applicationId,
    String? idempotencyKey,
  }) async {
    final assignmentId = newId();
    await _client.rpc<dynamic>(
      RpcNames.appointDriver,
      params: {
        'p_application_id': applicationId,
        'p_assignment_id': assignmentId,
        'p_idempotency_key': idempotencyKey ?? newId(),
      },
    );
    return assignmentId;
  }

  Future<List<JobAssignment>> companyAssignments(String companyId) async {
    final rows = await _client
        .from(Tables.jobAssignments)
        .select(
          '*, job_postings(title), companies(name), driver_accounts(display_name)',
        )
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return rows.map(JobAssignment.fromJson).toList();
  }

  Future<List<JobAssignment>> myAssignments() async {
    final account = await CompanyService(_client).myDriverAccount();
    if (account == null) return const [];
    final rows = await _client
        .from(Tables.jobAssignments)
        .select('*, job_postings(title), companies(name)')
        .eq('driver_account_id', account.id)
        .order('created_at', ascending: false);
    return rows.map(JobAssignment.fromJson).toList();
  }

  Future<void> endAssignment(String assignmentId) async {
    await _client.rpc<dynamic>(
      RpcNames.endAssignment,
      params: {'p_assignment_id': assignmentId},
    );
  }

  Stream<List<JobAssignment>> watchMyAssignments(String driverAccountId) {
    return _client
        .from(Tables.jobAssignments)
        .stream(primaryKey: ['id'])
        .eq('driver_account_id', driverAccountId)
        .map((rows) => rows.map(JobAssignment.fromJson).toList());
  }

  // -- Driver discovery -----------------------------------------------------------

  Future<List<DriverSearchResult>> searchDrivers({
    String? licenceClass,
    String? state,
    int limit = 50,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      RpcNames.searchDrivers,
      params: {
        'p_licence_class': licenceClass,
        'p_state': state,
        'p_limit': limit,
      },
    );
    return rows
        .map(
          (r) =>
              DriverSearchResult.fromJson(Map<String, dynamic>.from(r as Map)),
        )
        .toList();
  }
}
