import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'job_application.freezed.dart';
part 'job_application.g.dart';

@freezed
abstract class JobApplication with _$JobApplication {
  const factory JobApplication({
    required String id,
    required String jobId,
    required String driverId,
    required ApplicationStatus status,
    required DateTime appliedAt,
    String? coverNote,
    /// Snapshot of the driver's declared experience at application time.
    @Default(<VehicleCategory, int>{}) Map<VehicleCategory, int> experienceSnapshot,
    String? assignmentId,
  }) = _JobApplication;

  factory JobApplication.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationFromJson(json);
}
