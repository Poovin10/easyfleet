enum OutboxOperation { insert, update, delete }

enum OutboxStatus { pending, synced, failed }

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

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'table_name': table,
    'operation': operation.name,
    'payload': payload,
    'idempotency_key': idempotencyKey,
    'created_at': createdAt.toIso8601String(),
    'attempts': attempts,
    'status': status.name,
    'last_error': lastError,
  };

  factory OutboxEntry.fromMap(Map<String, dynamic> map) {
    return OutboxEntry(
      id: map['id'] as int?,
      table: map['table_name'] as String,
      operation: OutboxOperation.values.byName(map['operation'] as String),
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      idempotencyKey: map['idempotency_key'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      attempts: (map['attempts'] as int?) ?? 0,
      status: OutboxStatus.values.byName(map['status'] as String),
      lastError: map['last_error'] as String?,
    );
  }
}
