import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _dashboardTripsProvider = FutureProvider<List<FleetTrip>>((ref) async {
  ref.watch(driverAccountProvider);
  return ref.watch(fleetServiceProvider).myDriverTrips();
});

final _dashboardLicenceProvider = FutureProvider<DriverLicence?>((ref) async {
  ref.watch(driverAccountProvider);
  final account = ref.watch(driverAccountProvider).value;
  if (account == null) return null;
  return ref.watch(onboardingServiceProvider).dlDetails();
});

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(_dashboardTripsProvider);
    final licence = ref.watch(_dashboardLicenceProvider);
    final syncState = ref.watch(syncControllerProvider);
    final unread = ref.watch(unreadNotificationCountProvider).value ?? 0;
    final account = ref.watch(driverAccountProvider).value;

    return AppScaffold(
      title: 'EasyFleet Driver',
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
          ref.invalidate(_dashboardTripsProvider);
          ref.invalidate(_dashboardLicenceProvider);
          await ref.read(syncControllerProvider.notifier).flushNow();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${account?.displayName ?? 'Driver'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  licence.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(friendlyError(e)),
                    data: (lic) => Row(
                      children: [
                        const Text('Licence: '),
                        StatusChip(
                          status: lic?.verificationStatus ?? 'NOT_SUBMITTED',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.driverProfile),
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                  ),
                  if (licence.value?.rejectionReason != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Reason: ${licence.value!.rejectionReason}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSectionCard(
              child: Row(
                children: [
                  Icon(
                    syncState.pending > 0
                        ? Icons.cloud_upload_outlined
                        : Icons.cloud_done_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      syncState.pending > 0
                          ? '${syncState.pending} item(s) waiting to sync'
                          : 'All changes synced',
                    ),
                  ),
                  if (syncState.isSyncing)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: () =>
                          ref.read(syncControllerProvider.notifier).flushNow(),
                      child: const Text('Sync now'),
                    ),
                ],
              ),
            ),
            const SectionHeader(title: 'Current trips'),
            AsyncView(
              value: trips,
              onRetry: () => ref.invalidate(_dashboardTripsProvider),
              isEmpty: (list) => list.where((t) => t.isActive).isEmpty,
              emptyMessage: 'No active trips. Apply to jobs or wait for a transporter to assign you.',
              builder: (list) => Column(
                children: [
                  for (final trip in list.where((t) => t.isActive).take(3))
                    _TripCard(trip: trip),
                ],
              ),
            ),
            const SectionHeader(title: 'Quick actions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.work_outline, size: 18),
                    label: const Text('Find jobs'),
                    onPressed: () => context.go(AppRoutes.jobs),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.route_outlined, size: 18),
                    label: const Text('All trips'),
                    onPressed: () => context.go(AppRoutes.trips),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.gps_fixed, size: 18),
                    label: const Text('Live tracking'),
                    onPressed: () => context.go(AppRoutes.liveTracking),
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    label: const Text('Wallet'),
                    onPressed: () => context.push(AppRoutes.wallet),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.handshake_outlined, size: 18),
                    label: const Text('My appointment'),
                    onPressed: () => context.push(AppRoutes.assignments),
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

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final FleetTrip trip;

  @override
  Widget build(BuildContext context) {
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
              if (trip.gcNumber != null) 'GC ${trip.gcNumber}',
            ].join(' • '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
