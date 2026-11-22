import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_point.freezed.dart';
part 'location_point.g.dart';

/// One-shot location capture, mirroring WonderMove's `LocationPoint` model.
@freezed
abstract class LocationPoint with _$LocationPoint {
  const factory LocationPoint({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    required DateTime capturedAt,
    String? photoPath,
  }) = _LocationPoint;

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);
}
