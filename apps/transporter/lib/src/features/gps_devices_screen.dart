import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'company_gate.dart';
import 'vehicles_screen.dart';

final _providersProvider = FutureProvider<List<GpsProvider>>((ref) {
  return ref.watch(gpsDeviceServiceProvider).providers();
});

final _credentialsProvider = FutureProvider<List<GpsCredential>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(gpsDeviceServiceProvider).credentials(membership.companyId);
});

final gpsDevicesProvider = FutureProvider<List<GpsDevice>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref.watch(gpsDeviceServiceProvider).devices(membership.companyId);
});

/// GPS device registry: provider credentials, device registration,
/// vehicle assignment and provider sync.
class GpsDevicesScreen extends ConsumerWidget {
  const GpsDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(gpsDevicesProvider);
    final credentials = ref.watch(_credentialsProvider);
    return AppScaffold(
      title: 'Truck GPS devices',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Register device'),
      ),
      body: ListView(
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Provider credentials',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCredentialsSheet(context, ref),
                      icon: const Icon(Icons.key_outlined, size: 18),
                      label: const Text('Configure'),
                    ),
                  ],
                ),
                Text(
                  'Each transporter uses its own GPS provider account. '
                  'Credentials are encrypted server-side and never shared '
                  'between companies.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AsyncView(
                  value: credentials,
                  isEmpty: (list) => list.isEmpty,
                  emptyMessage: 'No provider credentials configured yet.',
                  builder: (list) => Column(
                    children: [
                      for (final credential in list)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.vpn_key_outlined),
                          title: Text(
                            '${credential.providerId} • ${credential.label}',
                          ),
                          subtitle: Text(
                            credential.config['base_url'] as String? ??
                                'base URL not set',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Devices'),
          AsyncView(
            value: devices,
            onRetry: () => ref.invalidate(gpsDevicesProvider),
            isEmpty: (list) => list.isEmpty,
            emptyMessage: 'No GPS devices registered yet.',
            builder: (list) => Column(
              children: [
                for (final device in list) _DeviceCard(device: device),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _showCredentialsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _CredentialsSheet(
          onDone: () {
            Navigator.pop(sheetContext);
            ref.invalidate(_credentialsProvider);
            showSuccessSnack(context, 'Provider credentials saved');
          },
        ),
      ),
    );
  }

  Future<void> _showRegisterSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _RegisterDeviceSheet(
          onDone: () {
            Navigator.pop(sheetContext);
            ref.invalidate(gpsDevicesProvider);
            showSuccessSnack(context, 'Device registered');
          },
        ),
      ),
    );
  }
}

class _DeviceCard extends ConsumerStatefulWidget {
  const _DeviceCard({required this.device});

  final GpsDevice device;

