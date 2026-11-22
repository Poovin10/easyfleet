// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payout _$PayoutFromJson(Map<String, dynamic> json) => _Payout(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$PayoutStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  method: json['method'] as String?,
  reference: json['reference'] as String?,
  bankAccountLast4: json['bankAccountLast4'] as String?,
);

Map<String, dynamic> _$PayoutToJson(_Payout instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'status': _$PayoutStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'method': instance.method,
  'reference': instance.reference,
  'bankAccountLast4': instance.bankAccountLast4,
};

const _$PayoutStatusEnumMap = {
  PayoutStatus.pending: 'pending',
  PayoutStatus.paid: 'paid',
  PayoutStatus.failed: 'failed',
};
