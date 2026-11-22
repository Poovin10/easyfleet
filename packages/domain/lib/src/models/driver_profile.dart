import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'driver_profile.freezed.dart';
part 'driver_profile.g.dart';

@freezed
abstract class DriverProfile with _$DriverProfile {
  const factory DriverProfile({
    required String id,
    required String displayName,

    /// Globally unique driver licence number — the driver's primary identity.
    required String dlNumber,
    required LicenseClass licenseClass,

    /// Years of experience keyed by vehicle category (bulker, oil tanker, …).
    @Default(<VehicleCategory, int>{})
    Map<VehicleCategory, int> experienceByVehicle,
    required VerificationStatus dlVerification,
    String? dlDocumentUrl,
    String? email,
    String? phone,
    String? avatarUrl,
    String? transporterId,
    String? currentAssignmentId,
    @Default(<String>[]) List<String> permissions,
  }) = _DriverProfile;

  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);
}
