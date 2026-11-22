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
  }) async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signInWithPassword(email: email, password: password);
  }

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
