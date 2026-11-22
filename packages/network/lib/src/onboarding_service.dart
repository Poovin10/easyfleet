import 'dart:typed_data';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

/// DL/GST onboarding: documents are uploaded to private Storage and approved manually.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final environment = ref.watch(environmentProvider);
  return OnboardingService(client, environment.storageBucket);
});

class OnboardingService {
  OnboardingService(this._client, this._bucket);

  final SupabaseClient _client;
  final String _bucket;

  Future<String> uploadDocument({
    required String userId,
    required String kind,
    required Uint8List bytes,
    required String extension,
  }) async {
    final path = '$userId/$kind-${DateTime.now().microsecondsSinceEpoch}.$extension';
    await _client.storage.from(_bucket).uploadBinary(path, bytes);
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<void> submitDriverDl({
    required String userId,
    required String dlNumber,
    required LicenseClass licenseClass,
    required String documentUrl,
  }) {
    return _client.from(Tables.driverProfiles).upsert({
      'id': userId,
      'dl_number': dlNumber.toUpperCase(),
      'license_class': licenseClass.name,
      'dl_document_url': documentUrl,
      'dl_verification': 'pending',
    });
  }

  Future<void> submitCompanyGst({
    required String userId,
    required String gst,
    required String legalName,
    required String documentUrl,
  }) {
    return _client.from(Tables.transporterCompanies).upsert({
      'id': userId,
      'gst': gst.toUpperCase(),
      'legal_name': legalName,
      'gst_document_url': documentUrl,
      'gst_verification': 'pending',
    });
  }

  Future<String> verificationStatus({
    required String userId,
    required bool isTransporter,
  }) async {
    final row = await _client
        .from(isTransporter ? Tables.transporterCompanies : Tables.driverProfiles)
        .select(isTransporter ? 'gst_verification' : 'dl_verification')
        .eq('id', userId)
        .single();
    return row[isTransporter ? 'gst_verification' : 'dl_verification'] as String;
  }
}
