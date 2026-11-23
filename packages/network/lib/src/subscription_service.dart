import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'company_service.dart';
import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(ref.watch(supabaseClientProvider));
});

/// Transporter subscription (₹1,500 / 30 days), renewal and billing history.
/// Plan prices are server-authoritative; the client never sends an amount.
class SubscriptionService {
  SubscriptionService(this._client);

  final SupabaseClient _client;

  Future<List<SubscriptionPlan>> plans() async {
    final rows = await _client.from(Tables.subscriptionPlans).select();
    return rows.map(SubscriptionPlan.fromJson).toList();
  }

  Future<CompanySubscription?> subscription(String companyId) async {
    final row = await _client
        .from(Tables.companySubscriptions)
        .select()
        .eq('company_id', companyId)
        .maybeSingle();
    return row == null ? null : CompanySubscription.fromJson(row);
  }

  Stream<CompanySubscription?> watchSubscription(String companyId) {
    return _client
        .from(Tables.companySubscriptions)
        .stream(primaryKey: ['id'])
        .eq('company_id', companyId)
        .map(
          (rows) =>
              rows.isEmpty ? null : CompanySubscription.fromJson(rows.first),
        );
  }

  /// Records a subscription payment or renewal. For UPI/Razorpay a provider
  /// reference is mandatory; gateway webhook verification is a server-side
  /// extension point (see docs/GPS-AND-INTEGRATIONS.md).
  Future<void> pay({
    required String companyId,
    required String planId,
    required String method,
    String? providerReference,
    String? notes,
    String? idempotencyKey,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.paySubscription,
      params: {
        'p_company_id': companyId,
        'p_plan_id': planId,
        'p_method': method,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_provider_reference': providerReference,
        'p_notes': notes,
      },
    );
  }

  Future<List<PaymentTransaction>> billingHistory(String companyId) async {
    final rows = await _client
        .from(Tables.paymentTransactions)
        .select()
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return rows.map(PaymentTransaction.fromJson).toList();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(supabaseClientProvider));
});

/// Recipient-scoped notifications with realtime delivery.
class NotificationService {
  NotificationService(this._client);

  final SupabaseClient _client;

  Future<List<NotificationItem>> latest({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(Tables.notifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(NotificationItem.fromJson).toList();
  }

  Stream<List<NotificationItem>> watch() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(const []);
    return _client
        .from(Tables.notifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (rows) =>
              rows.map(NotificationItem.fromJson).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> markRead(String notificationId) async {
    await _client
        .from(Tables.notifications)
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', notificationId);
  }

  Future<void> markAllRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from(Tables.notifications)
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }
}

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(notificationServiceProvider)
      .watch()
      .map((items) => items.where((n) => !n.isRead).length);
});
