import 'parse.dart';

/// Row from `public.subscription_plans`.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceInr,
    required this.durationDays,
    this.currency = 'INR',
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> j) => SubscriptionPlan(
    id: strReq(j['id']),
    name: strReq(j['name']),
    priceInr: dbl(j['price_inr']) ?? 0,
    durationDays: integer(j['duration_days']) ?? 30,
    currency: strReq(j['currency'], 'INR'),
  );

  final String id;
  final String name;
  final double priceInr;
  final int durationDays;
  final String currency;
}

/// Row from `public.company_subscriptions`.
class CompanySubscription {
  const CompanySubscription({
    required this.id,
    required this.companyId,
    required this.planId,
    required this.status,
    required this.startedAt,
    required this.validUntil,
  });

  factory CompanySubscription.fromJson(Map<String, dynamic> j) =>
      CompanySubscription(
        id: strReq(j['id']),
        companyId: strReq(j['company_id']),
        planId: strReq(j['plan_id']),
        status: strReq(j['status'], 'TRIAL'),
        startedAt: dtReq(j['started_at']),
        validUntil: dtReq(j['valid_until']),
      );

  final String id;
  final String companyId;
  final String planId;
  final String status;
  final DateTime startedAt;
  final DateTime validUntil;

  bool get isValid =>
      (status == 'TRIAL' || status == 'ACTIVE') &&
      validUntil.isAfter(DateTime.now());

  bool get isTrial => status == 'TRIAL';

  int get daysRemaining => validUntil.difference(DateTime.now()).inDays;
}

/// Row from `public.payment_transactions`.
class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.companyId,
    required this.purpose,
    required this.amountInr,
    required this.method,
    required this.status,
    this.providerReference,
    this.notes,
    this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> j) =>
      PaymentTransaction(
        id: strReq(j['id']),
        companyId: strReq(j['company_id']),
        purpose: strReq(j['purpose']),
        amountInr: dbl(j['amount_inr']) ?? 0,
        method: strReq(j['method'], 'MANUAL'),
        status: strReq(j['status'], 'CAPTURED'),
        providerReference: str(j['provider_reference']),
        notes: str(j['notes']),
        createdAt: dt(j['created_at']),
      );

  final String id;
  final String companyId;
  final String purpose;
  final double amountInr;
  final String method;
  final String status;
  final String? providerReference;
  final String? notes;
  final DateTime? createdAt;
}

/// Row from `public.notifications`.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.companyId,
    this.data = const {},
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: strReq(j['id']),
    kind: strReq(j['kind']),
    title: strReq(j['title']),
    body: strReq(j['body']),
    companyId: str(j['company_id']),
    data: jsonMap(j['data']),
    readAt: dt(j['read_at']),
    createdAt: dtReq(j['created_at']),
  );

  final String id;
  final String kind;
  final String title;
  final String body;
  final String? companyId;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;
}
