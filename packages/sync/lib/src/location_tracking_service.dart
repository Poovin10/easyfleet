import 'dart:async';

import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'outbox_repository.dart';
import 'sync_service.dart';

final locationTrackingServiceProvider = FutureProvider<LocationTrackingService>(
  (ref) async {
    final repository = await ref.watch(outboxRepositoryProvider.future);
    return LocationTrackingService(repository);
  },
);

/// Driver phone GPS capture. Positions are queued locally first (offline
/// safe) and flushed to `trip_location_breadcrumbs` by the sync loop with
/// idempotency keys, matching the native LiveTrackingService contract
/// (~15 s interval, 10 m minimum displacement).
class LocationTrackingService {
  LocationTrackingService(this._repository);

  final OutboxRepository _repository;
  StreamSubscription<Position>? _subscription;

  String? _activeTripId;
  String? get activeTripId => _activeTripId;
  bool get isTracking => _subscription != null;

  /// Requests permission and starts capturing for [tripId].
  Future<void> start(String tripId) async {
    if (isTracking) await stop();

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission is required for live tracking');
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError('Location services are disabled on this device');
    }

    _activeTripId = tripId;
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            timeLimit: Duration(seconds: 30),
          ),
        ).listen(
          (position) => _enqueue(tripId, position),
          onError: (Object error) {
            // Keep the queue intact; transient GPS errors must not lose data.
          },
        );

    // Seed with a one-shot fix so tracking shows immediately.
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await _enqueue(tripId, position);
    } catch (_) {
      // Stream fixes will follow.
    }
  }

  Future<void> _enqueue(String tripId, Position position) async {
    await _repository.enqueueBreadcrumb(
      breadcrumbId: newId(),
      tripId: tripId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      recordedAt: position.timestamp,
      idempotencyKey: newId(),
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeTripId = null;
  }
}
