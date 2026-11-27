import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/applications_screen.dart';
import '../features/dashboard_screen.dart';
import '../features/driver_profile_screen.dart';
import '../features/jobs_screen.dart';
import '../features/live_tracking_screen.dart';
import '../features/settings_screen.dart';
import '../features/trips_screen.dart';
import '../features/wallet_screen.dart';

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
            const SplashScreen(appName: 'EasyFleet Driver'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            const LoginScreen(appName: 'EasyFleet Driver', enableSignUp: true),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.myApplications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DriverApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.assignments,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DriverAssignmentsScreen(),
      ),
      GoRoute(
        path: '/trips/:tripId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            DriverTripDetailScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/jobs/:jobId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            DriverJobDetailScreen(jobId: state.pathParameters['jobId']!),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DriverDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.jobs,
            builder: (context, state) => const DriverJobsScreen(),
          ),
          GoRoute(
            path: AppRoutes.driverProfile,
            builder: (context, state) => const DriverProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.trips,
            builder: (context, state) => const DriverTripsScreen(),
          ),
          GoRoute(
            path: AppRoutes.liveTracking,
            builder: (context, state) => const LiveTrackingScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) =>
                const SettingsScreen(appName: 'EasyFleet Driver'),
          ),
        ],
      ),
    ],
  );
});

class DriverShell extends ConsumerWidget {
  const DriverShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (path: AppRoutes.home, label: 'Home', icon: Icons.home_outlined),
    (path: AppRoutes.jobs, label: 'Jobs', icon: Icons.work_outline),
    (path: AppRoutes.trips, label: 'Trips', icon: Icons.route_outlined),
    (path: AppRoutes.liveTracking, label: 'Map', icon: Icons.map_outlined),
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
