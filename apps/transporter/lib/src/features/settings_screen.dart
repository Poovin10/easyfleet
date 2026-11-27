import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'company_gate.dart';

final transporterNotificationsProvider = StreamProvider<List<NotificationItem>>(
  (ref) {
    ref.watch(authUserIdProvider);
    return ref.watch(notificationServiceProvider).watch();
  },
);

class TransporterNotificationsScreen extends ConsumerWidget {
  const TransporterNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(transporterNotificationsProvider);
    return AppScaffold(
      title: 'Notifications',
      actions: [
        TextButton(
          onPressed: () async {
            await ref.read(notificationServiceProvider).markAllRead();
            ref.invalidate(transporterNotificationsProvider);
          },
          child: const Text('Mark all read'),
        ),
      ],
      body: AsyncView(
        value: notifications,
        onRetry: () => ref.invalidate(transporterNotificationsProvider),
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
                  ref.invalidate(transporterNotificationsProvider);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// Transporter settings: account, company switching, sync and sign-out.
class TransporterSettingsScreen extends ConsumerStatefulWidget {
  const TransporterSettingsScreen({super.key});

  @override
  ConsumerState<TransporterSettingsScreen> createState() =>
      _TransporterSettingsScreenState();
}

class _TransporterSettingsScreenState
    extends ConsumerState<TransporterSettingsScreen> {
  bool _changingPassword = false;

  Future<void> _changePassword() async {
    final existing = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: existing,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      existing.dispose();
      next.dispose();
      confirm.dispose();
      return;
    }
    if (existing.text.isEmpty ||
        next.text.length < 6 ||
        next.text != confirm.text) {
      existing.dispose();
      next.dispose();
      confirm.dispose();
      if (mounted) {
        showErrorSnack(
          context,
          'Enter your current password; new passwords must match and be 6+ characters',
        );
      }
      return;
    }
    setState(() => _changingPassword = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(next.text, currentPassword: existing.text);
      if (mounted) showSuccessSnack(context, 'Password updated');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      existing.dispose();
      next.dispose();
      confirm.dispose();
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final syncState = ref.watch(syncControllerProvider);
    final environment = ref.watch(environmentProvider);
    final version = ref.watch(currentAppVersionProvider);
    final memberships = ref.watch(companyContextProvider);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName ?? 'Transporter account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? 'No email on this session',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'EasyFleet Transporter • ${environment.flavor.name}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Company'),
          AsyncView(
            value: memberships,
            builder: (membership) => ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Active company'),
              subtitle: Text(membership?.companyName ?? 'None'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _switchCompany(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Company profile & GST'),
            subtitle: const Text('Registered name and verification'),
            onTap: () => context.push(AppRoutes.companyProfile),
          ),
          const SectionHeader(title: 'Manage your fleet'),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Trucks & compliance'),
            subtitle: const Text(
              'Add trucks and upload RC, insurance, permits',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.vehicles),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Drivers'),
            subtitle: const Text(
              'Add drivers manually or hire verified drivers',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.assignments),
          ),
          ListTile(
            leading: const Icon(Icons.card_membership_outlined),
            title: const Text('Subscription & payments'),
            onTap: () => context.push('/subscription'),
          ),
          ListTile(
            leading: const Icon(Icons.gps_fixed_outlined),
            title: const Text('GPS devices'),
            onTap: () => context.push(AppRoutes.gpsDevices),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Accounting'),
            onTap: () => context.push(AppRoutes.accounting),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => context.push(AppRoutes.notifications),
          ),
          const SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change password'),
            subtitle: const Text('Requires your current password'),
            trailing: _changingPassword
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _changingPassword ? null : _changePassword,
          ),
          const SectionHeader(title: 'Offline sync'),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Queued items: ${syncState.pending}'),
                Text('Failed permanently: ${syncState.deadLetters}'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () =>
                          ref.read(syncControllerProvider.notifier).flushNow(),
                      child: const Text('Sync now'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (syncState.deadLetters > 0)
                      OutlinedButton(
                        onPressed: () => ref
                            .read(syncControllerProvider.notifier)
                            .retryDeadLetters(),
                        child: const Text('Retry failed'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'App info'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: Text('$version (${environment.flavor.name})'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final confirmed = await confirmDialog(
                  context,
                  title: 'Sign out?',
                  message: 'Queued offline items stay on this device.',
                  confirmLabel: 'Sign out',
                  destructive: true,
                );
                if (!confirmed) return;
                await ref.read(authControllerProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _switchCompany() async {
    final memberships = await ref.read(companyServiceProvider).myMemberships();
    if (!mounted) return;
    final active = memberships.where((m) => m.isActive).toList();
    if (active.length <= 1) {
      showSuccessSnack(context, 'Only one active company available');
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Switch company'),
        children: [
          for (final membership in active)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, membership.companyId),
              child: Text(membership.companyName ?? membership.companyId),
            ),
        ],
      ),
    );
    if (selected != null) {
      ref.read(selectedCompanyProvider.notifier).select(selected);
      ref.invalidate(companyContextProvider);
    }
  }
}
