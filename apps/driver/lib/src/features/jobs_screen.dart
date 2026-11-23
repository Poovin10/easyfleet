import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _openJobsProvider = FutureProvider<List<JobPosting>>((ref) {
  return ref.watch(marketplaceServiceProvider).searchJobs();
});

final _jobDetailProvider = FutureProvider.family<JobPosting?, String>((
  ref,
  jobId,
) {
  return ref.watch(marketplaceServiceProvider).job(jobId);
});

class DriverJobsScreen extends ConsumerWidget {
  const DriverJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(_openJobsProvider);
    return AppScaffold(
      title: 'Job market',
      body: AsyncView(
        value: jobs,
        onRetry: () => ref.invalidate(_openJobsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No open jobs right now. Check back soon.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_openJobsProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final job = list[index];
              return AppSectionCard(
                onTap: () => context.push('/jobs/${job.id}'),
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
                        if (job.companyName != null) job.companyName!,
                        if (job.origin != null && job.destination != null)
                          '${job.origin} → ${job.destination}',
                        if (job.city != null) job.city!,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final cls in job.requiredLicenceClasses)
                          Chip(
                            label: Text(
                              cls,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (job.rateAmount != null)
                          Chip(
                            label: Text(
                              '₹${job.rateAmount!.toStringAsFixed(0)} ${job.rateUnit == 'PER_TONNE'
                                  ? '/tonne'
                                  : job.rateUnit == 'MONTHLY_SALARY'
                                  ? '/month'
                                  : '/trip'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
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

class DriverJobDetailScreen extends ConsumerStatefulWidget {
  const DriverJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<DriverJobDetailScreen> createState() =>
      _DriverJobDetailScreenState();
}

class _DriverJobDetailScreenState extends ConsumerState<DriverJobDetailScreen> {
  final _coverNoteController = TextEditingController();
  bool _applying = false;

  @override
  void dispose() {
    _coverNoteController.dispose();
    super.dispose();
  }

  Future<void> _apply(JobPosting job) async {
    setState(() => _applying = true);
    try {
      await ref
          .read(marketplaceServiceProvider)
          .applyToJob(
            jobId: job.id,
            coverNote: _coverNoteController.text.trim().isEmpty
                ? null
                : _coverNoteController.text.trim(),
          );
      if (!mounted) return;
      showSuccessSnack(context, 'Application submitted');
      ref.invalidate(_openJobsProvider);
      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) router.pop();
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(_jobDetailProvider(widget.jobId));
    return AppScaffold(
      title: 'Job details',
      body: AsyncView(
        value: job,
        onRetry: () => ref.invalidate(_jobDetailProvider(widget.jobId)),
        builder: (job) {
          if (job == null) {
            return const EmptyView(message: 'Job not found');
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(status: job.status),
                  for (final cls in job.requiredLicenceClasses)
                    Chip(label: Text(cls)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow('Company', job.companyName ?? '—'),
              _DetailRow(
                'Route',
                job.origin != null && job.destination != null
                    ? '${job.origin} → ${job.destination}'
                    : '—',
              ),
              _DetailRow('Material', job.material ?? '—'),
              _DetailRow(
                'Load',
                job.tonnes != null ? '${job.tonnes} tonnes' : '—',
              ),
              _DetailRow('Vehicle', job.vehicleType ?? '—'),
              _DetailRow(
                'Rate',
                job.rateAmount != null
                    ? '₹${job.rateAmount!.toStringAsFixed(0)} (${job.rateUnit ?? 'PER_TRIP'})'
                    : '—',
              ),
              _DetailRow(
                'Location',
                [job.city, job.state].whereType<String>().join(', '),
              ),
              if (job.description != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(job.description!),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (job.isOpen) ...[
                TextField(
                  controller: _coverNoteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Cover note (optional)',
                    hintText: 'Tell the transporter about your experience',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _applying ? null : () => _apply(job),
                  icon: _applying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_applying ? 'Applying…' : 'Apply to this job'),
                ),
              ] else
                const EmptyView(message: 'This job is no longer open'),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
