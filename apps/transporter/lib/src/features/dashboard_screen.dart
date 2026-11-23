import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'company_gate.dart';

final companyDetailsProvider = FutureProvider<Company?>((ref) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return null;
  return ref.watch(companyServiceProvider).company(membership.companyId);
});

final subscriptionStatusProvider = FutureProvider<CompanySubscription?>((
  ref,
) async {
  final membership = ref.watch(companyContextProvider).value;
  if (membership == null) return null;
  return ref
      .watch(subscriptionServiceProvider)
      .subscription(membership.companyId);
});

final _dashboardDataProvider =
    FutureProvider<
      ({
        List<FleetTrip> trips,
        List<FleetVehicle> vehicles,
        int pendingClosures,
        int pendingExpenses,
      })
    >((ref) async {
      final membership = ref.watch(companyContextProvider).value;
      if (membership == null) {
        return (
          trips: <FleetTrip>[],
          vehicles: <FleetVehicle>[],
          pendingClosures: 0,
          pendingExpenses: 0,
        );
      }
      final fleet = ref.watch(fleetServiceProvider);
      final companyId = membership.companyId;
      final results = await Future.wait([
        fleet.companyTrips(companyId),
        fleet.vehicles(companyId),
        fleet.pendingClosures(companyId),
        fleet.pendingExpenses(companyId),
      ]);
      return (
        trips: results[0] as List<FleetTrip>,
        vehicles: results[1] as List<FleetVehicle>,
        pendingClosures: (results[2] as List).length,
        pendingExpenses: (results[3] as List).length,
      );
    });

class TransporterDashboardScreen extends ConsumerWidget {
  const TransporterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(companyContextProvider).value;
    final company = ref.watch(companyDetailsProvider);
    final data = ref.watch(_dashboardDataProvider);
    final subscription = ref.watch(subscriptionStatusProvider);
    final unread = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return AppScaffold(
      title: membership?.companyName ?? 'EasyFleet Transporter',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutes.notifications),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_dashboardDataProvider);
          ref.invalidate(subscriptionStatusProvider);
          ref.invalidate(companyDetailsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            AsyncView(
              value: subscription,
              builder: (sub) {
                if (sub == null) return const SizedBox.shrink();
                final valid = sub.isValid;
                return AppSectionCard(
                  onTap: () => context.push('/subscription'),
                  child: Row(
                    children: [
                      Icon(
                        valid
                            ? Icons.verified_outlined
                            : Icons.warning_amber_outlined,
                        color: valid
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.isTrial
                                  ? 'Trial: ${sub.daysRemaining} day(s) left'
                                  : valid
                                  ? 'Subscription active: ${sub.daysRemaining} day(s) left'
                                  : 'Subscription expired',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              valid
                                  ? 'Valid until ${sub.validUntil.toLocal().toString().split(' ').first}'
                                  : 'Renew for ₹1,500 / 30 days to keep creating trips and jobs',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
            AsyncView(
              value: company,
              builder: (company) => AppSectionCard(
                onTap: () => context.push(AppRoutes.companyProfile),
                child: Row(
                  children: [
                    const Icon(Icons.business_outlined),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'GST verification: ${company?.gstVerificationStatus ?? 'NOT_SUBMITTED'}',
                      ),
                    ),
                    StatusChip(
                      status: company?.gstVerificationStatus ?? 'NOT_SUBMITTED',
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            AsyncView(
              value: data,
              onRetry: () => ref.invalidate(_dashboardDataProvider),
              builder: (data) {
                final activeTrips = data.trips.where((t) => t.isActive).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.7,
                    children: [
                      _KpiCard(
                        label: 'Active trips',
                        value: '$activeTrips',
                        icon: Icons.route_outlined,
                        onTap: () => context.push(AppRoutes.trips),
                      ),
                      _KpiCard(
                        label: 'Vehicles',
                        value: '${data.vehicles.length}',
                        icon: Icons.local_shipping_outlined,
                        onTap: () => context.push(AppRoutes.vehicles),
                      ),
                      _KpiCard(
                        label: 'Closures to review',
                        value: '${data.pendingClosures}',
                        icon: Icons.fact_check_outlined,
                        onTap: () => context.push(AppRoutes.trips),
                      ),
                      _KpiCard(
                        label: 'Expenses to approve',
                        value: '${data.pendingExpenses}',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => context.push(AppRoutes.accounting),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SectionHeader(title: 'Quick actions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.add_road, size: 18),
                    label: const Text('New trip'),
                    onPressed: () => context.push(AppRoutes.trips),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.person_search_outlined, size: 18),
                    label: const Text('Find drivers'),
                    onPressed: () => context.go(AppRoutes.candidates),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.work_outline, size: 18),
                    label: const Text('Post a job'),
                    onPressed: () => context.push('/jobs-manage'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.sensors_outlined, size: 18),
                    label: const Text('GPS devices'),
                    onPressed: () => context.push(AppRoutes.gpsDevices),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Fleet map'),
                    onPressed: () => context.go(AppRoutes.fleetMap),
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    label: const Text('Accounting'),
                    onPressed: () => context.push(AppRoutes.accounting),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
