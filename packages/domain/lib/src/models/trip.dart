import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
abstract class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String vehicleNumber,
    String? driverId,
    String? transporterId,
    String? assignmentId,

    /// Tracker IMEI when this trip is being followed by a transporter GPS device.
    String? gpsDeviceId,
    String? partyName,
    String? loadingPoint,
    String? unloadingPoint,
    required TripStage stage,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? tonnage,
    String? currentLocationLabel,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
