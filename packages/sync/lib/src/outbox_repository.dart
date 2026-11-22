import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'outbox_entry.dart';

/// Local outbox replacing the native `driver_outbox` Room table.
class OutboxRepository {
  OutboxRepository(this._database);

  final Database _database;

  static const table = 'outbox';

  static Future<OutboxRepository> create() async {
    final directory = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      '${directory.path}/easyfleet_sync.db',
      version: 1,
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
            trip_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL,
            recorded_at TEXT NOT NULL,
            idempotency_key TEXT NOT NULL UNIQUE,
            sync_state TEXT NOT NULL DEFAULT 'PENDING'
          )
        ''');
      },
    );
    return OutboxRepository(db);
  }

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
      where: 'status IN (?, ?)',
      whereArgs: [OutboxStatus.pending.name, OutboxStatus.failed.name],
      orderBy: 'created_at ASC',
      limit: limit,
    );
    return rows.map(OutboxEntry.fromMap).toList();
  }

  Future<void> markSynced(int id) {
    return _database.update(
      table,
      {'status': OutboxStatus.synced.name, 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(int id, String error) async {
    final entry = await _database.query(table, where: 'id = ?', whereArgs: [id]);
    final attempts = (entry.first['attempts'] as int? ?? 0) + 1;
    await _database.update(
      table,
      {
        'status': OutboxStatus.failed.name,
        'attempts': attempts,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSynced() {
    return _database.delete(
      table,
      where: 'status = ?',
      whereArgs: [OutboxStatus.synced.name],
    );
  }
}
