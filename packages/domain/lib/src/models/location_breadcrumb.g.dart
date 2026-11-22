// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_breadcrumb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationBreadcrumb _$LocationBreadcrumbFromJson(Map<String, dynamic> json) =>
    _LocationBreadcrumb(
      idempotencyKey: json['idempotencyKey'] as String,
      tripId: json['tripId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      syncState: json['syncState'] as String? ?? 'PENDING',
    );

Map<String, dynamic> _$LocationBreadcrumbToJson(_LocationBreadcrumb instance) =>
    <String, dynamic>{
      'idempotencyKey': instance.idempotencyKey,
      'tripId': instance.tripId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'syncState': instance.syncState,
    };