  @override
  ConsumerState<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends ConsumerState<_DeviceCard> {
  bool _syncing = false;

  Future<void> _sync() async {
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    setState(() => _syncing = true);
    try {
      final inserted = await ref
          .read(gpsDeviceServiceProvider)
          .syncDevice(
            companyId: membership.companyId,
            device: widget.device,
            since: widget.device.lastSeenAt,
          );
      ref.invalidate(gpsDevicesProvider);
      if (mounted) {
        showSuccessSnack(
          context,
          inserted > 0
              ? '$inserted new position(s) synced'
              : 'No new positions from provider',
        );
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _assign() async {
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    final vehicles = await ref
        .read(fleetServiceProvider)
        .vehicles(membership.companyId);
    if (!mounted) return;
    final vehicleId = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Assign to vehicle'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Unbind device'),
          ),
          for (final vehicle in vehicles)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, vehicle.id),
              child: Text(vehicle.registrationNumber),
            ),
        ],
      ),
    );
    if (vehicleId == null || !mounted) return;
    try {
      await ref
          .read(gpsDeviceServiceProvider)
          .assignDevice(
            companyId: membership.companyId,
            deviceId: widget.device.id,
            vehicleId: vehicleId.isEmpty ? null : vehicleId,
          );
      ref.invalidate(gpsDevicesProvider);
      ref.invalidate(vehiclesProvider);
      if (mounted) showSuccessSnack(context, 'Device assignment updated');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final stale = device.isStale;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  device.label ?? device.externalDeviceId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusChip(
                status: stale && device.status == 'ACTIVE'
                    ? 'OFFLINE'
                    : device.status,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [
              device.providerId,
              'ID ${device.externalDeviceId}',
              if (device.imei != null) 'IMEI ${device.imei}',
              if (device.vehicleNumber != null)
                'Vehicle ${device.vehicleNumber}'
              else
                'Unbound',
            ].join(' • '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (device.lastSeenAt != null)
            Text(
              'Last position: ${device.lastSeenAt!.toLocal().toString().split('.').first}'
              '${stale ? ' (stale)' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _assign,
                child: const Text('Assign vehicle'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: _syncing || device.credentialId == null
                    ? null
                    : _sync,
                icon: _syncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: Text(_syncing ? 'Syncing…' : 'Sync now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CredentialsSheet extends ConsumerStatefulWidget {
  const _CredentialsSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_CredentialsSheet> createState() => _CredentialsSheetState();
}

class _CredentialsSheetState extends ConsumerState<_CredentialsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController(text: 'default');
  final _baseUrl = TextEditingController();
  final _positionsPath = TextEditingController(text: '/positions');
  final Map<String, TextEditingController> _secretControllers = {};
  String _providerId = 'generic_http_json';
  String _authStyle = 'bearer';
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _baseUrl.dispose();
    _positionsPath.dispose();
    for (final controller in _secretControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    setState(() => _saving = true);
    try {
      final credentials = <String, dynamic>{
        for (final entry in _secretControllers.entries)
          if (entry.value.text.trim().isNotEmpty)
            entry.key: entry.value.text.trim(),
      };
      if (credentials.isEmpty) {
        throw StateError('Enter at least one credential value');
      }
      await ref
          .read(gpsDeviceServiceProvider)
          .saveCredentials(
            companyId: membership.companyId,
            providerId: _providerId,
            label: _label.text.trim().isEmpty ? 'default' : _label.text.trim(),
            credentials: credentials,
            config: {
              'base_url': _baseUrl.text.trim(),
              'positions_path': _positionsPath.text.trim(),
              'auth_style': _authStyle,
            },
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
    final providers = ref.watch(_providersProvider);
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
                'GPS provider credentials',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AsyncView(
                value: providers,
                builder: (list) {
                  final provider = list.isEmpty
                      ? null
                      : list.firstWhere(
                          (p) => p.id == _providerId,
                          orElse: () => list.first,
                        );
                  // Build secret field controllers from the provider schema.
                  for (final field in provider?.credentialFields ?? []) {
                    final key = field['key'] as String;
                    _secretControllers.putIfAbsent(
                      key,
                      () => TextEditingController(),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _providerId,
                        decoration: const InputDecoration(
                          labelText: 'Provider',
                        ),
                        items: [
                          for (final p in list)
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(p.displayName),
                            ),
                        ],
                        onChanged: (v) => setState(
                          () => _providerId = v ?? 'generic_http_json',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextFormField(
                        controller: _baseUrl,
                        label: 'API base URL',
                        hint: 'https://gps.yourprovider.com',
                        validator: (v) =>
                            (v == null || !v.trim().startsWith('http'))
                            ? 'Enter a valid https URL'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextFormField(
                        controller: _positionsPath,
                        label: 'Positions path',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        initialValue: _authStyle,
                        decoration: const InputDecoration(
                          labelText: 'Auth style',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'bearer',
                            child: Text('Bearer token'),
                          ),
                          DropdownMenuItem(
                            value: 'header',
                            child: Text('Custom header'),
                          ),
                          DropdownMenuItem(
                            value: 'query',
                            child: Text('Query parameter'),
                          ),
                          DropdownMenuItem(
                            value: 'basic',
                            child: Text('Basic auth'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _authStyle = v ?? 'bearer'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final field in provider?.credentialFields ?? [])
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppTextFormField(
                            controller: _secretControllers[field['key']]!,
                            label:
                                field['label'] as String? ??
                                field['key'] as String,
                            validator: (_) => null,
                          ),
                        ),
                    ],
                  );
                },
              ),
              AppTextFormField(controller: _label, label: 'Account label'),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(_saving ? 'Saving…' : 'Save encrypted credentials'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterDeviceSheet extends ConsumerStatefulWidget {
  const _RegisterDeviceSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_RegisterDeviceSheet> createState() =>
      _RegisterDeviceSheetState();
}

class _RegisterDeviceSheetState extends ConsumerState<_RegisterDeviceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _externalId = TextEditingController();
  final _imei = TextEditingController();
  final _sim = TextEditingController();
  final _label = TextEditingController();
  String? _credentialId;
  bool _saving = false;

  @override
  void dispose() {
    _externalId.dispose();
    _imei.dispose();
    _sim.dispose();
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    final credentials = ref.read(_credentialsProvider).value ?? const [];
    if (credentials.isEmpty) {
      showErrorSnack(context, 'Configure provider credentials first');
      return;
    }
    setState(() => _saving = true);
    try {
      final credential = credentials.firstWhere(
        (c) => c.id == _credentialId,
        orElse: () => credentials.first,
      );
      await ref
          .read(gpsDeviceServiceProvider)
          .registerDevice(
            companyId: membership.companyId,
            providerId: credential.providerId,
            externalDeviceId: _externalId.text,
            credentialId: credential.id,
            imei: _imei.text.trim().isEmpty ? null : _imei.text.trim(),
            simNumber: _sim.text.trim().isEmpty ? null : _sim.text.trim(),
            label: _label.text.trim().isEmpty ? null : _label.text.trim(),
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
    final credentials = ref.watch(_credentialsProvider);
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
                'Register GPS device',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AsyncView(
                value: credentials,
                isEmpty: (list) => list.isEmpty,
                emptyMessage: 'Configure provider credentials before registering devices.',
                builder: (list) => DropdownButtonFormField<String>(
                  initialValue: list.any((c) => c.id == _credentialId)
                      ? _credentialId
                      : (list.isNotEmpty ? list.first.id : null),
                  decoration: const InputDecoration(
                    labelText: 'Provider account',
                  ),
                  items: [
                    for (final credential in list)
                      DropdownMenuItem(
                        value: credential.id,
                        child: Text(
                          '${credential.providerId} • ${credential.label}',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _credentialId = v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _externalId,
                label: 'Provider device ID',
                hint: 'As shown in your GPS provider portal',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _imei,
                label: 'IMEI (optional)',
                validator: (_) => null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _sim,
                label: 'SIM number (optional)',
                validator: (_) => null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _label,
                label: 'Label (optional)',
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
                    : const Icon(Icons.sensors_outlined),
                label: Text(_saving ? 'Registering…' : 'Register device'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
