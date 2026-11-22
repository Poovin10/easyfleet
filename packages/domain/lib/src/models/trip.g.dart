// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
  id: json['id'] as String,
  vehicleNumber: json['vehicleNumber'] as String,
  driverId: json['driverId'] as String?,
  transporterId: json['transporterId'] as String?,
  assignmentId: json['assignmentId'] as String?,
  gpsDeviceId: json['gpsDeviceId'] as String?,
  partyName: json['partyName'] as String?,
  loadingPoint: json['loadingPoint'] as String?,
  unloadingPoint: json['unloadingPoint'] as String?,
  stage: $enumDecode(_$TripStageEnumMap, json['stage']),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  tonnage: (json['tonnage'] as num?)?.toDouble(),
  currentLocationLabel: json['currentLocationLabel'] as String?,
);

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
  'id': instance.id,
  'vehicleNumber': instance.vehicleNumber,
  'driverId': instance.driverId,
  'transporterId': instance.transporterId,
  'assignmentId': instance.assignmentId,
  'gpsDeviceId': instance.gpsDeviceId,
  'partyName': instance.partyName,
  'loadingPoint': instance.loadingPoint,
  'unloadingPoint': instance.unloadingPoint,
  'stage': _$TripStageEnumMap[instance.stage]!,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'tonnage': instance.tonnage,
  'currentLocationLabel': instance.currentLocationLabel,
};

const _$TripStageEnumMap = {
  TripStage.assigned: 'assigned',
  TripStage.reporting: 'reporting',
  TripStage.loading: 'loading',
  TripStage.transit: 'transit',
  TripStage.unloading: 'unloading',
  TripStage.podPending: 'podPending',
  TripStage.completed: 'completed',
  TripStage.cancelled: 'cancelled',
};
