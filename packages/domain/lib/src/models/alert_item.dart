import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_item.freezed.dart';
part 'alert_item.g.dart';

enum AlertSeverity { info, warning, critical }

@freezed
abstract class AlertItem with _$AlertItem {
  const factory AlertItem({
    required String id,
    required String title,
    String? body,
    required AlertSeverity severity,
    required DateTime createdAt,
    @Default(false) bool isRead,
    String? tripId,
    String? vehicleNumber,
  }) = _AlertItem;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);
}
