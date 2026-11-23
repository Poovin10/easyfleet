import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _myApplicationsProvider = FutureProvider<List<JobApplication>>((
  ref,
) async {
  ref.watch(authUserIdProvider);
  return ref.watch(marketplaceServiceProvider).myApplications();
});

class DriverApplicationsScreen extends ConsumerWidget {
  const DriverApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(_myApplicationsProvider);
    return AppScaffold(
      title: 'My applications',
      body: AsyncView(
        value: applications,
        onRetry: () => ref.invalidate(_myApplicationsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'You have not applied to any jobs yet.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_myApplicationsProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final application = list[index];
              final canWithdraw =
                  application.status == 'APPLIED' ||
                  application.status == 'SHORTLISTED';
              return AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            application.jobTitle ?? 'Job',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(status: application.status),
                      ],
                    ),
                    if (application.reviewNote != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text('Reviewer note: ${application.reviewNote}'),
                    ],
                    if (canWithdraw)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final confirmed = await confirmDialog(
                              context,
                              title: 'Withdraw application?',
                              message: 'You can re-apply later while the job is open.',
                              confirmLabel: 'Withdraw',
                              destructive: true,
                            );
                            if (!confirmed || !context.mounted) return;
                            try {
                              await ref
                                  .read(marketplaceServiceProvider)
                                  .withdrawApplication(application.id);
                              ref.invalidate(_myApplicationsProvider);
                              if (context.mounted) {
                                showSuccessSnack(
                                  context,
                                  'Application withdrawn',
                                );
                              }
                            } catch (error) {
                              if (context.mounted) {
                                showErrorSnack(context, error);
                              }
                            }
                          },
                          child: const Text('Withdraw'),
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
}

final _myAssignmentsProvider = FutureProvider<List<JobAssignment>>((ref) async {
  ref.watch(driverAccountProvider);
  return ref.watch(marketplaceServiceProvider).myAssignments();
});

class DriverAssignmentsScreen extends ConsumerWidget {
  const DriverAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(_myAssignmentsProvider);
    return AppScaffold(
      title: 'My appointment',
      body: AsyncView(
        value: assignments,
        onRetry: () => ref.invalidate(_myAssignmentsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No appointments yet. When a transporter appoints you, it appears here.',
        builder: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_myAssignmentsProvider),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final assignment = list[index];
              return AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.jobTitle ?? 'Appointment',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(status: assignment.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(assignment.companyName ?? ''),
                    if (assignment.createdAt != null)
                      Text(
                        'Appointed ${assignment.createdAt!.toLocal().toString().split('.').first}',
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
