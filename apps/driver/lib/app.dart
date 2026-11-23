import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/router/app_router.dart';

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'EasyFleet Driver',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) => ForceUpdateGate(
        currentVersion: ref.watch(currentAppVersionProvider),
        minimumVersion: ref.watch(minimumSupportedVersionProvider),
        child: ConnectivityGate(
          connectivityStream: ref.watch(connectivityGateStreamProvider),
          offlineMessage: 'Offline — changes are queued and sync on reconnect.',
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
