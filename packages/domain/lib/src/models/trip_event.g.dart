// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripEvent _$TripEventFromJson(Map<String, dynamic> json) => _TripEvent(
  id: json['id'] as String,
  tripId: json['tripId'] as String,
  stage: $enumDecode(_$TripStageEnumMap, json['stage']),
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  actorId: json['actorId'] as String?,
  note: json['note'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TripEventToJson(_TripEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'stage': _$TripStageEnumMap[instance.stage]!,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'actorId': instance.actorId,
      'note': instance.note,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
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
