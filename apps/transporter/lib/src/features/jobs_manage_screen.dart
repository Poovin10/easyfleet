import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'company_gate.dart';

final companyJobsProvider = FutureProvider<List<JobPosting>>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return const [];
  return ref
      .watch(marketplaceServiceProvider)
      .companyJobs(membership.companyId);
});

final _applicantsProvider = FutureProvider.family<List<JobApplication>, String>(
  (ref, jobId) {
    return ref.watch(marketplaceServiceProvider).applicantsForJob(jobId);
  },
);

/// Post jobs, review applicants and appoint drivers.
class JobsManageScreen extends ConsumerWidget {
  const JobsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(companyJobsProvider);
    return AppScaffold(
      title: 'Job postings',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Post job'),
      ),
      body: AsyncView(
        value: jobs,
        onRetry: () => ref.invalidate(companyJobsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No jobs posted yet.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(companyJobsProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final job = list[index];
              return AppSectionCard(
                onTap: () => _showApplicants(context, ref, job),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(status: job.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (job.origin != null && job.destination != null)
                          '${job.origin} → ${job.destination}',
                        if (job.rateAmount != null)
                          '₹${job.rateAmount!.toStringAsFixed(0)}',
                        'Tap to view applicants',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (job.isOpen)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final confirmed = await confirmDialog(
                              context,
                              title: 'Close job?',
                              message:
                                  'Drivers will no longer be able to apply.',
                              confirmLabel: 'Close job',
                              destructive: true,
                            );
                            if (!confirmed || !context.mounted) return;
                            try {
                              await ref
                                  .read(marketplaceServiceProvider)
                                  .closeJob(jobId: job.id, status: 'CLOSED');
                              ref.invalidate(companyJobsProvider);
                            } catch (error) {
                              if (context.mounted) {
                                showErrorSnack(context, error);
                              }
                            }
                          },
                          child: const Text('Close'),
                        ),
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

  Future<void> _showPostSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _PostJobSheet(
          onDone: () {
            Navigator.pop(sheetContext);
            ref.invalidate(companyJobsProvider);
            showSuccessSnack(context, 'Job posted');
          },
        ),
      ),
    );
  }

  Future<void> _showApplicants(
    BuildContext context,
    WidgetRef ref,
    JobPosting job,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, scrollController) =>
            _ApplicantsSheet(job: job, scrollController: scrollController),
      ),
    );
  }
}

