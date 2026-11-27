import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_driver/src/features/settings_screen.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

SupabaseClient _dummyClient() => SupabaseClient(
  'https://test.invalid',
  'test-anon-key',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);

class FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    userId: 'd1',
    email: 'driver@example.com',
    displayName: 'Test Driver',
  );
}

class FakeSyncController extends SyncController {
  @override
  SyncLoopState build() => const SyncLoopState(pending: 3, deadLetters: 1);
}

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('settings lists account, security and sync options', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SettingsScreen(appName: 'EasyFleet Driver'), [
        authControllerProvider.overrideWith(FakeAuthController.new),
        syncControllerProvider.overrideWith(FakeSyncController.new),
        supabaseClientProvider.overrideWithValue(_dummyClient()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Driver'), findsOneWidget);
    expect(find.text('driver@example.com'), findsOneWidget);
    expect(find.text('DL profile & documents'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Wallet & earnings'), findsOneWidget);
    expect(find.text('My applications'), findsOneWidget);
    expect(find.text('Company assignments'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Sync now'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Queued items: 3'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
