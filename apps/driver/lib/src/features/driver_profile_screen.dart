import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final _dlDetailsProvider = FutureProvider<DriverLicence?>((ref) async {
  ref.watch(driverAccountProvider);
  final account = ref.watch(driverAccountProvider).value;
  if (account == null) return null;
  return ref.watch(onboardingServiceProvider).dlDetails();
});

final _dlHistoryProvider = FutureProvider<List<DocumentReview>>((ref) async {
  ref.watch(driverAccountProvider);
  final account = ref.watch(driverAccountProvider).value;
  if (account == null) return const [];
  return ref
      .watch(onboardingServiceProvider)
      .reviewHistory(isTransporter: false);
});

/// DL profile & office verification status for the driver.
class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dlNumberController = TextEditingController();
  LicenseClass _licenceClass = LicenseClass.hmv;
  XFile? _document;
  bool _submitting = false;

  @override
  void dispose() {
    _dlNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file != null) setState(() => _document = file);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file != null) setState(() => _document = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_document == null) {
      showErrorSnack(context, 'Attach a photo of your driving licence');
      return;
    }
    setState(() => _submitting = true);
    try {
      final service = ref.read(onboardingServiceProvider);
      final bytes = await _document!.readAsBytes();
      final path = await service.uploadDocument(
        kind: 'dl',
        bytes: bytes,
        extension: 'jpg',
      );
      await service.submitDriverDl(
        dlNumber: _dlNumberController.text,
        licenseClass: _licenceClass,
        documentPath: path,
      );
      if (!mounted) return;
      showSuccessSnack(context, 'Licence submitted for office verification');
      ref.invalidate(_dlDetailsProvider);
      ref.invalidate(_dlHistoryProvider);
      setState(() => _document = null);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(driverAccountProvider);
    final licence = ref.watch(_dlDetailsProvider);
    final history = ref.watch(_dlHistoryProvider);
    final memberships = ref.watch(driverMembershipsProvider);

    return AppScaffold(
      title: 'DL profile & verification',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AsyncView(
            value: account,
            builder: (account) => AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account?.displayName ?? 'Driver',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    account?.phoneE164 ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          AsyncView(
            value: licence,
            onRetry: () => ref.invalidate(_dlDetailsProvider),
            builder: (lic) => AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Verification: '),
                      StatusChip(
                        status: lic?.verificationStatus ?? 'NOT_SUBMITTED',
                      ),
                    ],
                  ),
                  if (lic != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Class: ${lic.licenceClass ?? '—'}'),
                    if (lic.validUntil != null)
                      Text(
                        'Valid until: ${lic.validUntil!.toIso8601String().split('T').first}',
                      ),
                  ],
                  if (lic?.rejectionReason != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Rejection reason: ${lic!.rejectionReason}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Approval is performed by the EasyFleet verification office.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Submit / update licence'),
          AppSectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField(
                    controller: _dlNumberController,
                    label: 'DL number',
                    hint: 'KL0120200001234',
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.length < 8) return 'Enter a valid DL number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<LicenseClass>(
                    initialValue: _licenceClass,
                    decoration: const InputDecoration(
                      labelText: 'Licence class',
                    ),
                    items: [
                      for (final value in LicenseClass.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(_licenceClassLabel(value)),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _licenceClass = value ?? _licenceClass),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _submitting ? null : _pickDocument,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _submitting ? null : _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                  if (_document != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _document!.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(
                      _submitting ? 'Submitting…' : 'Submit for verification',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Review history'),
          AsyncView(
            value: history,
            isEmpty: (list) => list.isEmpty,
            emptyMessage: 'No reviews yet.',
            builder: (list) => Column(
              children: [
                for (final review in list)
                  ListTile(
                    dense: true,
                    leading: StatusChip(status: review.decision, dense: true),
                    title: Text(review.reason ?? 'Status update'),
                    subtitle: Text(
                      review.actedAt.toLocal().toString().split('.').first,
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader(title: 'My companies'),
          AsyncView(
            value: memberships,
            isEmpty: (list) => list.isEmpty,
            emptyMessage: 'You are not part of any company yet. Apply to jobs to get appointed.',
            builder: (list) => Column(
              children: [
                for (final membership in list)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.business_outlined),
                    title: Text(membership.companyName ?? membership.companyId),
                    trailing: StatusChip(
                      status: membership.status,
                      dense: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _licenceClassLabel(LicenseClass value) => switch (value) {
    LicenseClass.lmv => 'LMV',
    LicenseClass.mmv => 'MMV',
    LicenseClass.hmv => 'HMV',
    LicenseClass.hmvPlus => 'HMV+',
    LicenseClass.tractorTrailer => 'Tractor / Trailer',
    LicenseClass.hazardousGoods => 'Hazardous goods',
  };
}