class _PostJobSheet extends ConsumerStatefulWidget {
  const _PostJobSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends ConsumerState<_PostJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _rate = TextEditingController();
  final _tonnes = TextEditingController();
  String _rateUnit = 'PER_TRIP';
  String _vehicleType = 'TRUCK';
  final Set<String> _classes = {'HMV'};
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _origin.dispose();
    _destination.dispose();
    _city.dispose();
    _state.dispose();
    _rate.dispose();
    _tonnes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final membership = ref.read(companyContextProvider).value;
    if (membership == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(marketplaceServiceProvider)
          .postJob(
            companyId: membership.companyId,
            title: _title.text,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            origin: _origin.text.trim().isEmpty ? null : _origin.text.trim(),
            destination: _destination.text.trim().isEmpty
                ? null
                : _destination.text.trim(),
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
            state: _state.text.trim().isEmpty ? null : _state.text.trim(),
            rateAmount: double.tryParse(_rate.text.trim()),
            rateUnit: _rateUnit,
            tonnes: double.tryParse(_tonnes.text.trim()),
            vehicleType: _vehicleType,
            requiredLicenceClasses: _classes.toList(),
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
              Text('Post a job', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              AppTextFormField(controller: _title, label: 'Job title'),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _description,
                label: 'Description (optional)',
                maxLines: 2,
                validator: (_) => null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: _origin,
                      label: 'Origin (optional)',
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _destination,
                      label: 'Destination (optional)',
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
                      controller: _city,
                      label: 'City (optional)',
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextFormField(
                      controller: _state,
                      label: 'State (optional)',
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
                      controller: _rate,
                      label: 'Rate ₹ (optional)',
                      decimal: true,
                      validator: optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _rateUnit,
                      decoration: const InputDecoration(labelText: 'Per'),
                      items: const [
                        DropdownMenuItem(
                          value: 'PER_TRIP',
                          child: Text('Trip'),
                        ),
                        DropdownMenuItem(
                          value: 'PER_TONNE',
                          child: Text('Tonne'),
                        ),
                        DropdownMenuItem(
                          value: 'MONTHLY_SALARY',
                          child: Text('Month'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _rateUnit = v ?? 'PER_TRIP'),
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
                    child: DropdownButtonFormField<String>(
                      initialValue: _vehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle type',
                      ),
                      items:
                          const [
                                'TRUCK',
                                'TRAILER',
                                'TANKER',
                                'CONTAINER',
                                'VAN',
                                'OTHER',
                              ]
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setState(() => _vehicleType = v ?? 'TRUCK'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Required licence classes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final cls in const [
                    'LMV',
                    'MMV',
                    'HMV',
                    'HMV_PLUS',
                    'TRACTOR_TRAILER',
                    'HAZARDOUS_GOODS',
                  ])
                    FilterChip(
                      label: Text(cls),
                      selected: _classes.contains(cls),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _classes.add(cls);
                        } else {
                          _classes.remove(cls);
                        }
                      }),
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
                    : const Icon(Icons.publish),
                label: Text(_saving ? 'Posting…' : 'Post job'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantsSheet extends ConsumerWidget {
  const _ApplicantsSheet({required this.job, required this.scrollController});

  final JobPosting job;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicants = ref.watch(_applicantsProvider(job.id));
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Applicants: ${job.title}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AsyncView(
              value: applicants,
              onRetry: () => ref.invalidate(_applicantsProvider(job.id)),
              isEmpty: (list) => list.isEmpty,
              emptyMessage: 'No applications yet.',
              builder: (list) => ListView.builder(
                controller: scrollController,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final application = list[index];
                  final actionable =
                      application.status == 'APPLIED' ||
                      application.status == 'SHORTLISTED';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  application.driverName ?? 'Driver',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              StatusChip(
                                status: application.status,
                                dense: true,
                              ),
                            ],
                          ),
                          if (application.coverNote != null)
                            Text(
                              application.coverNote!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (actionable && job.isOpen)
                            Wrap(
                              spacing: 6,
                              children: [
                                if (application.status == 'APPLIED')
                                  TextButton(
                                    onPressed: () => _review(
                                      context,
                                      ref,
                                      application,
                                      'SHORTLISTED',
                                    ),
                                    child: const Text('Shortlist'),
                                  ),
                                TextButton(
                                  onPressed: () => _review(
                                    context,
                                    ref,
                                    application,
                                    'REJECTED',
                                  ),
                                  child: const Text('Reject'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      _appoint(context, ref, application),
                                  child: const Text('Appoint'),
                                ),
                              ],
                            ),
                        ],
                      ),
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

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    JobApplication application,
    String decision,
  ) async {
    try {
      await ref
          .read(marketplaceServiceProvider)
          .reviewApplication(applicationId: application.id, decision: decision);
      ref.invalidate(_applicantsProvider(job.id));
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  Future<void> _appoint(
    BuildContext context,
    WidgetRef ref,
    JobApplication application,
  ) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Appoint driver?',
      message: 'This creates an approved company membership and fills the job.',
      confirmLabel: 'Appoint',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref
          .read(marketplaceServiceProvider)
          .appointDriver(applicationId: application.id);
      ref.invalidate(_applicantsProvider(job.id));
      ref.invalidate(companyJobsProvider);
      if (context.mounted) {
        showSuccessSnack(context, 'Driver appointed');
        Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }
}
