import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      next.dispose();
      confirm.dispose();
      return;
    }
    if (next.text.length < 6 || next.text != confirm.text) {
      next.dispose();
      confirm.dispose();
      if (mounted) {
        showErrorSnack(context, 'Passwords must match and be 6+ characters');
      }
      return;
    }
    setState(() => _changingPassword = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(next.text);
      if (mounted) showSuccessSnack(context, 'Password updated');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
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
                  auth.displayName ?? 'Signed in',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  auth.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'EasyFleet Transporter • ${environment.flavor.name}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
            leading: const Icon(Icons.password),
            title: const Text('Change password'),
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
