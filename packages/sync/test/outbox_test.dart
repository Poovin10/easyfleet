import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('OutboxEntry serialization', () {
    test('payload round-trips through JSON TEXT column', () {
      final entry = OutboxEntry(
        id: null,
        table: OutboxTargets.fuelEntry,
        operation: OutboxOperation.insert,
        payload: {
          'p_trip_id': 'trip-1',
          'p_litres': 120.5,
          'p_nested': {'a': 1},
        },
        idempotencyKey: 'key-1',
        createdAt: DateTime.utc(2026, 11, 23, 8),
      );
      final map = entry.toMap();
      expect(map['payload'], isA<String>());
      final restored = OutboxEntry.fromMap(map);
      expect(restored.payload['p_litres'], 120.5);
      expect(restored.payload['p_nested'], {'a': 1});
      expect(restored.idempotencyKey, 'key-1');
      expect(restored.isRpc, isTrue);
      expect(restored.rpcName, 'easyfleet_add_fuel_entry');
    });

    test('legacy Map payload rows still parse', () {
      final restored = OutboxEntry.fromMap({
        'id': 7,
        'table_name': 'trip_fuel_entries',
        'operation': 'insert',
        'payload': {'id': 'x'},
        'idempotency_key': 'k',
        'created_at': '2026-11-23T08:00:00.000Z',
        'attempts': 2,
        'status': 'failed',
        'last_error': 'boom',
      });
      expect(restored.payload['id'], 'x');
      expect(restored.status, OutboxStatus.failed);
      expect(restored.isRpc, isFalse);
    });
  });

  group('OutboxRepository queue contract', () {
    late Database db;
    late OutboxRepository repository;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('''
        CREATE TABLE outbox (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          operation TEXT NOT NULL,
          payload TEXT NOT NULL,
          idempotency_key TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'pending',
          last_error TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE location_breadcrumbs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          breadcrumb_id TEXT,
          trip_id TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          accuracy REAL,
          recorded_at TEXT NOT NULL,
          idempotency_key TEXT NOT NULL UNIQUE,
          sync_state TEXT NOT NULL DEFAULT 'PENDING',
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )
      ''');
      repository = OutboxRepository(db);
    });

    tearDown(() async => db.close());

    OutboxEntry entry(String key) => OutboxEntry(
      id: null,
      table: OutboxTargets.fuelEntry,
      operation: OutboxOperation.insert,
      payload: {'p_idempotency_key': key},
      idempotencyKey: key,
      createdAt: DateTime.now(),
    );

    test('duplicate idempotency keys are ignored', () async {
      await repository.enqueue(entry('dup'));
      await repository.enqueue(entry('dup'));
      expect(await repository.pendingCount(), 1);
    });

    test('claim only works from pending/failed', () async {
      await repository.enqueue(entry('a'));
      final pending = await repository.pending();
      expect(await repository.claim(pending.first.id!), isTrue);
      expect(await repository.claim(pending.first.id!), isFalse);
      expect(await repository.pendingCount(), 1); // uploading still counted
      expect(await repository.pending(), isEmpty);
    });

    test('five failures move the row to dead letter', () async {
      await repository.enqueue(entry('doomed'));
      final id = (await repository.pending()).first.id!;
      for (var i = 0; i < OutboxRepository.maxAttempts; i++) {
        await repository.markFailed(id, 'error $i');
      }
      expect(await repository.pending(), isEmpty);
      expect(await repository.deadLetterCount(), 1);
      await repository.retryPermanent(id);
      expect(await repository.pendingCount(), 1);
      expect(await repository.deadLetterCount(), 0);
    });

    test('synced rows are cleaned up', () async {
      await repository.enqueue(entry('ok'));
      final id = (await repository.pending()).first.id!;
      await repository.markSynced(id);
      await repository.deleteSynced();
      expect(await repository.pendingCount(), 0);
    });

    test('breadcrumb queue claims, syncs and dedupes', () async {
      await repository.enqueueBreadcrumb(
        breadcrumbId: 'b1',
        tripId: 't1',
        latitude: 9.9,
        longitude: 76.2,
        recordedAt: DateTime.utc(2026, 11, 23),
        idempotencyKey: 'bk1',
      );
      await repository.enqueueBreadcrumb(
        breadcrumbId: 'b1-again',
        tripId: 't1',
        latitude: 9.9,
        longitude: 76.2,
        recordedAt: DateTime.utc(2026, 11, 23),
        idempotencyKey: 'bk1',
      );
      expect(await repository.pendingBreadcrumbCount(), 1);
      final rows = await repository.pendingBreadcrumbs();
      expect(await repository.claimBreadcrumb(rows.first['id'] as int), isTrue);
      await repository.markBreadcrumbSynced(rows.first['id'] as int);
      await repository.deleteSyncedBreadcrumbs();
      expect(await repository.pendingBreadcrumbCount(), 0);
    });
  });
}
