import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'outbox_entry.dart';
import 'outbox_repository.dart';

final outboxRepositoryProvider = FutureProvider<OutboxRepository>((ref) {
  return OutboxRepository.create();
});

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final repository = await ref.watch(outboxRepositoryProvider.future);
  final client = ref.watch(supabaseClientProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return SyncService(repository, client, () => isOnline);
});

/// Flushes queued writes to Supabase with idempotency keys.
///
/// Contract preserved from the native apps: bounded retries (5 attempts),
/// dead-letter state, claim-before-upload, and duplicate-key tolerance.
/// RPC-targeted entries carry their idempotency key inside the payload;
/// a server-side unique violation means the write already landed.
class SyncService {
  SyncService(this._repository, this._client, this._isOnline);

  final OutboxRepository _repository;
  final SupabaseClient _client;
  final bool Function() _isOnline;

  bool _flushing = false;

  Future<int> flush() async {
    if (!_isOnline() || _flushing) return 0;
    _flushing = true;
    var synced = 0;
    try {
      synced += await _flushOutbox();
      synced += await _flushBreadcrumbs();
      await _repository.deleteSynced();
      await _repository.deleteSyncedBreadcrumbs();
    } finally {
      _flushing = false;
    }
    return synced;
  }

  Future<int> _flushOutbox() async {
    final pending = await _repository.pending();
    var synced = 0;
    for (final entry in pending) {
      if (!await _repository.claim(entry.id!)) continue;
      try {
        await _dispatch(entry);
        await _repository.markSynced(entry.id!);
        synced++;
      } catch (error) {
        if (_isDuplicate(error)) {
          // The idempotent write already exists server-side.
          await _repository.markSynced(entry.id!);
          synced++;
        } else if (_isAuthError(error)) {
          // Session expired: release the claim without burning an attempt.
          // The next flush after re-auth retries this row immediately.
          await _repository.release(entry.id!, 'auth: $error');
        } else {
          debugPrint('Sync failed for ${entry.idempotencyKey}: $error');
          await _repository.markFailed(entry.id!, error.toString());
        }
      }
    }
    return synced;
  }

  Future<void> _dispatch(OutboxEntry entry) async {
    if (entry.isRpc) {
      await _client.rpc<dynamic>(entry.rpcName, params: entry.payload);
      return;
    }
    switch (entry.operation) {
      case OutboxOperation.insert:
        await _client.from(entry.table).insert(entry.payload);
      case OutboxOperation.update:
        await _client
            .from(entry.table)
            .update(entry.payload)
            .eq('id', entry.payload['id'] as String);
      case OutboxOperation.delete:
        throw UnsupportedError(
          'Server-side deletes are not available: the backend has no '
          'generic delete RPC.',
        );
    }
  }

  Future<int> _flushBreadcrumbs() async {
    final pending = await _repository.pendingBreadcrumbs();
    var synced = 0;
    for (final row in pending) {
      final id = row['id'] as int;
      if (!await _repository.claimBreadcrumb(id)) continue;
      try {
        await _client.rpc<dynamic>(
          RpcNames.captureBreadcrumb,
          params: {
            'p_trip_id': row['trip_id'],
            'p_breadcrumb_id': row['breadcrumb_id'] ?? row['idempotency_key'],
            'p_latitude': row['latitude'],
            'p_longitude': row['longitude'],
            'p_recorded_at': row['recorded_at'],
            'p_idempotency_key': row['idempotency_key'],
            'p_accuracy_meters': row['accuracy'] ?? 0,
          },
        );
        await _repository.markBreadcrumbSynced(id);
        synced++;
      } catch (error) {
        if (_isDuplicate(error)) {
          await _repository.markBreadcrumbSynced(id);
          synced++;
        } else if (_isAuthError(error)) {
          await _repository.releaseBreadcrumb(id, 'auth: $error');
        } else {
          await _repository.markBreadcrumbFailed(id, error.toString());
        }
      }
    }
    return synced;
  }

  bool _isDuplicate(Object error) {
    if (error is PostgrestException) {
      return error.code == '23505';
    }
    final text = error.toString();
    return text.contains('23505') || text.contains('duplicate key');
  }

  bool _isAuthError(Object error) {
    if (error is PostgrestException) {
      return error.code == '401' || error.code == 'PGRST301';
    }
    if (error is AuthException) return true;
    final text = error.toString();
    return text.contains('JWT expired') || text.contains('401');
  }
}

/// Runs the sync loop: periodic flush plus flush on connectivity regain.
final syncControllerProvider = NotifierProvider<SyncController, SyncLoopState>(
  SyncController.new,
);

class SyncLoopState {
  const SyncLoopState({
    this.pending = 0,
    this.deadLetters = 0,
    this.lastSyncedAt,
    this.isSyncing = false,
  });

  final int pending;
  final int deadLetters;
  final DateTime? lastSyncedAt;
  final bool isSyncing;

  SyncLoopState copyWith({
    int? pending,
    int? deadLetters,
    DateTime? lastSyncedAt,
    bool? isSyncing,
  }) => SyncLoopState(
    pending: pending ?? this.pending,
    deadLetters: deadLetters ?? this.deadLetters,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    isSyncing: isSyncing ?? this.isSyncing,
  );
}

class SyncController extends Notifier<SyncLoopState> {
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;

  @override
  SyncLoopState build() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => flushNow());
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _wasOffline) flushNow();
      _wasOffline = !online;
    });
    ref.onDispose(() {
      _timer?.cancel();
      _connectivitySub?.cancel();
    });
    // Initial counts once the repository is ready.
    Future.microtask(refreshCounts);
    return const SyncLoopState();
  }

  Future<void> refreshCounts() async {
    final repository = await ref.read(outboxRepositoryProvider.future);
    state = state.copyWith(
      pending:
          await repository.pendingCount() +
          await repository.pendingBreadcrumbCount(),
      deadLetters: await repository.deadLetterCount(),
    );
  }

  Future<void> flushNow() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);
    try {
      final service = await ref.read(syncServiceProvider.future);
      final synced = await service.flush();
      state = state.copyWith(
        isSyncing: false,
        lastSyncedAt: synced > 0 ? DateTime.now() : state.lastSyncedAt,
      );
    } catch (error) {
      debugPrint('Sync loop error: $error');
      state = state.copyWith(isSyncing: false);
    }
    await refreshCounts();
  }

  Future<void> retryDeadLetters() async {
    final repository = await ref.read(outboxRepositoryProvider.future);
    for (final entry in await repository.deadLetters()) {
      await repository.retryPermanent(entry.id!);
    }
    await flushNow();
  }
}
