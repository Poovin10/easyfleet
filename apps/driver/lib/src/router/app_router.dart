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
            const SplashScreen(appName: 'EasyFleet Driver'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            const LoginScreen(appName: 'EasyFleet Driver', enableSignUp: true),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Driver dashboard',
              icon: Icons.dashboard_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.jobs,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Driver job market',
              icon: Icons.work_outline,
            ),
            routes: [
              GoRoute(
                path: ':jobId',
                builder: (context, state) => PlaceholderScreen(
                  title: 'Job ${state.pathParameters['jobId']}',
                  icon: Icons.description_outlined,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.myApplications,
            builder: (context, state) => const PlaceholderScreen(
              title: 'My applications',
              icon: Icons.assignment_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.assignments,
            builder: (context, state) => const PlaceholderScreen(
              title: 'My appointment',
              icon: Icons.handshake_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.driverProfile,
            builder: (context, state) => const PlaceholderScreen(
              title: 'DL profile & verification',
              icon: Icons.badge_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.trips,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Trips & logbook',
              icon: Icons.route_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.liveTracking,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Live tracking',
              icon: Icons.gps_fixed,
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

class DriverShell extends StatelessWidget {
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
