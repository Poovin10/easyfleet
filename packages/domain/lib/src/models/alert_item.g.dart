// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertItem _$AlertItemFromJson(Map<String, dynamic> json) => _AlertItem(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String?,
  severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
  tripId: json['tripId'] as String?,
  vehicleNumber: json['vehicleNumber'] as String?,
);

Map<String, dynamic> _$AlertItemToJson(_AlertItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'tripId': instance.tripId,
      'vehicleNumber': instance.vehicleNumber,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.warning: 'warning',
  AlertSeverity.critical: 'critical',
};
