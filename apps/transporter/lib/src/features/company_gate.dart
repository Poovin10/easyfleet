import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active company context for the transporter app. Falls back to the first
/// active membership; the user can switch companies from the dashboard.
final companyContextProvider = FutureProvider<CompanyMembership?>((ref) async {
  ref.watch(authUserIdProvider);
  final selected = ref.watch(selectedCompanyProvider);
  final memberships = await ref.watch(companyServiceProvider).myMemberships();
  final active = memberships.where((m) => m.isActive).toList();
  if (active.isEmpty) return null;
  if (selected != null) {
    for (final m in active) {
      if (m.companyId == selected) return m;
    }
  }
  active.sort((a, b) {
    int rank(CompanyMembership m) => m.isManager ? 0 : 1;
    return rank(a).compareTo(rank(b));
  });
  return active.first;
});

/// Gates transporter features behind company registration.
class CompanyGate extends ConsumerWidget {
  const CompanyGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(companyContextProvider);
    return company.when(
      loading: () => const LoadingView(message: 'Loading company…'),
      error: (error, _) => ErrorView(
        message: friendlyError(error),
        onRetry: () => ref.invalidate(companyContextProvider),
      ),
      data: (membership) {
        if (membership == null) return const CompanySetupScreen();
        return child;
      },
    );
  }
}

/// Registers the transporter's company (creates OWNER membership and a
/// 30-day trial subscription server-side).
class CompanySetupScreen extends ConsumerStatefulWidget {
  const CompanySetupScreen({super.key});

  @override
  ConsumerState<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends ConsumerState<CompanySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _legalNameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final companyId = await ref
          .read(companyServiceProvider)
          .registerCompany(
            name: _nameController.text,
            legalName: _legalNameController.text.trim().isEmpty
                ? _nameController.text
                : _legalNameController.text,
          );
      ref.read(selectedCompanyProvider.notifier).select(companyId);
      ref.invalidate(companyContextProvider);
      if (mounted) {
        showSuccessSnack(
          context,
          'Company registered. A 30-day trial has started.',
        );
      }
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register your company',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Set up your transport company',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Registration includes a 30-day free trial. After that, '
                    'the EasyFleet subscription is ₹1,500 per 30 days.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextFormField(
                    controller: _nameController,
                    label: 'Company name',
                    validator: (v) => (v?.trim().length ?? 0) < 2
                        ? 'Enter at least 2 characters'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextFormField(
                    controller: _legalNameController,
                    label: 'Legal name (optional)',
                    validator: (_) => null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _saving ? null : _register,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_saving ? 'Registering…' : 'Register company'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
