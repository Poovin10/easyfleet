import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'outbox_entry.dart';

/// Local outbox replacing the native `driver_outbox` / `transporter_outbox`
/// Room tables, plus the offline breadcrumb queue.
class OutboxRepository {
  OutboxRepository(this._database);

  final Database _database;

  static const table = 'outbox';
  static const breadcrumbTable = 'location_breadcrumbs';
  static const maxAttempts = 5;

  static Future<OutboxRepository> create() async {
    final directory = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      '${directory.path}/easyfleet_sync.db',
      version: 2,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS outbox (
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
        await database.execute('''
          CREATE TABLE IF NOT EXISTS location_breadcrumbs (
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
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v1 devices may lack breadcrumb bookkeeping columns.
          final columns = await database.rawQuery(
            'PRAGMA table_info($breadcrumbTable)',
          );
          final names = columns.map((c) => c['name'] as String).toSet();
          if (!names.contains('breadcrumb_id')) {
            await database.execute(
              'ALTER TABLE $breadcrumbTable ADD COLUMN breadcrumb_id TEXT',
            );
          }
          if (!names.contains('attempts')) {
            await database.execute(
              'ALTER TABLE $breadcrumbTable ADD COLUMN attempts INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (!names.contains('last_error')) {
            await database.execute(
              'ALTER TABLE $breadcrumbTable ADD COLUMN last_error TEXT',
            );
          }
          // Reset any rows stuck mid-upload from a killed process.
          await database.execute(
            "UPDATE $breadcrumbTable SET sync_state = 'PENDING' WHERE sync_state = 'UPLOADING'",
          );
          await database.execute(
            "UPDATE $table SET status = 'pending' WHERE status = 'uploading'",
          );
        }
      },
    );
    return OutboxRepository(db);
  }

  // -- Outbox ----------------------------------------------------------------

  Future<int> enqueue(OutboxEntry entry) {
    return _database.insert(
      table,
      entry.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<OutboxEntry>> pending({int limit = 100}) async {
    final rows = await _database.query(
      table,
      where: 'status IN (?, ?) AND attempts < ?',
      whereArgs: [
        OutboxStatus.pending.name,
        OutboxStatus.failed.name,
        maxAttempts,
      ],
      orderBy: 'created_at ASC',
      limit: limit,
    );
    return rows.map(OutboxEntry.fromMap).toList();
  }

  /// Claims a row for upload; only PENDING/FAILED rows can be claimed.
  Future<bool> claim(int id) async {
    final updated = await _database.update(
      table,
      {'status': OutboxStatus.uploading.name},
      where: 'id = ? AND status IN (?, ?)',
      whereArgs: [id, OutboxStatus.pending.name, OutboxStatus.failed.name],
    );
    return updated > 0;
  }

  Future<void> markSynced(int id) {
    return _database.update(
      table,
      {'status': OutboxStatus.synced.name, 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns a claimed row to the queue without consuming a retry attempt.
  /// Used when the failure is an expired session rather than a bad request.
  Future<void> release(int id, String error) {
    return _database.update(
      table,
      {'status': OutboxStatus.pending.name, 'last_error': error},
      where: 'id = ? AND status = ?',
      whereArgs: [id, OutboxStatus.uploading.name],
    );
  }

  Future<void> markFailed(int id, String error) async {
    final rows = await _database.query(
      table,
      columns: ['attempts'],
      where: 'id = ?',
      whereArgs: [id],
    );
    final attempts = (rows.first['attempts'] as int? ?? 0) + 1;
    await _database.update(
      table,
      {
        'status': attempts >= maxAttempts
            ? OutboxStatus.failedPermanent.name
            : OutboxStatus.failed.name,
        'attempts': attempts,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Requeues a permanently failed row for another manual retry cycle.
  Future<void> retryPermanent(int id) {
    return _database.update(
      table,
      {'status': OutboxStatus.pending.name, 'attempts': 0, 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> pendingCount() async {
    final rows = await _database.rawQuery(
      "SELECT COUNT(*) AS n FROM $table WHERE status IN ('pending','failed','uploading')",
    );
    return (rows.first['n'] as int?) ?? 0;
  }

  Future<int> deadLetterCount() async {
    final rows = await _database.rawQuery(
      "SELECT COUNT(*) AS n FROM $table WHERE status = 'failedPermanent'",
    );
    return (rows.first['n'] as int?) ?? 0;
  }

  Future<List<OutboxEntry>> deadLetters() async {
    final rows = await _database.query(
      table,
      where: 'status = ?',
      whereArgs: [OutboxStatus.failedPermanent.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(OutboxEntry.fromMap).toList();
  }

  Future<void> deleteSynced() {
    return _database.delete(
      table,
      where: 'status = ?',
      whereArgs: [OutboxStatus.synced.name],
    );
  }

  // -- Breadcrumb queue ---------------------------------------------------------

  Future<int> enqueueBreadcrumb({
    required String breadcrumbId,
    required String tripId,
    required double latitude,
    required double longitude,
    double? accuracy,
    required DateTime recordedAt,
    required String idempotencyKey,
  }) {
    return _database.insert(breadcrumbTable, {
      'breadcrumb_id': breadcrumbId,
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'recorded_at': recordedAt.toUtc().toIso8601String(),
      'idempotency_key': idempotencyKey,
      'sync_state': 'PENDING',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> pendingBreadcrumbs({int limit = 200}) {
    return _database.query(
      breadcrumbTable,
      where: "sync_state IN ('PENDING','FAILED') AND attempts < ?",
      whereArgs: [maxAttempts],
      orderBy: 'recorded_at ASC',
      limit: limit,
    );
  }

  Future<bool> claimBreadcrumb(int id) async {
    final updated = await _database.update(
      breadcrumbTable,
      {'sync_state': 'UPLOADING'},
      where: "id = ? AND sync_state IN ('PENDING','FAILED')",
      whereArgs: [id],
    );
    return updated > 0;
  }

  Future<void> markBreadcrumbSynced(int id) {
    return _database.update(
      breadcrumbTable,
      {'sync_state': 'SYNCED', 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns a claimed breadcrumb to the queue without consuming an attempt.
  Future<void> releaseBreadcrumb(int id, String error) {
    return _database.update(
      breadcrumbTable,
      {'sync_state': 'PENDING', 'last_error': error},
      where: "id = ? AND sync_state = 'UPLOADING'",
      whereArgs: [id],
    );
  }

  Future<void> markBreadcrumbFailed(int id, String error) async {
    final rows = await _database.query(
      breadcrumbTable,
      columns: ['attempts'],
      where: 'id = ?',
      whereArgs: [id],
    );
    final attempts = (rows.first['attempts'] as int? ?? 0) + 1;
    await _database.update(
      breadcrumbTable,
      {
        'sync_state': attempts >= maxAttempts ? 'FAILED_PERMANENT' : 'FAILED',
        'attempts': attempts,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> pendingBreadcrumbCount() async {
    final rows = await _database.rawQuery(
      "SELECT COUNT(*) AS n FROM $breadcrumbTable WHERE sync_state IN ('PENDING','FAILED','UPLOADING')",
    );
    return (rows.first['n'] as int?) ?? 0;
  }

  Future<void> deleteSyncedBreadcrumbs() {
    return _database.delete(breadcrumbTable, where: "sync_state = 'SYNCED'");
  }
}
