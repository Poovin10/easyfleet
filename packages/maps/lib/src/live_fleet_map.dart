import 'dart:async';

import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Transporter fleet map. Positions are streamed from Supabase Realtime.
/// Uses OpenStreetMap tiles so no maps API key is required.
class LiveFleetMap extends StatefulWidget {
  const LiveFleetMap({
    super.key,
    required this.positions,
    this.initialTarget = const LatLng(20.5937, 78.9629),
  });

  final Stream<List<VehiclePosition>> positions;
  final LatLng initialTarget;

  @override
  State<LiveFleetMap> createState() => _LiveFleetMapState();
}

class _LiveFleetMapState extends State<LiveFleetMap> {
  final MapController _controller = MapController();
  StreamSubscription<List<VehiclePosition>>? _subscription;
  List<VehiclePosition> _positions = const [];

  @override
  void initState() {
    super.initState();
    _subscription = widget.positions.listen(_onPositions);
  }

  @override
  void didUpdateWidget(LiveFleetMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.positions != widget.positions) {
      _subscription?.cancel();
      _subscription = widget.positions.listen(_onPositions);
    }
  }

  void _onPositions(List<VehiclePosition> positions) {
    if (!mounted) return;
    setState(() => _positions = positions);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.initialTarget,
        initialZoom: 5,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'in.easyfleet.app',
        ),
        MarkerLayer(
          markers: [
            for (final position in _positions)
              Marker(
                point: LatLng(position.latitude, position.longitude),
                width: 44,
                height: 44,
                child: Tooltip(
                  message:
                      '${position.vehicleNumber}${position.tripId == null ? '' : ' • on trip'}',
                  child: Icon(
                    Icons.local_shipping,
                    color: scheme.primary,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
