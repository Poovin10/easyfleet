import 'dart:async';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Driver trip map: breadcrumb trail and current position.
/// Uses OpenStreetMap tiles so no maps API key is required.
class TripRouteMap extends StatefulWidget {
  const TripRouteMap({
    super.key,
    required this.breadcrumbs,
    this.currentPosition,
    this.eta,
  });

  final Stream<List<LocationBreadcrumb>> breadcrumbs;
  final Stream<LocationPoint>? currentPosition;
  final Duration? eta;

  @override
  State<TripRouteMap> createState() => _TripRouteMapState();
}

class _TripRouteMapState extends State<TripRouteMap> {
  final MapController _controller = MapController();
  StreamSubscription<List<LocationBreadcrumb>>? _breadcrumbSub;
  StreamSubscription<LocationPoint>? _positionSub;
  List<LatLng> _trail = const [];
  LatLng? _current;

  @override
  void initState() {
    super.initState();
    _breadcrumbSub = widget.breadcrumbs.listen(_onBreadcrumbs);
    _positionSub = widget.currentPosition?.listen(_onCurrentPosition);
  }

  @override
  void didUpdateWidget(TripRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breadcrumbs != widget.breadcrumbs) {
      _breadcrumbSub?.cancel();
      _breadcrumbSub = widget.breadcrumbs.listen(_onBreadcrumbs);
    }
    if (oldWidget.currentPosition != widget.currentPosition) {
      _positionSub?.cancel();
      _positionSub = widget.currentPosition?.listen(_onCurrentPosition);
    }
  }

  void _onBreadcrumbs(List<LocationBreadcrumb> breadcrumbs) {
    if (!mounted || breadcrumbs.isEmpty) return;
    setState(() {
      _trail = breadcrumbs
          .map((b) => LatLng(b.latitude, b.longitude))
          .toList(growable: false);
      _current = _trail.last;
    });
  }

  void _onCurrentPosition(LocationPoint point) {
    if (!mounted) return;
    setState(() => _current = LatLng(point.latitude, point.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final et = widget.eta;
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: _current ?? const LatLng(20.5937, 78.9629),
            initialZoom: _current == null ? 5 : 13,
            minZoom: 3,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.easyfleet.app',
            ),
            if (_trail.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trail,
                    color: scheme.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
            if (_current != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _current!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.my_location,
                      color: scheme.secondary,
                      size: 30,
                    ),
                  ),
                ],
              ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        if (et != null)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text('ETA ${et.inMinutes} min'),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _breadcrumbSub?.cancel();
    _positionSub?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
