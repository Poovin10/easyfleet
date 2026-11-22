import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/placeholder_screen.dart';

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
        builder: (context, state) =>
            const LoginScreen(appName: 'EasyFleet Transporter'),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => TransporterShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Operations dashboard',
              icon: Icons.dashboard_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.candidates,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Find drivers',
              icon: Icons.person_search_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.assignments,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Appointments',
              icon: Icons.handshake_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.gpsDevices,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Truck GPS devices',
              icon: Icons.sensors_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.companyProfile,
            builder: (context, state) => const PlaceholderScreen(
              title: 'GST profile & verification',
              icon: Icons.business_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.fleetMap,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Live fleet map',
              icon: Icons.map_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.vehicleStatus,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Vehicle status',
              icon: Icons.local_shipping_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.accounting,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Accounting & KPIs',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Settings',
              icon: Icons.settings_outlined,
            ),
          ),
        ],
      ),
    ],
  );
});

class TransporterShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) => context.go(_destinations[index].path),
        destinations: [
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
