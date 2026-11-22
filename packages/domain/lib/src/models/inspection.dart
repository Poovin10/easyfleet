import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

enum InspectionKind { driverCheck, vehicle, tyre }

enum InspectionStatus { pending, submitted, approved, rejected }

@freezed
abstract class Inspection with _$Inspection {
  const factory Inspection({
    required String id,
    required InspectionKind kind,
    required String vehicleNumber,
    required InspectionStatus status,
    DateTime? submittedAt,
    String? templateId,
    @Default(<String, String>{}) Map<String, String> answers,
    @Default(<String>[]) List<String> photoPaths,
    String? capturedLocation,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);
}
