import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

/// The appointment relationship, mirrored to both apps via Supabase Realtime.
@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String driverId,
    required String transporterId,
    String? jobId,
    String? applicationId,
    required AssignmentStatus status,
    required DateTime appointedAt,
    DateTime? endedAt,
    String? vehicleNumber,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}
