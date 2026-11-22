// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspection _$InspectionFromJson(Map<String, dynamic> json) => _Inspection(
  id: json['id'] as String,
  kind: $enumDecode(_$InspectionKindEnumMap, json['kind']),
  vehicleNumber: json['vehicleNumber'] as String,
  status: $enumDecode(_$InspectionStatusEnumMap, json['status']),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  templateId: json['templateId'] as String?,
  answers:
      (json['answers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  photoPaths:
      (json['photoPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  capturedLocation: json['capturedLocation'] as String?,
);

Map<String, dynamic> _$InspectionToJson(_Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$InspectionKindEnumMap[instance.kind]!,
      'vehicleNumber': instance.vehicleNumber,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'templateId': instance.templateId,
      'answers': instance.answers,
      'photoPaths': instance.photoPaths,
      'capturedLocation': instance.capturedLocation,
    };

const _$InspectionKindEnumMap = {
  InspectionKind.driverCheck: 'driverCheck',
  InspectionKind.vehicle: 'vehicle',
  InspectionKind.tyre: 'tyre',
};

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.submitted: 'submitted',
  InspectionStatus.approved: 'approved',
  InspectionStatus.rejected: 'rejected',
};
