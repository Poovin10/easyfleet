// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GpsDevice _$GpsDeviceFromJson(Map<String, dynamic> json) => _GpsDevice(
  id: json['id'] as String,
  imei: json['imei'] as String,
  transporterId: json['transporterId'] as String,
  status: $enumDecode(_$GpsDeviceStatusEnumMap, json['status']),
  vehicleNumber: json['vehicleNumber'] as String?,
  simNumber: json['simNumber'] as String?,
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  lastLatitude: (json['lastLatitude'] as num?)?.toDouble(),
  lastLongitude: (json['lastLongitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$GpsDeviceToJson(_GpsDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imei': instance.imei,
      'transporterId': instance.transporterId,
      'status': _$GpsDeviceStatusEnumMap[instance.status]!,
      'vehicleNumber': instance.vehicleNumber,
      'simNumber': instance.simNumber,
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'lastLatitude': instance.lastLatitude,
      'lastLongitude': instance.lastLongitude,
    };

const _$GpsDeviceStatusEnumMap = {
  GpsDeviceStatus.unbound: 'unbound',
  GpsDeviceStatus.active: 'active',
  GpsDeviceStatus.offline: 'offline',
  GpsDeviceStatus.faulty: 'faulty',
};
