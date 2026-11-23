import 'dart:async';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Key used by both isolates to remember the trip being tracked.
const activeTripPreferenceKey = 'easyfleet.active_trip_id';

/// Configures the Android foreground service once, at app startup.
Future<void> configureTripTrackingBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: driverTrackingBackgroundEntry,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      notificationChannelId: 'easyfleet_tracking',
      initialNotificationTitle: 'EasyFleet trip tracking',
      initialNotificationContent: 'Preparing GPS tracking…',
      foregroundServiceNotificationId: 112234,
      foregroundServiceTypes: const [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(autoStart: false),
  );
}

/// Main-isolate helper used by the tracking screen.
class TripTrackingBackground {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<bool> isRunning() => _service.isRunning();

  static Future<void> start(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeTripPreferenceKey, tripId);
    if (!await _service.isRunning()) await _service.startService();
  }

  static Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeTripPreferenceKey);
    if (await _service.isRunning()) _service.invoke('stopService');
  }
}

bool _capturing = false;

/// Background isolate entry point. Keeps a foreground service alive, captures
/// one GPS fix every 15 seconds for the active trip and flushes the offline
/// queue. Every write uses the same idempotent outbox contract as the UI.
@pragma('vm:entry-point')
Future<void> driverTrackingBackgroundEntry(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = EnvironmentConfig.instance;
  await Supabase.initialize(
    url: environment.supabaseUrl,
    anonKey: environment.supabaseAnonKey,
  );
  final repository = await OutboxRepository.create();
  final sync = SyncService(repository, Supabase.instance.client, () => true);
  final prefs = await SharedPreferences.getInstance();

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
    await service.setForegroundNotificationInfo(
      title: 'EasyFleet trip tracking',
      content: 'Waiting for an active trip…',
    );
  }

  Timer? ticker;
  ticker = Timer.periodic(const Duration(seconds: 15), (_) async {
    if (_capturing) return;
    _capturing = true;
    try {
      final tripId = prefs.getString(activeTripPreferenceKey);
      if (tripId == null || tripId.isEmpty) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      await repository.enqueueBreadcrumb(
        breadcrumbId: newId(),
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        recordedAt: position.timestamp,
        idempotencyKey: newId(),
      );
      final synced = await sync.flush();
      if (service is AndroidServiceInstance) {
        final pending = await repository.pendingBreadcrumbCount();
        await service.setForegroundNotificationInfo(
          title: 'EasyFleet trip tracking',
          content: pending > 0
              ? '$pending GPS point(s) queued · $synced synced just now'
              : 'GPS tracking active · trip $tripId',
        );
      }
    } catch (error) {
      // The queue is intact; the next tick or the UI sync loop retries.
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'EasyFleet trip tracking',
          content: 'Waiting for location permission or network…',
        );
      }
    } finally {
      _capturing = false;
    }
  });

  service.on('stopService').listen((_) async {
    ticker?.cancel();
    await service.stopSelf();
  });
}
