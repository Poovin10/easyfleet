import 'dart:convert';

enum OutboxOperation { insert, update, delete }

/// Queue states mirror the native contract:
/// PENDING -> UPLOADING -> SYNCED | FAILED -> FAILED_PERMANENT.
enum OutboxStatus { pending, uploading, synced, failed, failedPermanent }

/// Logical write targets. Values prefixed with `rpc:` are routed to
/// SECURITY DEFINER RPCs; plain table names use REST (legacy contract).
abstract final class OutboxTargets {
  static const fuelEntry = 'rpc:${'easyfleet_add_fuel_entry'}';
  static const expenseEntry = 'rpc:${'easyfleet_add_expense_entry'}';
  static const breakdown = 'rpc:${'easyfleet_report_breakdown'}';
  static const breadcrumb = 'rpc:${'easyfleet_capture_breadcrumb'}';
}

class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.table,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    this.attempts = 0,
    this.status = OutboxStatus.pending,
    this.lastError,
  });

  final int? id;
  final String table;
  final OutboxOperation operation;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final DateTime createdAt;
  final int attempts;
  final OutboxStatus status;
  final String? lastError;

  bool get isRpc => table.startsWith('rpc:');
  String get rpcName => table.substring(4);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'table_name': table,
    'operation': operation.name,
    'payload': jsonEncode(payload),
    'idempotency_key': idempotencyKey,
    'created_at': createdAt.toIso8601String(),
    'attempts': attempts,
    'status': status.name,
    'last_error': lastError,
  };

  factory OutboxEntry.fromMap(Map<String, dynamic> map) {
    final rawPayload = map['payload'];
    final payload = rawPayload is String
        ? Map<String, dynamic>.from(jsonDecode(rawPayload) as Map)
        : Map<String, dynamic>.from(rawPayload as Map);
    return OutboxEntry(
      id: map['id'] as int?,
      table: map['table_name'] as String,
      operation: OutboxOperation.values.byName(map['operation'] as String),
      payload: payload,
      idempotencyKey: map['idempotency_key'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      attempts: (map['attempts'] as int?) ?? 0,
      status: OutboxStatus.values.byName(map['status'] as String),
      lastError: map['last_error'] as String?,
    );
  }
}
