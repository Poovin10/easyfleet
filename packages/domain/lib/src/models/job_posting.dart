import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'job_posting.freezed.dart';
part 'job_posting.g.dart';

@freezed
abstract class JobPosting with _$JobPosting {
  const factory JobPosting({
    required String id,
    required String transporterId,
    required String title,
    required Set<LicenseClass> requiredLicenseClasses,

    /// Minimum years of experience per vehicle category.
    @Default(<VehicleCategory, int>{})
    Map<VehicleCategory, int> requiredExperience,
    VehicleCategory? vehicleCategory,
    String? pickupLocation,
    String? dropLocation,
    double? payPerTrip,
    String? description,
    required JobStatus status,
    required DateTime createdAt,
    DateTime? expiresAt,
    @Default(0) int applicantCount,
  }) = _JobPosting;

  factory JobPosting.fromJson(Map<String, dynamic> json) =>
      _$JobPostingFromJson(json);
}
