import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings: account, security, sync diagnostics and sign-out.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.appName});

  final String appName;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _changingPassword = false;

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
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
              controller: current,
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
      current.dispose();
      next.dispose();
      return;
    }
    if (next.text.length < 6 || next.text != current.text) {
      current.dispose();
      next.dispose();
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
      current.dispose();
      next.dispose();
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final syncState = ref.watch(syncControllerProvider);
    final environment = ref.watch(environmentProvider);

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
                  '${widget.appName} • ${environment.flavor.name}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => context.push(AppRoutes.notifications),
          ),
          const SectionHeader(title: 'Offline sync'),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Queued items: ${syncState.pending}'),
                Text('Failed permanently: ${syncState.deadLetters}'),
                if (syncState.lastSyncedAt != null)
                  Text(
                    'Last sync: ${syncState.lastSyncedAt!.toLocal().toString().split('.').first}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
}
