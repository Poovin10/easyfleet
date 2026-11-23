import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_transporter/src/features/company_gate.dart';
import 'package:easyfleet_transporter/src/features/subscription_screen.dart';
import 'package:easyfleet_transporter/src/features/vehicles_screen.dart';
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
}
