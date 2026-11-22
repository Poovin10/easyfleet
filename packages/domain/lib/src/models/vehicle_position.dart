import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_position.freezed.dart';
part 'vehicle_position.g.dart';

/// Live marker fed to the Transporter fleet map via Supabase Realtime.
@freezed
abstract class VehiclePosition with _$VehiclePosition {
  const factory VehiclePosition({
    required String vehicleId,
    required String vehicleNumber,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    required DateTime updatedAt,
    String? tripId,
  }) = _VehiclePosition;

  factory VehiclePosition.fromJson(Map<String, dynamic> json) =>
      _$VehiclePositionFromJson(json);
}
