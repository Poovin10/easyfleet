import 'package:dio/dio.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'outbox_entry.dart';
import 'outbox_repository.dart';

final outboxRepositoryProvider = FutureProvider<OutboxRepository>((ref) {
  return OutboxRepository.create();
});

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final repository = await ref.watch(outboxRepositoryProvider.future);
  final dataSource = ref.watch(supabaseDataSourceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return SyncService(repository, dataSource, () => isOnline);
});

/// Flushes queued writes to Supabase with idempotency keys.
class SyncService {
  SyncService(this._repository, this._dataSource, this._isOnline);

  final OutboxRepository _repository;
  final SupabaseDataSource _dataSource;
  final bool Function() _isOnline;

  Future<int> flush() async {
    if (!_isOnline()) return 0;

    final pending = await _repository.pending();
    var synced = 0;

    for (final entry in pending) {
      try {
        switch (entry.operation) {
          case OutboxOperation.insert:
            await _dataSource.insert(entry.table, entry.payload);
          case OutboxOperation.update:
            await _dataSource.update(
              entry.table,
              entry.payload,
              filterColumn: 'id',
              filterValue: entry.payload['id'] as String,
            );
          case OutboxOperation.delete:
            throw UnsupportedError(
              'Server-side deletes are not available: the backend has no '
              'generic delete_row RPC.',
            );
        }
        await _repository.markSynced(entry.id!);
        synced++;
      } on DioException catch (error) {
        debugPrint('Sync failed for ${entry.idempotencyKey}: ${error.message}');
        await _repository.markFailed(
          entry.id!,
          error.message ?? 'unknown error',
        );
      }
    }

    await _repository.deleteSynced();
    return synced;
  }
}
