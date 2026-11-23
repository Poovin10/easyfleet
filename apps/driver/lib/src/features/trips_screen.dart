import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

final driverTripsProvider = FutureProvider<List<FleetTrip>>((ref) async {
  ref.watch(driverAccountProvider);
  return ref.watch(fleetServiceProvider).myDriverTrips();
});

final driverTripDetailProvider = FutureProvider.family<FleetTrip?, String>((
  ref,
  tripId,
) async {
  return ref.watch(fleetServiceProvider).trip(tripId);
});

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(driverTripsProvider);
    return AppScaffold(
      title: 'Trips & logbook',
      body: AsyncView(
        value: trips,
        onRetry: () => ref.invalidate(driverTripsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No trips assigned yet.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(driverTripsProvider),
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
                        if (trip.companyName != null) trip.companyName!,
                        if (trip.vehicleNumber != null) trip.vehicleNumber!,
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
}

final _tripFuelProvider = FutureProvider.family<List<FuelEntry>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).fuelEntries(tripId);
});

final _tripExpensesProvider = FutureProvider.family<List<ExpenseEntry>, String>(
  (ref, tripId) {
    return ref.watch(fleetServiceProvider).expenseEntries(tripId);
  },
);

final _tripHistoryProvider = FutureProvider.family<List<AuditEvent>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).tripHistory(tripId);
});

final _tripClosuresProvider = FutureProvider.family<List<TripClosure>, String>((
  ref,
  tripId,
) {
  return ref.watch(fleetServiceProvider).closuresForTrip(tripId);
});

class DriverTripDetailScreen extends ConsumerStatefulWidget {
  const DriverTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<DriverTripDetailScreen> createState() =>
      _DriverTripDetailScreenState();
}

