import 'dart:typed_data';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';

final documentServiceProvider = Provider<DocumentService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final environment = ref.watch(environmentProvider);
  return DocumentService(client, environment.storageBucket);
});

/// Private document storage. Objects live in `easyfleet-private-documents`
/// under policy-scoped paths; access is via short-lived signed URLs only.
class DocumentService {
  DocumentService(this._client, this._bucket);

  final SupabaseClient _client;
  final String _bucket;

  static const maxBytes = 20 * 1024 * 1024; // bucket limit: 20 MB

  /// Uploads (or replaces) a document object. Path must satisfy the bucket
  /// RLS policies, e.g. `<company>/trips/<trip>/pod/<file>`.
  Future<String> upload({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    if (bytes.length > maxBytes) {
      throw ArgumentError('Document exceeds the 20 MB bucket limit');
    }
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    return path;
  }

  /// Short-lived signed URL for a private object.
  Future<String> signedUrl(String path, {int expiresInSeconds = 300}) {
    return _client.storage
        .from(_bucket)
        .createSignedUrl(path, expiresInSeconds);
  }

  String podPath({
    required String companyId,
    required String tripId,
    required String filename,
  }) => '$companyId/trips/$tripId/pod/$filename';

  String receiptPath({
    required String companyId,
    required String tripId,
    required String filename,
  }) => '$companyId/trips/$tripId/receipts/$filename';

  String vehicleDocumentPath({
    required String companyId,
    required String vehicleId,
    required String kind,
    required String filename,
  }) => '$companyId/vehicles/$vehicleId/$kind/$filename';
}
