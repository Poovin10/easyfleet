// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Assignment _$AssignmentFromJson(Map<String, dynamic> json) => _Assignment(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  transporterId: json['transporterId'] as String,
  jobId: json['jobId'] as String?,
  applicationId: json['applicationId'] as String?,
  status: $enumDecode(_$AssignmentStatusEnumMap, json['status']),
  appointedAt: DateTime.parse(json['appointedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  vehicleNumber: json['vehicleNumber'] as String?,
);

Map<String, dynamic> _$AssignmentToJson(_Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'transporterId': instance.transporterId,
      'jobId': instance.jobId,
      'applicationId': instance.applicationId,
      'status': _$AssignmentStatusEnumMap[instance.status]!,
      'appointedAt': instance.appointedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'vehicleNumber': instance.vehicleNumber,
    };

const _$AssignmentStatusEnumMap = {
  AssignmentStatus.active: 'active',
  AssignmentStatus.paused: 'paused',
  AssignmentStatus.ended: 'ended',
};
