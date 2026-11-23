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
/// Storage RLS policies, and metadata writes go through scoped RPCs.
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
    final userId = _currentUserId;
    final cleanExtension = extension.replaceAll('.', '').toLowerCase();
    final filename =
        '$kind-${DateTime.now().microsecondsSinceEpoch}'
        '.$cleanExtension';

    late final String path;
    switch (kind) {
      case 'dl':
        final driverAccountId = await _driverAccountId();
        path = 'personal/$driverAccountId/licence/$filename';
      case 'gst':
        final companyId = await _ownedCompanyId();
        path = '$companyId/company_documents/$filename';
      default:
        path = 'personal/$userId/profile/$filename';
    }

    await _client.storage.from(_bucket).uploadBinary(path, bytes);
    return path;
  }

  Future<void> submitDriverDl({
    required String dlNumber,
    required LicenseClass licenseClass,
    required String documentPath,
  }) async {
    final driverAccountId = await _driverAccountId();
    await _client.rpc<void>(
      'easyfleet_submit_driver_licence',
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
    await _client.rpc<void>(
      'easyfleet_submit_company_gst',
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
          .select('gst_certificate_path')
          .eq('id', companyId)
          .maybeSingle();
      final path = row?['gst_certificate_path'] as String?;
      return (path != null && path.trim().isNotEmpty)
          ? VerificationStatus.pending
          : VerificationStatus.notSubmitted;
    }

    final driverAccountId = await _driverAccountId();
    final row = await _client
        .from(Tables.driverLicences)
        .select('verification_status')
        .eq('driver_account_id', driverAccountId)
        .maybeSingle();

    return switch (row?['verification_status'] as String?) {
      'PENDING' => VerificationStatus.pending,
      'VERIFIED' => VerificationStatus.approved,
      'FAILED' || 'EXPIRED' || 'REVIEW_REQUIRED' => VerificationStatus.rejected,
      _ => VerificationStatus.notSubmitted,
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
