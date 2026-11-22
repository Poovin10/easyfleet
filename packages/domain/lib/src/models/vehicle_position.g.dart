// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehiclePosition _$VehiclePositionFromJson(Map<String, dynamic> json) =>
    _VehiclePosition(
      vehicleId: json['vehicleId'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tripId: json['tripId'] as String?,
    );

Map<String, dynamic> _$VehiclePositionToJson(_VehiclePosition instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleNumber': instance.vehicleNumber,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heading': instance.heading,
      'speed': instance.speed,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tripId': instance.tripId,
    };
