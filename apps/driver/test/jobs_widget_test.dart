import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_driver/src/features/jobs_screen.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _dummyClient() => SupabaseClient(
  'https://test.invalid',
  'test-anon-key',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);

class FakeMarketplaceService extends MarketplaceService {
  FakeMarketplaceService() : super(_dummyClient());

  final List<JobPosting> jobs = [
    const JobPosting(
      id: 'j1',
      companyId: 'c1',
      title: 'HMV driver Kochi-Chennai',
      status: 'OPEN',
      origin: 'Kochi',
      destination: 'Chennai',
      requiredLicenceClasses: ['HMV'],
      rateAmount: 25000,
      rateUnit: 'PER_TRIP',
      companyName: 'Test Transport Co',
    ),
    const JobPosting(
      id: 'j2',
      companyId: 'c1',
      title: 'Tanker driver',
      status: 'OPEN',
      requiredLicenceClasses: ['HAZARDOUS_GOODS'],
    ),
  ];

  String? appliedJobId;
  String? appliedCoverNote;

  @override
  Future<List<JobPosting>> searchJobs({
    String? licenceClass,
    String? location,
    int limit = 50,
  }) async => jobs;

  @override
  Future<JobPosting?> job(String jobId) async =>
      jobs.where((j) => j.id == jobId).firstOrNull;

  @override
  Future<String> applyToJob({
    required String jobId,
    String? coverNote,
    String? idempotencyKey,
  }) async {
    appliedJobId = jobId;
    appliedCoverNote = coverNote;
    return 'app-1';
  }
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
  testWidgets('login screen validates email and password', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LoginScreen(appName: 'EasyFleet Driver', enableSignUp: true),
        [supabaseClientProvider.overrideWithValue(_dummyClient())],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('driver job market lists open jobs from the backend service', (
    tester,
  ) async {
    final fake = FakeMarketplaceService();
    await tester.pumpWidget(
      _wrap(const DriverJobsScreen(), [
        marketplaceServiceProvider.overrideWithValue(fake),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('HMV driver Kochi-Chennai'), findsOneWidget);
    expect(find.text('Tanker driver'), findsOneWidget);
    expect(find.text('Test Transport Co • Kochi → Chennai'), findsOneWidget);
  });

  testWidgets('driver can apply to a job with a cover note', (tester) async {
    final fake = FakeMarketplaceService();
    await tester.pumpWidget(
      _wrap(const DriverJobDetailScreen(jobId: 'j1'), [
        marketplaceServiceProvider.overrideWithValue(fake),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apply to this job'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'I know this route well',
    );
    await tester.tap(find.text('Apply to this job'));
    await tester.pumpAndSettle();

    expect(fake.appliedJobId, 'j1');
    expect(fake.appliedCoverNote, 'I know this route well');
    expect(find.text('Application submitted'), findsOneWidget);
  });
}
