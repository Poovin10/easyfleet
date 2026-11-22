// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobApplication _$JobApplicationFromJson(Map<String, dynamic> json) =>
    _JobApplication(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      driverId: json['driverId'] as String,
      status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      coverNote: json['coverNote'] as String?,
      experienceSnapshot:
          (json['experienceSnapshot'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$VehicleCategoryEnumMap, k),
              (e as num).toInt(),
            ),
          ) ??
          const <VehicleCategory, int>{},
      assignmentId: json['assignmentId'] as String?,
    );

Map<String, dynamic> _$JobApplicationToJson(_JobApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'driverId': instance.driverId,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'appliedAt': instance.appliedAt.toIso8601String(),
      'coverNote': instance.coverNote,
      'experienceSnapshot': instance.experienceSnapshot.map(
        (k, e) => MapEntry(_$VehicleCategoryEnumMap[k]!, e),
      ),
      'assignmentId': instance.assignmentId,
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.applied: 'applied',
  ApplicationStatus.shortlisted: 'shortlisted',
  ApplicationStatus.appointed: 'appointed',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.withdrawn: 'withdrawn',
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
