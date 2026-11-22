import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';

part 'transporter_company.freezed.dart';
part 'transporter_company.g.dart';

@freezed
abstract class TransporterCompany with _$TransporterCompany {
  const factory TransporterCompany({
    required String id,

    /// Globally unique GSTIN — the transporter's primary identity.
    required String gst,
    required String legalName,
    String? tradeName,
    required VerificationStatus gstVerification,
    String? gstDocumentUrl,
    String? email,
    String? phone,
    String? address,
    @Default(<String>[]) List<String> permissions,
  }) = _TransporterCompany;

  factory TransporterCompany.fromJson(Map<String, dynamic> json) =>
      _$TransporterCompanyFromJson(json);
}
