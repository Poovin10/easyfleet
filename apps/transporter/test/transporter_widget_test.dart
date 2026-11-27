import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_transporter/src/features/company_gate.dart';
import 'package:easyfleet_transporter/src/features/drivers_screen.dart';
import 'package:easyfleet_transporter/src/features/settings_screen.dart';
import 'package:easyfleet_transporter/src/features/subscription_screen.dart';
import 'package:easyfleet_transporter/src/features/vehicles_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

SupabaseClient _dummyClient() => SupabaseClient(
  'https://test.invalid',
  'test-anon-key',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);

const _membership = CompanyMembership(
  id: 'm1',
  companyId: 'c1',
  userId: 'u1',
  role: 'OWNER',
  status: 'ACTIVE',
  companyName: 'Test Transport Co',
);

class FakeCompanyService extends CompanyService {
  FakeCompanyService() : super(_dummyClient());

  String? registeredName;

  @override
  Future<String> registerCompany({
    required String name,
    String? legalName,
  }) async {
    registeredName = name;
    return 'c-new';
  }

  @override
  Future<List<CompanyMembership>> myMemberships() async => [_membership];
}

class FakeFleetService extends FleetService {
  FakeFleetService() : super(_dummyClient());

  String? manualDriverName;
  String? manualDriverPhone;

  @override
  Future<List<FleetVehicle>> vehicles(String companyId) async => [
    const FleetVehicle(
      id: 'v1',
      companyId: 'c1',
      registrationNumber: 'KL01AB1234',
      vehicleType: 'TRUCK',
      status: 'AVAILABLE',
      odometerKm: 12000,
    ),
  ];

  @override
  Future<List<Map<String, dynamic>>> vehicleDocuments(
    String companyId,
    String vehicleId,
  ) async => [
    {
      'document_type': 'rc',
      'document_number': 'KL01AB1234',
      'expiry_date': '2030-01-31',
    },
  ];

  @override
  Future<String> addManualDriver({
    required String companyId,
    required String displayName,
    String? phoneE164,
    String? localDriverCode,
  }) async {
    manualDriverName = displayName;
    manualDriverPhone = phoneE164;
    return 'driver-new';
  }
}

class FakeSubscriptionService extends SubscriptionService {
  FakeSubscriptionService() : super(_dummyClient());

  bool payCalled = false;
  String? payMethod;

  @override
  Future<List<SubscriptionPlan>> plans() async => [
    const SubscriptionPlan(
      id: 'TRANSPORTER_MONTHLY',
      name: 'EasyFleet Transporter Monthly',
      priceInr: 1500,
      durationDays: 30,
    ),
  ];

  @override
  Future<CompanySubscription?> subscription(String companyId) async =>
      CompanySubscription(
        id: 's1',
        companyId: companyId,
        planId: 'TRANSPORTER_MONTHLY',
        status: 'TRIAL',
        startedAt: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 12)),
      );

  @override
  Future<List<PaymentTransaction>> billingHistory(String companyId) async =>
      const [];

  @override
  Future<void> pay({
    required String companyId,
    required String planId,
    required String method,
    String? providerReference,
    String? notes,
    String? idempotencyKey,
  }) async {
    payCalled = true;
    payMethod = method;
  }
}

class FakeMarketplaceService extends MarketplaceService {
  FakeMarketplaceService() : super(_dummyClient());

  bool lookupCalled = false;

  @override
  Future<List<DriverSearchResult>> searchDrivers({
    String? licenceClass,
    String? state,
    int limit = 50,
  }) async => [
    const DriverSearchResult(
      driverAccountId: 'd1',
      displayName: 'Verified Driver',
      licenceClass: 'HMV',
      issuingState: 'Kerala',
      verificationStatus: 'VERIFIED',
    ),
  ];

  @override
  Future<DriverContact> lookupDriverContact(
    String driverAccountId, {
    String? idempotencyKey,
  }) async {
    lookupCalled = true;
    return DriverContact(
      driverAccountId: driverAccountId,
      displayName: 'Verified Driver',
      phoneE164: '+919876543210',
      amountInr: 100,
      lookupId: 'lookup-1',
    );
  }
}

class FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    userId: 'u1',
    email: 'owner@example.com',
    displayName: 'Test Owner',
  );
}

