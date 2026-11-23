import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'company_gate.dart';

final vehicleDocumentsProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({String companyId, String vehicleId})
    >((ref, args) async {
      return ref
          .watch(fleetServiceProvider)
          .vehicleDocuments(args.companyId, args.vehicleId);
    });

final vehiclesProvider = FutureProvider<List<FleetVehicle>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(fleetServiceProvider).vehicles(membership.companyId);
});

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    return AppScaffold(
      title: 'Vehicles',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicle(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
      ),
      body: AsyncView(
        value: vehicles,
        onRetry: () => ref.invalidate(vehiclesProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No vehicles registered yet.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(vehiclesProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final vehicle = list[index];
              return ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(vehicle.registrationNumber),
                subtitle: Text(
                  [
                    vehicle.vehicleType,
                    if (vehicle.make != null) vehicle.make!,
                    if (vehicle.odometerKm != null) '${vehicle.odometerKm} km',
                  ].join(' • '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Compliance documents',
                      icon: const Icon(Icons.description_outlined),
                      onPressed: () => _showDocuments(context, ref, vehicle),
                    ),
                    StatusChip(status: vehicle.status, dense: true),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDocuments(
    BuildContext context,
    WidgetRef ref,
    FleetVehicle vehicle,
  ) async {
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _VehicleDocumentsSheet(
        companyId: membership.companyId,
        vehicle: vehicle,
      ),
    );
  }

  Future<void> _showAddVehicle(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _AddVehicleSheet(
          onDone: () {
            Navigator.pop(sheetContext);
            ref.invalidate(vehiclesProvider);
            showSuccessSnack(context, 'Vehicle registered');
          },
        ),
      ),
    );
  }
}

class _AddVehicleSheet extends ConsumerStatefulWidget {
  const _AddVehicleSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _registration = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _capacity = TextEditingController();
  final _odometer = TextEditingController();
  String _type = 'TRUCK';
  bool _saving = false;

  @override
  void dispose() {
    _registration.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _capacity.dispose();
    _odometer.dispose();
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
          .createVehicle(
            companyId: membership.companyId,
            registrationNumber: _registration.text,
            vehicleType: _type,
            make: _make.text.trim().isEmpty ? null : _make.text.trim(),
            model: _model.text.trim().isEmpty ? null : _model.text.trim(),
            manufacturingYear: int.tryParse(_year.text.trim()),
            capacityTonnes: double.tryParse(_capacity.text.trim()),
            odometerKm: int.tryParse(_odometer.text.trim()),
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
                'Register vehicle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(
                controller: _registration,
                label: 'Registration number',
                hint: 'KL01AB1234',
                validator: (v) => (v?.trim().length ?? 0) < 3
                    ? 'Enter a valid registration'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Vehicle type'),
                items:
                    const [
                          'TRUCK',
                          'TRAILER',
                          'TANKER',
                          'CONTAINER',
                          'VAN',
                          'OTHER',
                        ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => setState(() => _type = v ?? 'TRUCK'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _make,
                      label: 'Make (optional)',
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _model,
                      label: 'Model (optional)',
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
                      controller: _year,
                      label: 'Year (optional)',
                      numeric: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final year = int.tryParse(v.trim());
                        if (year == null || year < 1950 || year > 2100) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _capacity,
                      label: 'Capacity t (optional)',
                      decimal: true,
                      validator: optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _odometer,
                label: 'Odometer km (optional)',
                numeric: true,
                validator: optionalNumberValidator,
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
                label: Text(_saving ? 'Saving…' : 'Register vehicle'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

const _documentTypes = [
  'rc',
  'insurance',
  'fitness',
  'permit',
  'puc',
  'tax',
  'other',
];

/// Compliance documents for one vehicle: private Storage upload followed by
/// a metadata registration through the server-validated RPC.
class _VehicleDocumentsSheet extends ConsumerStatefulWidget {
  const _VehicleDocumentsSheet({
    required this.companyId,
    required this.vehicle,
  });

  final String companyId;
  final FleetVehicle vehicle;

  @override
  ConsumerState<_VehicleDocumentsSheet> createState() =>
      _VehicleDocumentsSheetState();
}

class _VehicleDocumentsSheetState
    extends ConsumerState<_VehicleDocumentsSheet> {
  String _type = 'rc';
  bool _uploading = false;

  Future<void> _upload() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final args = (companyId: widget.companyId, vehicleId: widget.vehicle.id);
    setState(() => _uploading = true);
    try {
      final documents = ref.read(documentServiceProvider);
      final path = documents.vehicleDocumentPath(
        companyId: widget.companyId,
        vehicleId: widget.vehicle.id,
        kind: _type,
        filename: '${_type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await documents.upload(path: path, bytes: await file.readAsBytes());
      await ref
          .read(fleetServiceProvider)
          .addVehicleDocument(
            companyId: widget.companyId,
            vehicleId: widget.vehicle.id,
            documentType: _type,
            storageObjectPath: path,
            documentNumber: widget.vehicle.registrationNumber,
          );
      ref.invalidate(vehicleDocumentsProvider(args));
      if (mounted) showSuccessSnack(context, 'Vehicle document uploaded');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (companyId: widget.companyId, vehicleId: widget.vehicle.id);
    final documents = ref.watch(vehicleDocumentsProvider(args));
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Documents · ${widget.vehicle.registrationNumber}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Document type'),
              items: _documentTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? 'rc'),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _uploading ? 'Uploading…' : 'Upload ${_type.toUpperCase()}',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncView(
                value: documents,
                onRetry: () => ref.invalidate(vehicleDocumentsProvider(args)),
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'No compliance documents uploaded yet.',
                builder: (list) => ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final document = list[index];
                    final expiry = document['expiry_date']?.toString();
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(document['document_type']?.toString() ?? ''),
                      subtitle: Text(
                        [
                          document['document_number']?.toString() ?? '',
                          if (expiry != null) 'Expires $expiry',
                        ].where((s) => s.isNotEmpty).join(' • '),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
