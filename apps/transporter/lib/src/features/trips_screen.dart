import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'company_gate.dart';
import 'drivers_screen.dart';
import 'vehicles_screen.dart';

final companyTripsProvider = FutureProvider<List<FleetTrip>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(fleetServiceProvider).companyTrips(membership.companyId);
});

final transporterTripDetailProvider = FutureProvider.family<FleetTrip?, String>(
  (ref, tripId) {
    return ref.watch(fleetServiceProvider).trip(tripId);
  },
);

class TransporterTripsScreen extends ConsumerWidget {
  const TransporterTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(companyTripsProvider);
    return AppScaffold(
      title: 'Trips',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New trip'),
      ),
      body: AsyncView(
        value: trips,
        onRetry: () => ref.invalidate(companyTripsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No trips yet. Create one to get started.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(companyTripsProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final trip = list[index];
              return AppSectionCard(
                onTap: () => context.push('/trips/${trip.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${trip.origin} → ${trip.destination}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(status: trip.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (trip.vehicleNumber != null) trip.vehicleNumber!,
                        if (trip.driverName != null) trip.driverName!,
                        if (trip.gcNumber != null) 'GC ${trip.gcNumber}',
                        if (trip.scheduledDate != null)
                          trip.scheduledDate!
                              .toIso8601String()
                              .split('T')
                              .first,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _CreateTripSheet(
          onDone: (tripId) {
            Navigator.pop(sheetContext);
            ref.invalidate(companyTripsProvider);
            showSuccessSnack(context, 'Trip created');
            context.push('/trips/$tripId');
          },
        ),
      ),
    );
  }
}

class _CreateTripSheet extends ConsumerStatefulWidget {
  const _CreateTripSheet({required this.onDone});

  final void Function(String tripId) onDone;

  @override
  ConsumerState<_CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends ConsumerState<_CreateTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _gcNumber = TextEditingController();
  final _material = TextEditingController();
  final _tonnes = TextEditingController();
  final _freight = TextEditingController();
  final _bataAdvance = TextEditingController(text: '0');
  final _distance = TextEditingController();
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  String? _vehicleId;
  String? _companyDriverId;
  String? _driverAccountId;
  bool _saving = false;

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _gcNumber.dispose();
    _material.dispose();
    _tonnes.dispose();
    _freight.dispose();
    _bataAdvance.dispose();
    _distance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    setState(() => _saving = true);
    try {
      final tripId = await ref
          .read(fleetServiceProvider)
          .createTrip(
            companyId: membership.companyId,
            origin: _origin.text,
            destination: _destination.text,
            scheduledDate: _scheduledDate,
            vehicleId: _vehicleId,
            companyDriverId: _companyDriverId,
            driverAccountId: _driverAccountId,
            gcNumber: _gcNumber.text.trim().isEmpty
                ? null
                : _gcNumber.text.trim(),
            material: _material.text.trim().isEmpty
                ? null
                : _material.text.trim(),
            tonnes: double.tryParse(_tonnes.text.trim()),
            freightRate: double.tryParse(_freight.text.trim()),
            bataAdvance: double.tryParse(_bataAdvance.text.trim()) ?? 0,
            plannedDistanceKm: double.tryParse(_distance.text.trim()),
          );
      widget.onDone(tripId);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);
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
                'Create trip',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _origin,
                      label: 'Origin',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _destination,
                      label: 'Destination',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  'Scheduled: ${_scheduledDate.toIso8601String().split('T').first}',
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _scheduledDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _scheduledDate = picked);
                },
              ),
              AsyncView(
                value: vehicles,
                builder: (list) => DropdownButtonFormField<String?>(
                  initialValue: _vehicleId,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle (optional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    for (final vehicle in list.where(
                      (v) => v.status == 'AVAILABLE',
                    ))
                      DropdownMenuItem(
                        value: vehicle.id,
                        child: Text(vehicle.registrationNumber),
                      ),
                  ],
                  onChanged: (v) => setState(() => _vehicleId = v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AsyncView(
                value: drivers,
                builder: (list) => DropdownButtonFormField<String?>(
                  initialValue: _companyDriverId,
                  decoration: const InputDecoration(
                    labelText: 'Driver (optional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    for (final driver in list.where(
                      (d) => d.membershipStatus == 'APPROVED',
                    ))
                      DropdownMenuItem(
                        value: driver.id,
                        child: Text(
                          driver.displayName ?? driver.localDriverCode,
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _companyDriverId = v;
                      _driverAccountId = v == null
                          ? null
                          : list.firstWhere((d) => d.id == v).driverAccountId;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _gcNumber,
                      label: 'GC number (optional)',
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _material,
                      label: 'Material (optional)',
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _tonnes,
                      label: 'Tonnes (optional)',
                      decimal: true,
                      validator: optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _freight,
                      label: 'Freight ₹ (optional)',
                      decimal: true,
                      validator: optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _bataAdvance,
                      label: 'Bata advance ₹',
                      decimal: true,
                      validator: (v) =>
                          positiveNumberValidator(v, allowZero: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _distance,
                      label: 'Distance km (optional)',
                      decimal: true,
                      validator: optionalNumberValidator,
                    ),
                  ),
                ],
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
                    : const Icon(Icons.add_road),
                label: Text(_saving ? 'Creating…' : 'Create trip'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

final _tripClosuresProvider = FutureProvider.family<List<TripClosure>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).closuresForTrip(tripId);
});

final _tripExpensesProvider = FutureProvider.family<List<ExpenseEntry>, String>(
  (ref, tripId) {
    return ref.watch(fleetServiceProvider).expenseEntries(tripId);
  },
);

final _tripFuelProvider = FutureProvider.family<List<FuelEntry>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).fuelEntries(tripId);
});

