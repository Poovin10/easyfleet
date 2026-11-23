import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'company_gate.dart';
import 'drivers_screen.dart';

final _ledgerProvider = FutureProvider<List<LedgerEntry>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(fleetServiceProvider).companyLedger(membership.companyId);
});

final _pendingExpensesProvider = FutureProvider<List<ExpenseEntry>>((
  ref,
) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(fleetServiceProvider).pendingExpenses(membership.companyId);
});

final billingHistoryProvider = FutureProvider<List<PaymentTransaction>>((
  ref,
) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref
      .watch(subscriptionServiceProvider)
      .billingHistory(membership.companyId);
});

/// Accounting: driver ledger, expense approvals and billing history.
class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(_ledgerProvider);
    final expenses = ref.watch(_pendingExpensesProvider);
    final billing = ref.watch(billingHistoryProvider);

    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        title: 'Accounting & KPIs',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showLedgerSheet(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Ledger entry'),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Driver ledger'),
                Tab(text: 'Expenses'),
                Tab(text: 'Billing'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AsyncView(
                    value: ledger,
                    onRetry: () => ref.invalidate(_ledgerProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyMessage: 'No ledger entries yet.',
                    builder: (list) {
                      final totalPaid = list
                          .where((e) => e.entryType == 'PAYMENT')
                          .fold<double>(0, (s, e) => s + e.amount);
                      final totalBata = list
                          .where((e) => e.entryType == 'BATA_EARNED')
                          .fold<double>(0, (s, e) => s + e.amount);
                      return ListView(
                        children: [
                          AppSectionCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Bata earned',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    Text(
                                      '₹${totalBata.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Paid out',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    Text(
                                      '₹${totalPaid.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          for (final entry in list)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                entry.isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: entry.isCredit
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                              title: Text(
                                '${entry.driverName ?? 'Driver'} • ${StatusChip.label(entry.entryType)}',
                              ),
                              subtitle: Text(entry.description ?? ''),
                              trailing: Text(
                                '₹${entry.amount.toStringAsFixed(2)}',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  AsyncView(
                    value: expenses,
                    onRetry: () => ref.invalidate(_pendingExpensesProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyMessage: 'No pending expenses.',
                    builder: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final entry = list[index];
                        return ListTile(
                          title: Text('${entry.category} • ₹${entry.amount}'),
                          subtitle: Text(entry.description ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Reject',
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    _review(context, ref, entry, 'REJECTED'),
                              ),
                              IconButton(
                                tooltip: 'Approve',
                                icon: const Icon(Icons.check),
                                onPressed: () =>
                                    _review(context, ref, entry, 'APPROVED'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  AsyncView(
                    value: billing,
                    onRetry: () => ref.invalidate(billingHistoryProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyMessage: 'No subscription payments yet.',
                    builder: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final payment = list[index];
                        return ListTile(
                          leading: const Icon(Icons.receipt_outlined),
                          title: Text(
                            '${StatusChip.label(payment.purpose)} • ₹${payment.amountInr.toStringAsFixed(0)}',
                          ),
                          subtitle: Text(
                            [
                              payment.method,
                              if (payment.providerReference != null)
                                payment.providerReference!,
                              if (payment.createdAt != null)
                                payment.createdAt!
                                    .toLocal()
                                    .toString()
                                    .split('.')
                                    .first,
                            ].join(' • '),
                          ),
                          trailing: StatusChip(
                            status: payment.status,
                            dense: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    ExpenseEntry entry,
    String decision,
  ) async {
    try {
      await ref
          .read(fleetServiceProvider)
          .reviewExpense(
            companyId: entry.companyId,
            entryId: entry.id,
            decision: decision,
          );
      ref.invalidate(_pendingExpensesProvider);
      if (context.mounted) {
        showSuccessSnack(context, 'Expense $decision');
      }
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _showLedgerSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _LedgerSheet(
          onDone: () {
            Navigator.pop(sheetContext);
            ref.invalidate(_ledgerProvider);
            showSuccessSnack(context, 'Ledger entry recorded');
          },
        ),
      ),
    );
  }
}

class _LedgerSheet extends ConsumerStatefulWidget {
  const _LedgerSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_LedgerSheet> createState() => _LedgerSheetState();
}

class _LedgerSheetState extends ConsumerState<_LedgerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  String _entryType = 'PAYMENT';
  String? _driverAccountId;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null || _driverAccountId == null) {
      showErrorSnack(context, 'Select a driver');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(fleetServiceProvider)
          .addLedgerEntry(
            companyId: membership.companyId,
            driverAccountId: _driverAccountId!,
            entryType: _entryType,
            amount: double.parse(_amount.text.trim()),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
          );
      widget.onDone();
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(companyDriversProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Record ledger entry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AsyncView(
                value: drivers,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'Hire a driver first.',
                builder: (list) => DropdownButtonFormField<String>(
                  initialValue:
                      list.any((d) => d.driverAccountId == _driverAccountId)
                      ? _driverAccountId
                      : null,
                  decoration: const InputDecoration(labelText: 'Driver'),
                  items: [
                    for (final driver in list)
                      DropdownMenuItem(
                        value: driver.driverAccountId,
                        child: Text(
                          driver.displayName ?? driver.localDriverCode,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _driverAccountId = v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _entryType,
                decoration: const InputDecoration(labelText: 'Entry type'),
                items: const [
                  DropdownMenuItem(
                    value: 'PAYMENT',
                    child: Text('Payment to driver'),
                  ),
                  DropdownMenuItem(value: 'ADVANCE', child: Text('Advance')),
                  DropdownMenuItem(
                    value: 'BATA_EARNED',
                    child: Text('Bata earned'),
                  ),
                  DropdownMenuItem(
                    value: 'APPROVED_DEDUCTION',
                    child: Text('Approved deduction'),
                  ),
                  DropdownMenuItem(
                    value: 'ADJUSTMENT',
                    child: Text('Adjustment'),
                  ),
                ],
                onChanged: (v) => setState(() => _entryType = v ?? 'PAYMENT'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _amount,
                label: 'Amount (₹)',
                decimal: true,
                validator: (v) => positiveNumberValidator(v),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _description,
                label: 'Description (optional)',
                validator: (_) => null,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Record entry'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
