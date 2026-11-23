import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Owns the Supabase session state for both apps.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final client = ref.watch(supabaseClientProvider);

    final subscription = client.auth.onAuthStateChange.listen((data) {
      state = _stateFromSession(data.session);
    });
    ref.onDispose(subscription.cancel);

    return _stateFromSession(client.auth.currentSession);
  }

  AuthState _stateFromSession(Session? session) {
    if (session == null) return AuthState.unauthenticated;
    return AuthState(
      status: AuthStatus.authenticated,
      userId: session.user.id,
      email: session.user.email,
      displayName: session.user.userMetadata?['display_name'] as String?,
    );
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
    bool createDriverAccountIfMissing = false,
  }) async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signInWithPassword(email: email, password: password);
    if (createDriverAccountIfMissing) {
      await ensureDriverAccount();
    }
  }

  /// Ensures the signed-in user has a `driver_accounts` row.
  ///
  /// The backend RPC is idempotent and scoped to `auth.uid()`.
  Future<void> ensureDriverAccount({String? displayName}) async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    final metadataName = user?.userMetadata?['display_name'] as String?;
    final emailName = user?.email?.split('@').first;
    final resolved = (displayName ?? metadataName ?? emailName ?? 'Driver')
        .trim();
    await client.rpc<void>(
      'easyfleet_create_driver_account',
      params: {'p_display_name': resolved.isEmpty ? 'Driver' : resolved},
    );
  }

  /// Creates an account with Supabase Auth.
  ///
  /// Returns `true` when Supabase auto-confirmed the account and returned a
  /// session. Returns `false` when the user must confirm their email first.
  Future<bool> signUpWithPassword({
    required String displayName,
    required String email,
    required String password,
    String appRole = 'driver',
  }) async {
    final client = ref.read(supabaseClientProvider);
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName.trim(), 'app_role': appRole},
    );
    final signedInImmediately = response.session != null;
    if (signedInImmediately && appRole == 'driver') {
      await ensureDriverAccount(displayName: displayName);
    }
    return signedInImmediately;
  }

  /// Creates a driver account with Supabase Auth.
  Future<bool> signUpDriverWithPassword({
    required String displayName,
    required String email,
    required String password,
  }) => signUpWithPassword(
    displayName: displayName,
    email: email,
    password: password,
  );

  /// Supabase email OTP replaces WonderMove's Ory Kratos login-link flow.
  Future<void> signInWithOtp({required String email}) async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signInWithOtp(email: email);
  }

  Future<void> signOut() async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signOut();
    state = AuthState.unauthenticated;
  }

  Future<void> changePassword(String newPassword) async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
