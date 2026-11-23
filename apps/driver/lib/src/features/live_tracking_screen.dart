import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_maps/easyfleet_maps.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_sync/easyfleet_sync.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../background/tracking_background.dart';

final _trackableTripsProvider = FutureProvider<List<FleetTrip>>((ref) async {
  ref.watch(driverAccountProvider);
  final trips = await ref.watch(fleetServiceProvider).myDriverTrips();
  return trips
      .where((t) => t.status == 'IN_TRANSIT' || t.status == 'ASSIGNED')
      .toList();
});

/// Live tracking: captures phone GPS for the selected active trip and
/// queues breadcrumbs for idempotent sync.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  String? _selectedTripId;
  bool _starting = false;
  Stream<List<LocationBreadcrumb>>? _trailStream;
  String? _trailTripId;

  Stream<List<LocationBreadcrumb>> _trailFor(String tripId) {
    if (_trailTripId != tripId || _trailStream == null) {
      _trailTripId = tripId;
      _trailStream = ref
          .read(fleetServiceProvider)
          .watchTripLocations(tripId)
          .map(
            (points) => points
                .map(
                  (p) => LocationBreadcrumb(
                    idempotencyKey: p.id,
                    tripId: p.tripId,
                    latitude: p.latitude,
                    longitude: p.longitude,
                    accuracy: p.accuracyMeters,
                    recordedAt: p.recordedAt,
                  ),
                )
                .toList(),
          );
    }
    return _trailStream!;
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(_trackableTripsProvider);
    final syncState = ref.watch(syncControllerProvider);
    final trackingAsync = ref.watch(locationTrackingServiceProvider);
    final tracking = trackingAsync.value;
    final isTracking = tracking?.isTracking ?? false;
    final activeTripId = tracking?.activeTripId ?? _selectedTripId;

    return AppScaffold(
      title: 'Live tracking',
      body: Column(
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AsyncView(
                  value: trips,
                  onRetry: () => ref.invalidate(_trackableTripsProvider),
                  isEmpty: (list) => list.isEmpty,
                  emptyMessage:
                      'No active trip to track. Start an assigned trip first.',
                  builder: (list) => DropdownButtonFormField<String>(
                    initialValue: list.any((t) => t.id == _selectedTripId)
                        ? _selectedTripId
                        : (list.isNotEmpty ? list.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Trip to track',
                    ),
                    items: [
                      for (final trip in list)
                        DropdownMenuItem(
                          value: trip.id,
                          child: Text(
                            '${trip.origin} → ${trip.destination}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: isTracking
                        ? null
                        : (value) => setState(() => _selectedTripId = value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _starting || trackingAsync.isLoading
                            ? null
                            : () async {
                                final service = trackingAsync.value;
                                if (service == null) return;
                                if (isTracking) {
                                  await service.stop();
                                  await TripTrackingBackground.stop();
                                  setState(() {});
                                  return;
                                }
                                final tripId =
                                    _selectedTripId ??
                                    (trips.value?.isNotEmpty == true
                                        ? trips.value!.first.id
                                        : null);
                                if (tripId == null) {
                                  showErrorSnack(
                                    context,
                                    'Select a trip first',
                                  );
                                  return;
                                }
                                setState(() => _starting = true);
                                try {
                                  await service.start(tripId);
                                  await TripTrackingBackground.start(tripId);
                                  setState(() => _selectedTripId = tripId);
                                  if (context.mounted) {
                                    showSuccessSnack(
                                      context,
                                      'Tracking started',
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    showErrorSnack(context, error);
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _starting = false);
                                  }
                                }
                              },
                        icon: Icon(isTracking ? Icons.stop : Icons.gps_fixed),
                        label: Text(
                          isTracking
                              ? 'Stop tracking'
                              : (_starting ? 'Starting…' : 'Start tracking'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isTracking
                      ? 'Capturing GPS in the foreground service. '
                            '${syncState.pending} point(s) queued for sync.'
                      : 'Tracking is off. The foreground service captures a '
                            'fix every 15 s while the app is in the background.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: activeTripId == null
                ? const EmptyView(
                    message: 'Select a trip to see its route',
                    icon: Icons.map_outlined,
                  )
                : TripRouteMap(breadcrumbs: _trailFor(activeTripId)),
          ),
        ],
      ),
    );
  }
}