class FakeSyncController extends SyncController {
  @override
  SyncLoopState build() => const SyncLoopState(pending: 2, deadLetters: 1);
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
  testWidgets('company registration validates the name', (tester) async {
    final fake = FakeCompanyService();
    await tester.pumpWidget(
      _wrap(const CompanySetupScreen(), [
        companyServiceProvider.overrideWithValue(fake),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register company'));
    await tester.pumpAndSettle();
    expect(find.text('Enter at least 2 characters'), findsOneWidget);
    expect(fake.registeredName, isNull);
  });

  testWidgets('company registration calls the backend RPC service', (
    tester,
  ) async {
    final fake = FakeCompanyService();
    await tester.pumpWidget(
      _wrap(const CompanySetupScreen(), [
        companyServiceProvider.overrideWithValue(fake),
        supabaseClientProvider.overrideWithValue(_dummyClient()),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Kerala Movers');
    await tester.tap(find.text('Register company'));
    await tester.pumpAndSettle();

    expect(fake.registeredName, 'Kerala Movers');
    expect(
      find.text('Company registered. A 30-day trial has started.'),
      findsOneWidget,
    );
  });

  testWidgets('vehicles screen lists live fleet vehicles', (tester) async {
    await tester.pumpWidget(
      _wrap(const VehiclesScreen(), [
        companyContextProvider.overrideWith((ref) async => _membership),
        fleetServiceProvider.overrideWithValue(FakeFleetService()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('KL01AB1234'), findsOneWidget);
    expect(find.text('TRUCK • 12000 km'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
  });

  testWidgets('contact lookup charges ₹100 and reveals a verified phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeMarketplaceService();
    await tester.pumpWidget(
      _wrap(const FindDriversScreen(), [
        companyContextProvider.overrideWith((ref) async => _membership),
        marketplaceServiceProvider.overrideWithValue(fake),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verified Driver'), findsOneWidget);
    await tester.tap(find.text('Contact ₹100'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(fake.lookupCalled, isTrue);
    expect(find.text('+919876543210'), findsOneWidget);
    expect(find.textContaining('₹100 charged'), findsOneWidget);
  });

  testWidgets('subscription screen shows ₹1500 plan and records payment', (
    tester,
  ) async {
    final fake = FakeSubscriptionService();
    await tester.pumpWidget(
      _wrap(const SubscriptionScreen(), [
        companyContextProvider.overrideWith((ref) async => _membership),
        subscriptionServiceProvider.overrideWithValue(fake),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('₹1500 / 30 days'), findsOneWidget);
    expect(find.textContaining('Free trial'), findsOneWidget);

    await tester.tap(find.text('Pay ₹1500 / renew'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm payment'), findsOneWidget);
    await tester.tap(find.text('Record payment'));
    await tester.pumpAndSettle();

    expect(fake.payCalled, isTrue);
    expect(fake.payMethod, 'MANUAL');
  });

  testWidgets('settings exposes fleet management and account options', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const TransporterSettingsScreen(), [
        authControllerProvider.overrideWith(FakeAuthController.new),
        syncControllerProvider.overrideWith(FakeSyncController.new),
        companyContextProvider.overrideWith((ref) async => _membership),
        companyServiceProvider.overrideWithValue(FakeCompanyService()),
        supabaseClientProvider.overrideWithValue(_dummyClient()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trucks & compliance'), findsOneWidget);
    expect(
      find.text('Add trucks and upload RC, insurance, permits'),
      findsOneWidget,
    );
    expect(find.text('Drivers'), findsOneWidget);
    expect(find.text('Subscription & payments'), findsOneWidget);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Change password'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Change password'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sync now'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Sync now'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('drivers screen adds a manual driver', (tester) async {
    final fake = FakeFleetService();
    await tester.pumpWidget(
      _wrap(const DriversScreen(), [
        companyContextProvider.overrideWith((ref) async => _membership),
        fleetServiceProvider.overrideWithValue(fake),
        marketplaceServiceProvider.overrideWithValue(FakeMarketplaceService()),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add driver manually'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Manual Driver');
    await tester.enterText(fields.at(1), '+919876543210');
    await tester.tap(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Add driver'),
      ),
    );
    await tester.pumpAndSettle();

    expect(fake.manualDriverName, 'Manual Driver');
    expect(fake.manualDriverPhone, '+919876543210');
    expect(find.text('Manual Driver added to your company'), findsOneWidget);
  });

  testWidgets('compliance tab lists uploaded truck documents', (tester) async {
    await tester.pumpWidget(
      _wrap(const VehiclesScreen(), [
        companyContextProvider.overrideWith((ref) async => _membership),
        fleetServiceProvider.overrideWithValue(FakeFleetService()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add truck'), findsOneWidget);
    await tester.tap(find.text('Compliance'));
    await tester.pumpAndSettle();

    expect(find.text('1 compliance document(s)'), findsOneWidget);
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.text('RC'), findsOneWidget);
    expect(find.text('Upload compliance document'), findsOneWidget);
  });
}
