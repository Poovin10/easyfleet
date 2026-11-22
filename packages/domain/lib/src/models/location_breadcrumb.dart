import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_breadcrumb.freezed.dart';
part 'location_breadcrumb.g.dart';

/// Continuous GPS breadcrumb written by the Driver foreground service.
@freezed
abstract class LocationBreadcrumb with _$LocationBreadcrumb {
  const factory LocationBreadcrumb({
    required String idempotencyKey,
    required String tripId,
    required double latitude,
    required double longitude,
    double? accuracy,
    required DateTime recordedAt,
    @Default('PENDING') String syncState,
  }) = _LocationBreadcrumb;

  factory LocationBreadcrumb.fromJson(Map<String, dynamic> json) =>
      _$LocationBreadcrumbFromJson(json);
}
