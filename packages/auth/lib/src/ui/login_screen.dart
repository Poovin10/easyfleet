import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.appName,
    this.enableSignUp = false,
  });

  final String appName;
  final bool enableSignUp;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _isSubmitting = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode({required bool signUp}) {
    setState(() {
      _isSignUpMode = signUp;
      _error = null;
      _notice = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            createDriverAccountIfMissing: widget.enableSignUp,
          );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signUp() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
      _notice = null;
    });
    try {
      final signedInImmediately = await ref
          .read(authControllerProvider.notifier)
          .signUpDriverWithPassword(
            displayName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      setState(() {
        _notice = signedInImmediately
            ? l10n.signUpSuccess
            : l10n.checkYourEmail;
        _isSignUpMode = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submit() async {
    if (_isSignUpMode) {
      await _signUp();
    } else {
      await _signIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_isSignUpMode) ...[
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.fullName),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.nameRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.email),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.password),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      if (_isSignUpMode && value.length < 6) {
                        return l10n.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  if (_isSignUpMode) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                      ),
                      validator: (value) => value != _passwordController.text
                          ? l10n.passwordMismatch
                          : null,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_notice != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _notice!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(
                      _isSubmitting
                          ? l10n.loading
                          : (_isSignUpMode ? l10n.signUp : l10n.signIn),
                    ),
                  ),
                  if (widget.enableSignUp) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _switchMode(signUp: !_isSignUpMode),
                      child: Text(
                        _isSignUpMode
                            ? l10n.alreadyHaveAccount
                            : l10n.dontHaveAccount,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
