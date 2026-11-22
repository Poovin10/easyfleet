// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transporter_company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransporterCompany _$TransporterCompanyFromJson(Map<String, dynamic> json) =>
    _TransporterCompany(
      id: json['id'] as String,
      gst: json['gst'] as String,
      legalName: json['legalName'] as String,
      tradeName: json['tradeName'] as String?,
      gstVerification: $enumDecode(
        _$VerificationStatusEnumMap,
        json['gstVerification'],
      ),
      gstDocumentUrl: json['gstDocumentUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$TransporterCompanyToJson(_TransporterCompany instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gst': instance.gst,
      'legalName': instance.legalName,
      'tradeName': instance.tradeName,
      'gstVerification': _$VerificationStatusEnumMap[instance.gstVerification]!,
      'gstDocumentUrl': instance.gstDocumentUrl,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'permissions': instance.permissions,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.notSubmitted: 'notSubmitted',
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
