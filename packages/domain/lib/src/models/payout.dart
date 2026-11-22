import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout.freezed.dart';
part 'payout.g.dart';

enum PayoutStatus { pending, paid, failed }

@freezed
abstract class Payout with _$Payout {
  const factory Payout({
    required String id,
    required double amount,
    required PayoutStatus status,
    required DateTime createdAt,
    String? method,
    String? reference,
    String? bankAccountLast4,
  }) = _Payout;

  factory Payout.fromJson(Map<String, dynamic> json) => _$PayoutFromJson(json);
}
