import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'company_gate.dart';

final companyDriversProvider = FutureProvider<List<CompanyDriver>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(fleetServiceProvider).companyDrivers(membership.companyId);
});

final companyAssignmentsProvider = FutureProvider<List<JobAssignment>>((
  ref,
) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref
      .watch(marketplaceServiceProvider)
      .companyAssignments(membership.companyId);
});

/// Company drivers and marketplace appointments.
class DriversScreen extends ConsumerWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(companyDriversProvider);
    final assignments = ref.watch(companyAssignmentsProvider);
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'Drivers & appointments',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDriver(context, ref),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add driver'),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Company drivers'),
                Tab(text: 'Appointments'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AsyncView(
                    value: drivers,
                    onRetry: () => ref.invalidate(companyDriversProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyMessage:
                        'No drivers yet. Use "Hire" to find verified drivers.',
                    builder: (list) => RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(companyDriversProvider),
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final driver = list[index];
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(
                              driver.displayName ?? driver.localDriverCode,
                            ),
                            subtitle: Text(driver.localDriverCode),
                            trailing: StatusChip(
                              status: driver.membershipStatus ?? 'INVITED',
                              dense: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AsyncView(
                    value: assignments,
                    onRetry: () => ref.invalidate(companyAssignmentsProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyMessage: 'No marketplace appointments yet.',
                    builder: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final assignment = list[index];
                        return ListTile(
                          leading: const Icon(Icons.handshake_outlined),
                          title: Text(assignment.driverName ?? 'Driver'),
                          subtitle: Text(assignment.jobTitle ?? ''),
                          trailing: assignment.isActive
                              ? TextButton(
                                  onPressed: () async {
                                    final confirmed = await confirmDialog(
                                      context,
                                      title: 'End appointment?',
                                      message: 'The driver keeps company membership; only this appointment ends.',
                                      confirmLabel: 'End',
                                      destructive: true,
                                    );
                                    if (!confirmed || !context.mounted) return;
                                    try {
                                      await ref
                                          .read(marketplaceServiceProvider)
                                          .endAssignment(assignment.id);
                                      ref.invalidate(
                                        companyAssignmentsProvider,
                                      );
                                      if (context.mounted) {
                                        showSuccessSnack(
                                          context,
                                          'Appointment ended',
                                        );
                                      }
                                    } catch (error) {
                                      if (context.mounted) {
                                        showErrorSnack(context, error);
                                      }
                                    }
                                  },
                                  child: const Text('End'),
                                )
                              : StatusChip(
                                  status: assignment.status,
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

  Future<void> _showAddDriver(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _AddDriverSheet(
          onDone: (name) {
            Navigator.pop(sheetContext);
            ref.invalidate(companyDriversProvider);
            showSuccessSnack(context, '$name added to your company');
          },
        ),
      ),
    );
  }
}

/// Manual driver registration for transporters: drivers who do not use the
/// Driver app still get a company record and an approved membership.
class _AddDriverSheet extends ConsumerStatefulWidget {
  const _AddDriverSheet({required this.onDone});

  final ValueChanged<String> onDone;

  @override
  ConsumerState<_AddDriverSheet> createState() => _AddDriverSheetState();
}

class _AddDriverSheetState extends ConsumerState<_AddDriverSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(fleetServiceProvider)
          .addManualDriver(
            companyId: membership.companyId,
            displayName: _name.text,
            phoneE164: _phone.text.trim().isEmpty ? null : _phone.text,
            localDriverCode: _code.text.trim().isEmpty ? null : _code.text,
          );
      if (mounted) widget.onDone(_name.text.trim());
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add driver manually',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'For drivers who do not use the Driver app. They are added '
                  'to your company with an approved membership.',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  controller: _name,
                  label: 'Driver name',
                  validator: (v) => (v?.trim().length ?? 0) < 2
                      ? 'Enter at least 2 characters'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _phone,
                  label: 'Phone (optional)',
                  hint: '+919876543210',
                  validator: (_) => null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _code,
                  label: 'Local driver code (optional)',
                  hint: 'DRV-001',
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
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(_saving ? 'Adding…' : 'Add driver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _driverSearchProvider =
    FutureProvider.family<List<DriverSearchResult>, String>((ref, query) {
      final parts = query.split('|');
      return ref
          .watch(marketplaceServiceProvider)
          .searchDrivers(
            licenceClass: parts[0].isEmpty ? null : parts[0],
            state: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
          );
    });

/// Verified-driver discovery and direct hiring.
class FindDriversScreen extends ConsumerStatefulWidget {
  const FindDriversScreen({super.key});

  @override
  ConsumerState<FindDriversScreen> createState() => _FindDriversScreenState();
}

class _FindDriversScreenState extends ConsumerState<FindDriversScreen> {
  String _licenceClass = '';
  final _stateController = TextEditingController();
  String _query = '|';

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(_driverSearchProvider(_query));
    return AppScaffold(
      title: 'Find drivers',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _licenceClass,
                    decoration: const InputDecoration(
                      labelText: 'Licence class',
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Any')),
                      DropdownMenuItem(value: 'LMV', child: Text('LMV')),
                      DropdownMenuItem(value: 'MMV', child: Text('MMV')),
                      DropdownMenuItem(value: 'HMV', child: Text('HMV')),
                      DropdownMenuItem(value: 'HMV_PLUS', child: Text('HMV+')),
                      DropdownMenuItem(
                        value: 'TRACTOR_TRAILER',
                        child: Text('Tractor/Trailer'),
                      ),
                      DropdownMenuItem(
                        value: 'HAZARDOUS_GOODS',
                        child: Text('Hazardous'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _licenceClass = v ?? ''),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                    onSubmitted: (_) => setState(
                      () => _query = '$_licenceClass|${_stateController.text}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(
                    () => _query = '$_licenceClass|${_stateController.text}',
                  ),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView(
              value: results,
              onRetry: () => ref.invalidate(_driverSearchProvider(_query)),
              isEmpty: (list) => list.isEmpty,
              emptyMessage: 'No verified drivers match. Only office-verified licences are listed.',
              builder: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final driver = list[index];
                  return ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(driver.displayName),
                    subtitle: Text(
                      [
                        if (driver.licenceClass != null) driver.licenceClass!,
                        if (driver.issuingState != null) driver.issuingState!,
                      ].join(' • '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _unlockContact(driver),
                          child: const Text('Contact ₹100'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _hire(driver),
                          child: const Text('Hire'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockContact(DriverSearchResult driver) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'contact_lookup:${driver.driverAccountId}';
    final idempotencyKey = prefs.getString(key) ?? newId();
    if (!mounted) return;
    final confirmed = await confirmDialog(
      context,
      title: 'Unlock contact?',
      message:
          'A ₹100 lookup charge is recorded to your company. Re-opening this '
          'contact is free because the same request key is reused.',
      confirmLabel: 'Unlock',
    );
    if (!confirmed || !mounted) return;
    try {
      final contact = await ref
          .read(marketplaceServiceProvider)
          .lookupDriverContact(
            driver.driverAccountId,
            idempotencyKey: idempotencyKey,
          );
      await prefs.setString(key, idempotencyKey);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(contact.displayName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                contact.phoneE164 ?? 'No phone number on file',
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                contact.alreadyUnlocked
                    ? 'Previously unlocked • no new charge'
                    : '₹${contact.amountInr.toStringAsFixed(0)} charged to this company',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _hire(DriverSearchResult driver) async {
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    final confirmed = await confirmDialog(
      context,
      title: 'Hire ${driver.displayName}?',
      message:
          'This adds the driver to your company with an approved membership.',
      confirmLabel: 'Hire',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref
          .read(fleetServiceProvider)
          .addCompanyDriver(
            companyId: membership.companyId,
            driverAccountId: driver.driverAccountId,
          );
      ref.invalidate(companyDriversProvider);
      if (mounted) showSuccessSnack(context, '${driver.displayName} hired');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }
}
