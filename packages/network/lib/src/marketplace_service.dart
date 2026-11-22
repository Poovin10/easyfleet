import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ref.watch(supabaseClientProvider));
});

/// Powers the driver job market and transporter hiring flow.
class MarketplaceService {
  MarketplaceService(this._client);

  final SupabaseClient _client;

  Future<List<JobPosting>> searchJobs({
    Set<LicenseClass>? licenseClasses,
    VehicleCategory? vehicleCategory,
    String? location,
    int limit = 50,
  }) async {
    var query = _client.from(Tables.jobPostings).select().eq('status', 'open');

    if (licenseClasses != null && licenseClasses.isNotEmpty) {
      query = query.overlaps(
        'required_license_classes',
        licenseClasses.map((e) => e.name).toList(),
      );
    }
    if (vehicleCategory != null) {
      query = query.eq('vehicle_category', vehicleCategory.name);
    }
    if (location != null && location.isNotEmpty) {
      query = query.ilike('pickup_location', '%$location%');
    }

    final rows = await query.order('created_at', ascending: false).limit(limit);
    return rows.map((row) => JobPosting.fromJson(_normalize(row))).toList();
  }

  Future<void> postJob(JobPosting job) {
    return _client.from(Tables.jobPostings).insert({
      'id': job.id,
      'transporter_id': job.transporterId,
      'title': job.title,
      'required_license_classes': job.requiredLicenseClasses
          .map((e) => e.name)
          .toList(),
      'required_experience': job.requiredExperience.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'vehicle_category': job.vehicleCategory?.name,
      'pickup_location': job.pickupLocation,
      'drop_location': job.dropLocation,
      'pay_per_trip': job.payPerTrip,
      'description': job.description,
      'status': job.status.name,
      'created_at': job.createdAt.toIso8601String(),
      'expires_at': job.expiresAt?.toIso8601String(),
    });
  }

  Future<void> applyToJob(JobApplication application) {
    return _client.from(Tables.jobApplications).insert({
      'id': application.id,
      'job_id': application.jobId,
      'driver_id': application.driverId,
      'status': application.status.name,
      'applied_at': application.appliedAt.toIso8601String(),
      'cover_note': application.coverNote,
      'experience_snapshot': application.experienceSnapshot.map(
        (key, value) => MapEntry(key.name, value),
      ),
    });
  }

  Future<List<JobApplication>> applicantsForJob(String jobId) async {
    final rows = await _client
        .from(Tables.jobApplications)
        .select()
        .eq('job_id', jobId)
        .order('applied_at');
    return rows.map((row) => JobApplication.fromJson(_normalize(row))).toList();
  }

  Future<List<JobApplication>> applicationsForDriver(String driverId) async {
    final rows = await _client
        .from(Tables.jobApplications)
        .select()
        .eq('driver_id', driverId)
        .order('applied_at', ascending: false);
    return rows.map((row) => JobApplication.fromJson(_normalize(row))).toList();
  }

  /// Appointment writes one assignment row; Realtime mirrors it to both apps.
  Future<Assignment> appointDriver({
    required String driverId,
    required String transporterId,
    String? jobId,
    String? applicationId,
    String? vehicleNumber,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final row = await _client
        .from(Tables.assignments)
        .insert({
          'id': id,
          'driver_id': driverId,
          'transporter_id': transporterId,
          'job_id': jobId,
          'application_id': applicationId,
          'status': 'active',
          'appointed_at': DateTime.now().toIso8601String(),
          'vehicle_number': vehicleNumber,
        })
        .select()
        .single();

    if (applicationId != null) {
      await _client
          .from(Tables.jobApplications)
          .update({'status': 'appointed', 'assignment_id': id})
          .eq('id', applicationId);
    }

    return Assignment.fromJson(_normalize(row));
  }

  Stream<List<Map<String, dynamic>>> watchAssignments(String userId) {
    // Supabase's stream builder has no `or` filter; RLS limits rows to the caller
    // and this narrows further to either side of the appointment relationship.
    return _client
        .from(Tables.assignments)
        .stream(primaryKey: ['id'])
        .map(
          (rows) => rows
              .where(
                (row) =>
                    row['driver_id'] == userId ||
                    row['transporter_id'] == userId,
              )
              .toList(),
        );
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> row) =>
      Map<String, dynamic>.from(row);
}
