import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accounting_screen.dart';
import 'company_gate.dart';
import 'dashboard_screen.dart';

final _plansProvider = FutureProvider<List<SubscriptionPlan>>((ref) {
  return ref.watch(subscriptionServiceProvider).plans();
});

/// Subscription status, payment/renewal (₹1,500 / 30 days) and billing.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _method = 'MANUAL';
  final _referenceController = TextEditingController();
  bool _paying = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pay(SubscriptionPlan plan) async {
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    if ((_method == 'UPI' || _method == 'RAZORPAY') &&
        _referenceController.text.trim().isEmpty) {
      showErrorSnack(context, 'Enter the payment reference for $_method');
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Confirm payment',
      message:
          'Record a ${plan.name} payment of ₹${plan.priceInr.toStringAsFixed(0)} '
          '(${plan.durationDays} days) via $_method?',
      confirmLabel: 'Record payment',
    );
    if (!confirmed || !mounted) return;
    setState(() => _paying = true);
    try {
      await ref
          .read(subscriptionServiceProvider)
          .pay(
            companyId: membership.companyId,
            planId: plan.id,
            method: _method,
            providerReference: _method == 'MANUAL'
                ? null
                : _referenceController.text.trim(),
          );
      ref.invalidate(subscriptionStatusProvider);
      ref.invalidate(billingHistoryProvider);
      if (mounted) {
        showSuccessSnack(context, 'Subscription active. Thank you!');
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStatusProvider);
    final plans = ref.watch(_plansProvider);
    final billing = ref.watch(billingHistoryProvider);

    return AppScaffold(
      title: 'Subscription',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AsyncView(
            value: subscription,
            onRetry: () => ref.invalidate(subscriptionStatusProvider),
            builder: (sub) => AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Current plan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (sub != null) StatusChip(status: sub.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (sub == null)
                    const Text('No subscription record found.')
                  else ...[
                    Text(
                      sub.isTrial
                          ? 'Free trial — ${sub.daysRemaining} day(s) remaining'
                          : sub.isValid
                          ? 'Active — ${sub.daysRemaining} day(s) remaining'
                          : 'Expired on ${sub.validUntil.toLocal().toString().split(' ').first}',
                    ),
                    Text(
                      'Valid until: ${sub.validUntil.toLocal().toString().split('.').first}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Plan'),
          AsyncView(
            value: plans,
            onRetry: () => ref.invalidate(_plansProvider),
            builder: (list) => Column(
              children: [
                for (final plan in list)
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '₹${plan.priceInr.toStringAsFixed(0)} / ${plan.durationDays} days',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Unlimited trips, job postings, GPS device sync and '
                          'fleet tracking. No transaction fees.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _method,
                          decoration: const InputDecoration(
                            labelText: 'Payment method',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'MANUAL',
                              child: Text('Manual / bank transfer'),
                            ),
                            DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                            DropdownMenuItem(
                              value: 'RAZORPAY',
                              child: Text('Razorpay'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _method = v ?? 'MANUAL'),
                        ),
                        if (_method == 'UPI' || _method == 'RAZORPAY') ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _referenceController,
                            decoration: const InputDecoration(
                              labelText: 'Payment reference / transaction ID',
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: _paying ? null : () => _pay(plan),
                          icon: _paying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.payment),
                          label: Text(
                            _paying
                                ? 'Processing…'
                                : 'Pay ₹${plan.priceInr.toStringAsFixed(0)} / renew',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader(title: 'Billing history'),
          AsyncView(
            value: billing,
            isEmpty: (list) => list.isEmpty,
            emptyMessage: 'No payments recorded yet.',
            builder: (list) => Column(
              children: [
                for (final payment in list)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.receipt_outlined),
                    title: Text(
                      '${StatusChip.label(payment.purpose)} • ₹${payment.amountInr.toStringAsFixed(0)}',
                    ),
                    subtitle: Text(
                      [
                        payment.method,
                        if (payment.createdAt != null)
                          payment.createdAt!
                              .toLocal()
                              .toString()
                              .split('.')
                              .first,
                      ].join(' • '),
                    ),
                    trailing: StatusChip(status: payment.status, dense: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