class _DriverTripDetailScreenState
    extends ConsumerState<DriverTripDetailScreen> {
  bool _busy = false;

  void _invalidateAll() {
    ref.invalidate(driverTripDetailProvider(widget.tripId));
    ref.invalidate(driverTripsProvider);
    ref.invalidate(_tripFuelProvider(widget.tripId));
    ref.invalidate(_tripExpensesProvider(widget.tripId));
    ref.invalidate(_tripHistoryProvider(widget.tripId));
    ref.invalidate(_tripClosuresProvider(widget.tripId));
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

  Future<void> _startTrip(FleetTrip trip) async {
    final controller = TextEditingController(
      text: trip.startingOdometerKm?.toString() ?? '',
    );
    final odometer = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start trip'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Starting odometer (km)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (odometer == null && !mounted) return;
    await _run(
      () => ref
          .read(fleetServiceProvider)
          .startTrip(
            companyId: trip.companyId,
            tripId: trip.id,
            startingOdometerKm: odometer,
          ),
      'Trip started',
    );
  }

  Future<void> _showEntrySheet(FleetTrip trip) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _EntrySheet(
          trip: trip,
          onDone: (message) {
            Navigator.pop(sheetContext);
            _invalidateAll();
            showSuccessSnack(context, message);
          },
        ),
      ),
    );
  }

  Future<void> _showClosureSheet(FleetTrip trip) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _ClosureSheet(
          trip: trip,
          onDone: () {
            Navigator.pop(sheetContext);
            _invalidateAll();
            showSuccessSnack(context, 'Closure submitted for review');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(driverTripDetailProvider(widget.tripId));
    final fuel = ref.watch(_tripFuelProvider(widget.tripId));
    final expenses = ref.watch(_tripExpensesProvider(widget.tripId));
    final history = ref.watch(_tripHistoryProvider(widget.tripId));
    final closures = ref.watch(_tripClosuresProvider(widget.tripId));

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
                        if (trip.companyName != null) trip.companyName!,
                        if (trip.vehicleNumber != null) trip.vehicleNumber!,
                        if (trip.gcNumber != null) 'GC ${trip.gcNumber}',
                      ].join(' • '),
                    ),
                    if (trip.material != null)
                      Text('Material: ${trip.material}'),
                    if (trip.tonnes != null) Text('Load: ${trip.tonnes} t'),
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
                    if (trip.isAssigned)
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _startTrip(trip),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start trip'),
                      ),
                    if (trip.isInTransit) ...[
                      FilledButton.tonalIcon(
                        onPressed: _busy ? null : () => _showEntrySheet(trip),
                        icon: const Icon(Icons.add),
                        label: const Text('Add entry'),
                      ),
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _showClosureSheet(trip),
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Deliver / POD'),
                      ),
                    ],
                    if (trip.isActive)
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.liveTracking),
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('Tracking'),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Fuel & AdBlue'),
              AsyncView(
                value: fuel,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No fuel entries yet.',
                builder: (list) => Column(
                  children: [
                    for (final entry in list)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          entry.fuelType == 'ADBLUE'
                              ? Icons.water_drop_outlined
                              : Icons.local_gas_station,
                        ),
                        title: Text(
                          '${entry.fuelType} • ${entry.litres} L • ₹${entry.amount}',
                        ),
                        subtitle: Text(entry.pumpName ?? ''),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Expenses'),
              AsyncView(
                value: expenses,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No expenses yet.',
                builder: (list) => Column(
                  children: [
                    for (final entry in list)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text('${entry.category} • ₹${entry.amount}'),
                        subtitle: Text(entry.description ?? ''),
                        trailing: StatusChip(
                          status: entry.approvalStatus,
                          dense: true,
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Closures'),
              AsyncView(
                value: closures,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No closure submitted yet.',
                builder: (list) => Column(
                  children: [
                    for (final closure in list)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.fact_check_outlined),
                        title: Text(
                          'Submission #${closure.submissionNumber} • bata ₹${closure.bataEarned}',
                        ),
                        subtitle: Text(closure.reviewerNote ?? ''),
                        trailing: StatusChip(
                          status: closure.status,
                          dense: true,
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Logbook'),
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

/// Fuel / expense / breakdown entry sheet. Writes go to the offline outbox
/// with idempotency keys and are flushed immediately when online.
class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.trip, required this.onDone});

  final FleetTrip trip;
  final void Function(String message) onDone;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  final _formKey = GlobalKey<FormState>();
  String _kind = 'FUEL';
  String _fuelType = 'DIESEL';
  String _category = 'TOLL';
  final _litres = TextEditingController();
  final _rate = TextEditingController();
  final _amount = TextEditingController();
  final _pump = TextEditingController();
  final _odometer = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _litres.dispose();
    _rate.dispose();
    _amount.dispose();
    _pump.dispose();
    _odometer.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repository = await ref.read(outboxRepositoryProvider.future);
      final key = newId();
      final entryId = newId();
      final odometer = int.tryParse(_odometer.text.trim());
      late final OutboxEntry entry;
      late final String message;
      switch (_kind) {
        case 'FUEL':
          final litres = double.parse(_litres.text.trim());
          final rate = double.tryParse(_rate.text.trim());
          final amount =
              double.tryParse(_amount.text.trim()) ??
              (rate != null ? rate * litres : 0);
          entry = OutboxEntry(
            id: null,
            table: OutboxTargets.fuelEntry,
            operation: OutboxOperation.insert,
            idempotencyKey: key,
            createdAt: DateTime.now(),
            payload: {
              'p_company_id': widget.trip.companyId,
              'p_trip_id': widget.trip.id,
              'p_entry_id': entryId,
              'p_fuel_type': _fuelType,
              'p_litres': litres,
              'p_amount': amount,
              'p_idempotency_key': key,
              'p_rate_per_litre': rate,
              'p_pump_name': _pump.text.trim().isEmpty
                  ? null
                  : _pump.text.trim(),
              'p_odometer_km': odometer,
            },
          );
          message = 'Fuel entry saved';
        case 'EXPENSE':
          entry = OutboxEntry(
            id: null,
            table: OutboxTargets.expenseEntry,
            operation: OutboxOperation.insert,
            idempotencyKey: key,
            createdAt: DateTime.now(),
            payload: {
              'p_company_id': widget.trip.companyId,
              'p_trip_id': widget.trip.id,
              'p_entry_id': entryId,
              'p_category': _category,
              'p_amount': double.parse(_amount.text.trim()),
              'p_idempotency_key': key,
              'p_description': _description.text.trim().isEmpty
                  ? null
                  : _description.text.trim(),
              'p_odometer_km': odometer,
            },
          );
          message = 'Expense saved';
        default:
          entry = OutboxEntry(
            id: null,
            table: OutboxTargets.breakdown,
            operation: OutboxOperation.insert,
            idempotencyKey: key,
            createdAt: DateTime.now(),
            payload: {
              'p_company_id': widget.trip.companyId,
              'p_trip_id': widget.trip.id,
              'p_job_id': entryId,
              'p_issue_description': _description.text.trim(),
              'p_idempotency_key': key,
              'p_odometer_km': odometer,
            },
          );
          message = 'Breakdown reported';
      }
      await repository.enqueue(entry);
      await ref.read(syncControllerProvider.notifier).flushNow();
      widget.onDone(message);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Add trip entry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'FUEL', label: Text('Fuel')),
                  ButtonSegment(value: 'EXPENSE', label: Text('Expense')),
                  ButtonSegment(value: 'BREAKDOWN', label: Text('Breakdown')),
                ],
                selected: {_kind},
                onSelectionChanged: (value) =>
                    setState(() => _kind = value.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_kind == 'FUEL') ...[
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'DIESEL', label: Text('Diesel')),
                    ButtonSegment(value: 'ADBLUE', label: Text('AdBlue')),
                  ],
                  selected: {_fuelType},
                  onSelectionChanged: (value) =>
                      setState(() => _fuelType = value.first),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextFormField(
                  controller: _litres,
                  label: 'Litres',
                  decimal: true,
                  validator: (v) => positiveNumberValidator(v),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _rate,
                  label: 'Rate per litre (optional)',
                  decimal: true,
                  validator: optionalNumberValidator,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _amount,
                  label: 'Total amount (optional if rate given)',
                  decimal: true,
                  validator: (v) {
                    if ((v == null || v.trim().isEmpty) &&
                        _rate.text.trim().isEmpty) {
                      return 'Enter amount or rate';
                    }
                    return optionalNumberValidator(v);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _pump,
                  label: 'Pump name (optional)',
                  validator: (_) => null,
                ),
              ] else if (_kind == 'EXPENSE') ...[
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      const [
                            'TOLL',
                            'FOOD',
                            'LOADING',
                            'UNLOADING',
                            'PARKING',
                            'REPAIR',
                            'OTHER',
                          ]
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _category = v ?? 'TOLL'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _amount,
                  label: 'Amount (₹)',
                  decimal: true,
                  validator: (v) => positiveNumberValidator(v, allowZero: true),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _description,
                  label: 'Description (optional)',
                  validator: (_) => null,
                ),
              ] else ...[
                AppTextFormField(
                  controller: _description,
                  label: 'What happened?',
                  maxLines: 3,
                ),
              ],
              if (_kind != 'BREAKDOWN') ...[
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _odometer,
                  label: 'Odometer km (optional)',
                  numeric: true,
                  validator: optionalNumberValidator,
                ),
              ],
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
                label: Text(_saving ? 'Saving…' : 'Save entry'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// POD / delivery closure sheet with photo upload.
class _ClosureSheet extends ConsumerStatefulWidget {
  const _ClosureSheet({required this.trip, required this.onDone});

  final FleetTrip trip;
  final VoidCallback onDone;

  @override
  ConsumerState<_ClosureSheet> createState() => _ClosureSheetState();
}

class _ClosureSheetState extends ConsumerState<_ClosureSheet> {
  final _formKey = GlobalKey<FormState>();
  final _closingOdometer = TextEditingController();
  final _distance = TextEditingController();
  final _bataEarned = TextEditingController();
  final _notes = TextEditingController();
  bool _deliveryConfirmed = true;
  bool _saving = false;
  String? _podPath;

  @override
  void dispose() {
    _closingOdometer.dispose();
    _distance.dispose();
    _bataEarned.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _attachPod() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() => _saving = true);
      final documents = ref.read(documentServiceProvider);
      final path = documents.podPath(
        companyId: widget.trip.companyId,
        tripId: widget.trip.id,
        filename: 'pod-${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await documents.upload(path: path, bytes: await file.readAsBytes());
      if (mounted) {
        setState(() => _podPath = path);
        showSuccessSnack(context, 'POD photo uploaded');
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(fleetServiceProvider)
          .submitClosure(
            companyId: widget.trip.companyId,
            tripId: widget.trip.id,
            closingOdometerKm: int.tryParse(_closingOdometer.text.trim()),
            actualDistanceKm: double.tryParse(_distance.text.trim()),
            bataEarned: double.tryParse(_bataEarned.text.trim()) ?? 0,
            bataAdvance: widget.trip.bataAdvance,
            deliveryConfirmed: _deliveryConfirmed,
            podObjectPath: _podPath,
            closureNotes: _notes.text.trim().isEmpty
                ? null
                : _notes.text.trim(),
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
                'Delivery & POD',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(
                controller: _closingOdometer,
                label: 'Closing odometer (km)',
                numeric: true,
                validator: optionalNumberValidator,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _distance,
                label: 'Actual distance (km, optional)',
                decimal: true,
                validator: optionalNumberValidator,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _bataEarned,
                label: 'Bata earned (₹)',
                decimal: true,
                validator: (v) => positiveNumberValidator(v, allowZero: true),
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Delivery confirmed by receiver'),
                value: _deliveryConfirmed,
                onChanged: (v) => setState(() => _deliveryConfirmed = v),
              ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _attachPod,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(
                  _podPath == null ? 'Attach POD photo' : 'POD attached ✓',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _notes,
                label: 'Notes (optional)',
                maxLines: 2,
                validator: (_) => null,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flag_outlined),
                label: Text(_saving ? 'Submitting…' : 'Submit closure'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