final _tripHistoryProvider = FutureProvider.family<List<AuditEvent>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).tripHistory(tripId);
});

class TransporterTripDetailScreen extends ConsumerStatefulWidget {
  const TransporterTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TransporterTripDetailScreen> createState() =>
      _TransporterTripDetailScreenState();
}

class _TransporterTripDetailScreenState
    extends ConsumerState<TransporterTripDetailScreen> {
  bool _busy = false;

  void _invalidateAll() {
    ref.invalidate(transporterTripDetailProvider(widget.tripId));
    ref.invalidate(companyTripsProvider);
    ref.invalidate(_tripClosuresProvider(widget.tripId));
    ref.invalidate(_tripExpensesProvider(widget.tripId));
    ref.invalidate(_tripFuelProvider(widget.tripId));
    ref.invalidate(_tripHistoryProvider(widget.tripId));
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      _invalidateAll();
      if (mounted) showSuccessSnack(context, success);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(FleetTrip trip) async {
    final controller = TextEditingController();
    final reason = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel trip'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Cancel trip'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    await _run(
      () => ref
          .read(fleetServiceProvider)
          .cancelTrip(
            companyId: trip.companyId,
            tripId: trip.id,
            reason: reason,
          ),
      'Trip cancelled',
    );
  }

  Future<void> _reviewClosure(TripClosure closure, bool approve) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve closure' : 'Reject closure'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reviewer note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    final note = controller.text.trim();
    controller.dispose();
    if (confirmed != true) return;
    await _run(
      () => ref
          .read(fleetServiceProvider)
          .reviewClosure(
            companyId: closure.companyId,
            closureId: closure.id,
            decision: approve ? 'APPROVED' : 'REJECTED',
            reviewerNote: note.isEmpty ? null : note,
          ),
      approve ? 'Closure approved — trip completed' : 'Closure rejected',
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(transporterTripDetailProvider(widget.tripId));
    final closures = ref.watch(_tripClosuresProvider(widget.tripId));
    final expenses = ref.watch(_tripExpensesProvider(widget.tripId));
    final fuel = ref.watch(_tripFuelProvider(widget.tripId));
    final history = ref.watch(_tripHistoryProvider(widget.tripId));

    return AppScaffold(
      title: 'Trip details',
      body: AsyncView(
        value: trip,
        onRetry: _invalidateAll,
        builder: (trip) {
          if (trip == null) return const EmptyView(message: 'Trip not found');
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${trip.origin} → ${trip.destination}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        StatusChip(status: trip.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      [
                        if (trip.vehicleNumber != null) trip.vehicleNumber!,
                        if (trip.driverName != null) trip.driverName!,
                        if (trip.gcNumber != null) 'GC ${trip.gcNumber}',
                      ].join(' • '),
                    ),
                    if (trip.material != null)
                      Text('Material: ${trip.material}'),
                    if (trip.freightRate != null)
                      Text('Freight: ₹${trip.freightRate}'),
                    Text('Bata advance: ₹${trip.bataAdvance}'),
                    if (trip.cancellationReason != null)
                      Text(
                        'Cancelled: ${trip.cancellationReason}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: LinearProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (trip.status == 'PLANNED' || trip.isAssigned)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: _busy ? null : () => _cancel(trip),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel trip'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/fleet-map'),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Fleet map'),
                    ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Closures / POD'),
              AsyncView(
                value: closures,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No closure submitted yet.',
                builder: (list) => Column(
                  children: [
                    for (final closure in list)
                      AppSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Submission #${closure.submissionNumber}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                                StatusChip(status: closure.status),
                              ],
                            ),
                            Text(
                              'Bata earned ₹${closure.bataEarned} • advance ₹${closure.bataAdvance}',
                            ),
                            if (closure.closingOdometerKm != null)
                              Text(
                                'Closing odometer: ${closure.closingOdometerKm} km',
                              ),
                            if (closure.deliveryConfirmed)
                              const Text('Delivery confirmed ✓'),
                            if (closure.podObjectPath != null)
                              _PodViewer(path: closure.podObjectPath!),
                            if (closure.reviewerNote != null)
                              Text('Note: ${closure.reviewerNote}'),
                            if (closure.status == 'SUBMITTED')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _reviewClosure(closure, false),
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  FilledButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _reviewClosure(closure, true),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Expenses'),
              AsyncView(
                value: expenses,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No expenses recorded.',
                builder: (list) => Column(
                  children: [
                    for (final entry in list)
                      ListTile(
                        dense: true,
                        title: Text('${entry.category} • ₹${entry.amount}'),
                        subtitle: Text(entry.description ?? ''),
                        trailing: entry.approvalStatus == 'PENDING'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Reject',
                                    onPressed: () => _run(
                                      () => ref
                                          .read(fleetServiceProvider)
                                          .reviewExpense(
                                            companyId: trip.companyId,
                                            entryId: entry.id,
                                            decision: 'REJECTED',
                                          ),
                                      'Expense rejected',
                                    ),
                                    icon: const Icon(Icons.close, size: 18),
                                  ),
                                  IconButton(
                                    tooltip: 'Approve',
                                    onPressed: () => _run(
                                      () => ref
                                          .read(fleetServiceProvider)
                                          .reviewExpense(
                                            companyId: trip.companyId,
                                            entryId: entry.id,
                                            decision: 'APPROVED',
                                          ),
                                      'Expense approved',
                                    ),
                                    icon: const Icon(Icons.check, size: 18),
                                  ),
                                ],
                              )
                            : StatusChip(
                                status: entry.approvalStatus,
                                dense: true,
                              ),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Fuel'),
              AsyncView(
                value: fuel,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No fuel entries.',
                builder: (list) => Column(
                  children: [
                    for (final entry in list)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.local_gas_station),
                        title: Text(
                          '${entry.fuelType} • ${entry.litres} L • ₹${entry.amount}',
                        ),
                        subtitle: Text(entry.pumpName ?? ''),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Audit history'),
              AsyncView(
                value: history,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No events recorded.',
                builder: (list) => Column(
                  children: [
                    for (final event in list)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 20),
                        title: Text(StatusChip.label(event.eventType)),
                        subtitle: Text(
                          event.eventTime.toLocal().toString().split('.').first,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

/// Shows a private POD document via a short-lived signed URL.
class _PodViewer extends ConsumerStatefulWidget {
  const _PodViewer({required this.path});

  final String path;

  @override
  ConsumerState<_PodViewer> createState() => _PodViewerState();
}

class _PodViewerState extends ConsumerState<_PodViewer> {
  String? _url;
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final url = await ref
          .read(documentServiceProvider)
          .signedUrl(widget.path);
      if (mounted) setState(() => _url = url);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_url != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.network(
            _url!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Text('POD image unavailable'),
          ),
        ),
      );
    }
    return TextButton.icon(
      onPressed: _loading ? null : _load,
      icon: _loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.image_outlined),
      label: const Text('View POD document'),
    );
  }
}
