// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationPoint _$LocationPointFromJson(Map<String, dynamic> json) =>
    _LocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      photoPath: json['photoPath'] as String?,
    );

Map<String, dynamic> _$LocationPointToJson(_LocationPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'photoPath': instance.photoPath,
    };
