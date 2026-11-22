// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobPosting _$JobPostingFromJson(Map<String, dynamic> json) => _JobPosting(
  id: json['id'] as String,
  transporterId: json['transporterId'] as String,
  title: json['title'] as String,
  requiredLicenseClasses: (json['requiredLicenseClasses'] as List<dynamic>)
      .map((e) => $enumDecode(_$LicenseClassEnumMap, e))
      .toSet(),
  requiredExperience:
      (json['requiredExperience'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$VehicleCategoryEnumMap, k),
          (e as num).toInt(),
        ),
      ) ??
      const <VehicleCategory, int>{},
  vehicleCategory: $enumDecodeNullable(
    _$VehicleCategoryEnumMap,
    json['vehicleCategory'],
  ),
  pickupLocation: json['pickupLocation'] as String?,
  dropLocation: json['dropLocation'] as String?,
  payPerTrip: (json['payPerTrip'] as num?)?.toDouble(),
  description: json['description'] as String?,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  applicantCount: (json['applicantCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$JobPostingToJson(_JobPosting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transporterId': instance.transporterId,
      'title': instance.title,
      'requiredLicenseClasses': instance.requiredLicenseClasses
          .map((e) => _$LicenseClassEnumMap[e]!)
          .toList(),
      'requiredExperience': instance.requiredExperience.map(
        (k, e) => MapEntry(_$VehicleCategoryEnumMap[k]!, e),
      ),
      'vehicleCategory': _$VehicleCategoryEnumMap[instance.vehicleCategory],
      'pickupLocation': instance.pickupLocation,
      'dropLocation': instance.dropLocation,
      'payPerTrip': instance.payPerTrip,
      'description': instance.description,
      'status': _$JobStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'applicantCount': instance.applicantCount,
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

const _$JobStatusEnumMap = {
  JobStatus.open: 'open',
  JobStatus.closed: 'closed',
  JobStatus.filled: 'filled',
  JobStatus.cancelled: 'cancelled',
};
