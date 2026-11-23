import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'src/background/tracking_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = EnvironmentConfig.instance;
  await Supabase.initialize(
    url: environment.supabaseUrl,
    anonKey: environment.supabaseAnonKey,
  );

  await configureTripTrackingBackgroundService();
  final prefs = await SharedPreferences.getInstance();
  if ((prefs.getString(activeTripPreferenceKey) ?? '').isNotEmpty) {
    await TripTrackingBackground.start(
      prefs.getString(activeTripPreferenceKey)!,
    );
  }

  runApp(const ProviderScope(child: DriverApp()));
}
