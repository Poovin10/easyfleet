import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'company_gate.dart';
import 'dashboard_screen.dart';

final gstHistoryProvider = FutureProvider<List<DocumentReview>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref
      .watch(onboardingServiceProvider)
      .reviewHistory(isTransporter: true);
});

/// GST profile & office verification for the transporter.
class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();
  final _legalNameController = TextEditingController();
  XFile? _document;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _gstinController.dispose();
    _legalNameController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file != null) setState(() => _document = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_document == null) {
      showErrorSnack(context, 'Attach the GST certificate photo');
      return;
    }
    setState(() => _saving = true);
    try {
      final service = ref.read(onboardingServiceProvider);
      final bytes = await _document!.readAsBytes();
      final path = await service.uploadDocument(
        kind: 'gst',
        bytes: bytes,
        extension: 'jpg',
      );
      await service.submitCompanyGst(
        gst: _gstinController.text,
        legalName: _legalNameController.text,
        documentPath: path,
      );
      if (!mounted) return;
      showSuccessSnack(context, 'GST submitted for office verification');
      ref.invalidate(companyDetailsProvider);
      ref.invalidate(gstHistoryProvider);
      setState(() => _document = null);
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyDetailsProvider);
    final history = ref.watch(gstHistoryProvider);

    ref.listen(companyDetailsProvider, (_, next) {
      final data = next.value;
      if (data != null && !_prefilled) {
        _prefilled = true;
        _gstinController.text = data.gstin;
        _legalNameController.text = data.legalName;
      }
    });

    return AppScaffold(
      title: 'GST profile & verification',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AsyncView(
            value: company,
            onRetry: () => ref.invalidate(companyDetailsProvider),
            builder: (company) => AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company?.name ?? 'Company',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Text('GST status: '),
                      StatusChip(
                        status:
                            company?.gstVerificationStatus ?? 'NOT_SUBMITTED',
                      ),
                    ],
                  ),
                  if (company?.gstRejectionReason != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Rejection reason: ${company!.gstRejectionReason}',
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
          const SectionHeader(title: 'Submit / update GST'),
          AppSectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField(
                    controller: _gstinController,
                    label: 'GSTIN',
                    hint: '29ABCDE1234F1Z5',
                    validator: (value) {
                      final v = value?.trim().toUpperCase() ?? '';
                      final valid = RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                      ).hasMatch(v);
                      return valid ? null : 'Enter a valid 15-character GSTIN';
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextFormField(
                    controller: _legalNameController,
                    label: 'Legal name',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _pick(ImageSource.gallery),
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
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(
                      _saving ? 'Submitting…' : 'Submit for verification',
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
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
