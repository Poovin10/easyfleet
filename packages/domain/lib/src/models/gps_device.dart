import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'gps_device.freezed.dart';
part 'gps_device.g.dart';

/// A transporter-owned GPS tracker bound to a truck.
@freezed
abstract class GpsDevice with _$GpsDevice {
  const factory GpsDevice({
    required String id,
    /// Tracker IMEI, globally unique.
    required String imei,
    required String transporterId,
    required GpsDeviceStatus status,
    String? vehicleNumber,
    String? simNumber,
    DateTime? lastSeenAt,
    double? lastLatitude,
    double? lastLongitude,
  }) = _GpsDevice;

  factory GpsDevice.fromJson(Map<String, dynamic> json) =>
      _$GpsDeviceFromJson(json);
}
