import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounting_screen.dart';
import '../features/company_gate.dart';
import '../features/company_profile_screen.dart';
import '../features/dashboard_screen.dart';
import '../features/drivers_screen.dart';
import '../features/fleet_map_screen.dart';
import '../features/gps_devices_screen.dart';
import '../features/jobs_manage_screen.dart';
import '../features/settings_screen.dart';
import '../features/subscription_screen.dart';
import '../features/trips_screen.dart';
import '../features/vehicles_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final isAuthenticated = authState.isAuthenticated;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == AppRoutes.login;
      final atSplash = state.matchedLocation == AppRoutes.splash;

      if (!isAuthenticated && !atLogin) return AppRoutes.login;
      if (isAuthenticated && (atLogin || atSplash)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            const SplashScreen(appName: 'EasyFleet Transporter'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(
          appName: 'EasyFleet Transporter',
          enableSignUp: true,
          appRole: 'transporter',
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: TransporterNotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.companyProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: CompanyProfileScreen()),
      ),
      GoRoute(
        path: '/jobs-manage',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: JobsManageScreen()),
      ),
      GoRoute(
        path: AppRoutes.trips,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: TransporterTripsScreen()),
      ),
      GoRoute(
        path: '/trips/:tripId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CompanyGate(
          child: TransporterTripDetailScreen(
            tripId: state.pathParameters['tripId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.gpsDevices,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: GpsDevicesScreen()),
      ),
      GoRoute(
        path: AppRoutes.accounting,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: AccountingScreen()),
      ),
      GoRoute(
        path: '/subscription',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CompanyGate(child: SubscriptionScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => TransporterShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const CompanyGate(child: TransporterDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.candidates,
            builder: (context, state) =>
                const CompanyGate(child: FindDriversScreen()),
          ),
          GoRoute(
            path: AppRoutes.assignments,
            builder: (context, state) =>
                const CompanyGate(child: DriversScreen()),
          ),
          GoRoute(
            path: AppRoutes.vehicles,
            builder: (context, state) =>
                const CompanyGate(child: VehiclesScreen()),
          ),
          GoRoute(
            path: AppRoutes.fleetMap,
            builder: (context, state) =>
                const CompanyGate(child: FleetMapScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) =>
                const CompanyGate(child: TransporterSettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

class TransporterShell extends ConsumerWidget {
  const TransporterShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (path: AppRoutes.home, label: 'Home', icon: Icons.home_outlined),
    (
      path: AppRoutes.candidates,
      label: 'Hire',
      icon: Icons.person_search_outlined,
    ),
    (
      path: AppRoutes.assignments,
      label: 'Drivers',
      icon: Icons.handshake_outlined,
    ),
    (
      path: AppRoutes.vehicles,
      label: 'Fleet',
      icon: Icons.local_shipping_outlined,
    ),
    (path: AppRoutes.fleetMap, label: 'Map', icon: Icons.map_outlined),
    (
      path: AppRoutes.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _destinations.indexWhere((d) => location.startsWith(d.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the offline sync loop for the signed-in session.
    ref.watch(syncControllerProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex(context),
        onDestinationSelected: (index) => context.go(_destinations[index].path),
        items: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
