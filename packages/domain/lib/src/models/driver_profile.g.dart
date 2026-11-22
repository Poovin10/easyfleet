// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    _DriverProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      dlNumber: json['dlNumber'] as String,
      licenseClass: $enumDecode(_$LicenseClassEnumMap, json['licenseClass']),
      experienceByVehicle:
          (json['experienceByVehicle'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$VehicleCategoryEnumMap, k),
              (e as num).toInt(),
            ),
          ) ??
          const <VehicleCategory, int>{},
      dlVerification: $enumDecode(
        _$VerificationStatusEnumMap,
        json['dlVerification'],
      ),
      dlDocumentUrl: json['dlDocumentUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      transporterId: json['transporterId'] as String?,
      currentAssignmentId: json['currentAssignmentId'] as String?,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$DriverProfileToJson(_DriverProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'dlNumber': instance.dlNumber,
      'licenseClass': _$LicenseClassEnumMap[instance.licenseClass]!,
      'experienceByVehicle': instance.experienceByVehicle.map(
        (k, e) => MapEntry(_$VehicleCategoryEnumMap[k]!, e),
      ),
      'dlVerification': _$VerificationStatusEnumMap[instance.dlVerification]!,
      'dlDocumentUrl': instance.dlDocumentUrl,
      'email': instance.email,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'transporterId': instance.transporterId,
      'currentAssignmentId': instance.currentAssignmentId,
      'permissions': instance.permissions,
    };

const _$LicenseClassEnumMap = {
  LicenseClass.lmv: 'lmv',
  LicenseClass.mmv: 'mmv',
  LicenseClass.hmv: 'hmv',
  LicenseClass.hmvPlus: 'hmvPlus',
  LicenseClass.tractorTrailer: 'tractorTrailer',
  LicenseClass.hazardousGoods: 'hazardousGoods',
};

const _$VehicleCategoryEnumMap = {
  VehicleCategory.bulker: 'bulker',
  VehicleCategory.oilTanker: 'oilTanker',
  VehicleCategory.openTruck: 'openTruck',
  VehicleCategory.trailer: 'trailer',
  VehicleCategory.lmcCab: 'lmcCab',
  VehicleCategory.container: 'container',
  VehicleCategory.tipper: 'tipper',
  VehicleCategory.flatbed: 'flatbed',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.notSubmitted: 'notSubmitted',
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
