import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _walletProvider = FutureProvider<List<LedgerEntry>>((ref) async {
  ref.watch(driverAccountProvider);
  return ref.watch(fleetServiceProvider).myDriverLedger();
});

/// Driver wallet: bata, advances, payments and deductions.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_walletProvider);
    return AppScaffold(
      title: 'Wallet & payouts',
      body: AsyncView(
        value: entries,
        onRetry: () => ref.invalidate(_walletProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No wallet entries yet.',
        builder: (list) {
          final balance = list
              .where((e) => e.approvalStatus == 'APPROVED')
              .fold<double>(
                0,
                (sum, e) => sum + (e.isCredit ? e.amount : -e.amount),
              );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_walletProvider),
            child: ListView(
              children: [
                AppSectionCard(
                  child: Column(
                    children: [
                      Text(
                        'Balance',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                for (final entry in list)
                  ListTile(
                    leading: Icon(
                      entry.isCredit
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: entry.isCredit
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(StatusChip.label(entry.entryType)),
                    subtitle: Text(entry.description ?? ''),
                    trailing: Text(
                      '${entry.isCredit ? '+' : '-'}₹${entry.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  ref.watch(authUserIdProvider);
  return ref.watch(notificationServiceProvider).watch();
});

/// Shared notifications screen (driver).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return AppScaffold(
      title: 'Notifications',
      actions: [
        TextButton(
          onPressed: () async {
            await ref.read(notificationServiceProvider).markAllRead();
            ref.invalidate(notificationsProvider);
          },
          child: const Text('Mark all read'),
        ),
      ],
      body: AsyncView(
        value: notifications,
        onRetry: () => ref.invalidate(notificationsProvider),
        isEmpty: (list) => list.isEmpty,
        emptyMessage: 'No notifications yet.',
        builder: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              leading: Icon(
                item.isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: item.isRead
                    ? null
                    : Theme.of(context).colorScheme.primary,
              ),
              title: Text(item.title),
              subtitle: Text(
                '${item.body}\n${item.createdAt.toLocal().toString().split('.').first}',
              ),
              isThreeLine: true,
              onTap: () async {
                if (!item.isRead) {
                  await ref.read(notificationServiceProvider).markRead(item.id);
                  ref.invalidate(notificationsProvider);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
