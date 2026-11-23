import 'package:easyfleet_transporter/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Device-level smoke test: the app boots, initializes Supabase and lands
/// on the login screen. Run with:
///   flutter test integration_test/app_test.dart \
///     --dart-define=SUPABASE_ANON_KEY=`<publishable-key>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('transporter app launches to login', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('EasyFleet Transporter'), findsWidgets);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
