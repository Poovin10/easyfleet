import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'trip_event.freezed.dart';
part 'trip_event.g.dart';

@freezed
abstract class TripEvent with _$TripEvent {
  const factory TripEvent({
    required String id,
    required String tripId,
    required TripStage stage,
    required DateTime occurredAt,
    String? actorId,
    String? note,
    double? latitude,
    double? longitude,
  }) = _TripEvent;

  factory TripEvent.fromJson(Map<String, dynamic> json) =>
      _$TripEventFromJson(json);
}
