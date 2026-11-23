import 'dart:typed_data';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

/// DL/GST onboarding against the live company-centric Supabase schema.
///
/// Documents are uploaded to the private bucket with paths that match the
/// Storage RLS policies; metadata writes go through scoped RPCs; approval
/// remains office-controlled.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final environment = ref.watch(environmentProvider);
  return OnboardingService(client, environment.storageBucket);
});

class OnboardingService {
  OnboardingService(this._client, this._bucket);

  final SupabaseClient _client;
  final String _bucket;

  /// Uploads a document and returns its object path inside the private bucket.
  Future<String> uploadDocument({
    required String kind,
    required Uint8List bytes,
    required String extension,
  }) async {
    final cleanExtension = extension.replaceAll('.', '').toLowerCase();
    final filename =
        '$kind-${DateTime.now().microsecondsSinceEpoch}.$cleanExtension';

    late final String path;
    switch (kind) {
      case 'dl':
        final driverAccountId = await _driverAccountId();
        path = 'personal/$driverAccountId/licence/$filename';
      case 'gst':
        final companyId = await _ownedCompanyId();
        path = '$companyId/company_documents/$filename';
      default:
        final driverAccountId = await _driverAccountId();
        path = 'personal/$driverAccountId/profile/$filename';
    }

    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  Future<void> submitDriverDl({
    required String dlNumber,
    required LicenseClass licenseClass,
    required String documentPath,
  }) async {
    final driverAccountId = await _driverAccountId();
    await _client.rpc<dynamic>(
      RpcNames.submitDriverLicence,
      params: {
        'p_driver_account_id': driverAccountId,
        'p_licence_class': _licenceClassValue(licenseClass),
        'p_licence_fingerprint': dlNumber.trim().toUpperCase(),
        'p_storage_path': documentPath,
      },
    );
  }

  Future<void> submitCompanyGst({
    required String gst,
    required String legalName,
    required String documentPath,
  }) async {
    final companyId = await _ownedCompanyId();
    await _client.rpc<dynamic>(
      RpcNames.submitCompanyGst,
      params: {
        'p_company_id': companyId,
        'p_gstin': gst.trim().toUpperCase(),
        'p_legal_name': legalName.trim(),
        'p_storage_path': documentPath,
      },
    );
  }

  Future<VerificationStatus> verificationStatus({
    required bool isTransporter,
  }) async {
    if (isTransporter) {
      final companyId = await _ownedCompanyId();
      final row = await _client
          .from(Tables.companies)
          .select('gst_verification_status, gst_certificate_path')
          .eq('id', companyId)
          .maybeSingle();
      return _mapStatus(
        row?['gst_verification_status'] as String?,
        submitted: (row?['gst_certificate_path'] as String? ?? '').isNotEmpty,
      );
    }
    final licence = await dlDetails();
    return _mapStatus(licence?.verificationStatus, submitted: licence != null);
  }

  /// Full licence record for the signed-in driver (status, rejection reason).
  Future<DriverLicence?> dlDetails() async {
    final driverAccountId = await _driverAccountId();
    final row = await _client
        .from(Tables.driverLicences)
        .select()
        .eq('driver_account_id', driverAccountId)
        .maybeSingle();
    return row == null ? null : DriverLicence.fromJson(row);
  }

  /// GST state for the owned company, including rejection reason.
  Future<Company?> gstDetails() async {
    final companyId = await _ownedCompanyId();
    final row = await _client
        .from(Tables.companies)
        .select()
        .eq('id', companyId)
        .maybeSingle();
    return row == null ? null : Company.fromJson(row);
  }

  /// Office review history for the caller's DL or company GST.
  Future<List<DocumentReview>> reviewHistory({
    required bool isTransporter,
  }) async {
    if (isTransporter) {
      final companyId = await _ownedCompanyId();
      final rows = await _client
          .from(Tables.documentReviewHistory)
          .select()
          .eq('company_id', companyId)
          .order('acted_at', ascending: false);
      return rows.map(DocumentReview.fromJson).toList();
    }
    final driverAccountId = await _driverAccountId();
    final rows = await _client
        .from(Tables.documentReviewHistory)
        .select()
        .eq('driver_account_id', driverAccountId)
        .order('acted_at', ascending: false);
    return rows.map(DocumentReview.fromJson).toList();
  }

  VerificationStatus _mapStatus(String? backend, {required bool submitted}) {
    return switch (backend) {
      'PENDING' => VerificationStatus.pending,
      'VERIFIED' => VerificationStatus.approved,
      'FAILED' || 'EXPIRED' || 'REVIEW_REQUIRED' => VerificationStatus.rejected,
      _ =>
        submitted
            ? VerificationStatus.pending
            : VerificationStatus.notSubmitted,
    };
  }

  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in before submitting onboarding documents');
    }
    return userId;
  }

  Future<String> _driverAccountId() async {
    final row = await _client
        .from(Tables.driverAccounts)
        .select('id')
        .eq('auth_user_id', _currentUserId)
        .maybeSingle();
    final id = row?['id'] as String?;
    if (id == null) {
      throw StateError('Driver account is missing. Complete signup first.');
    }
    return id;
  }

  Future<String> _ownedCompanyId() async {
    final rows = await _client
        .from(Tables.companyMemberships)
        .select('company_id, role')
        .eq('user_id', _currentUserId)
        .eq('status', 'ACTIVE');
    for (final row in rows) {
      final role = row['role'] as String?;
      if (role == 'OWNER' || role == 'ADMIN') {
        return row['company_id'] as String;
      }
    }
    throw StateError(
      'An active OWNER or ADMIN company membership is required for GST '
      'onboarding',
    );
  }

  String _licenceClassValue(LicenseClass value) => switch (value) {
    LicenseClass.lmv => 'LMV',
    LicenseClass.mmv => 'MMV',
    LicenseClass.hmv => 'HMV',
    LicenseClass.hmvPlus => 'HMV_PLUS',
    LicenseClass.tractorTrailer => 'TRACTOR_TRAILER',
    LicenseClass.hazardousGoods => 'HAZARDOUS_GOODS',
  };
}
