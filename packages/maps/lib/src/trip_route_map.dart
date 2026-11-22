import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Driver trip map: breadcrumb trail, current vehicle position and ETA panel.
class TripRouteMap extends StatefulWidget {
  const TripRouteMap({
    super.key,
    required this.breadcrumbs,
    required this.currentPosition,
    this.eta,
  });

  final Stream<List<LocationBreadcrumb>> breadcrumbs;
  final Stream<LocationPoint> currentPosition;
  final Duration? eta;

  @override
  State<TripRouteMap> createState() => _TripRouteMapState();
}

class _TripRouteMapState extends State<TripRouteMap> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = const <Polyline>{};
  Set<Marker> _markers = const <Marker>{};

  @override
  void initState() {
    super.initState();
    widget.breadcrumbs.listen(_onBreadcrumbs);
    widget.currentPosition.listen(_onCurrentPosition);
  }

  void _onBreadcrumbs(List<LocationBreadcrumb> breadcrumbs) {
    if (!mounted || breadcrumbs.isEmpty) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('trip-trail'),
          color: Theme.of(context).colorScheme.primary,
          width: 4,
          points: breadcrumbs
              .map((b) => LatLng(b.latitude, b.longitude))
              .toList(growable: false),
        ),
      };
    });
  }

  void _onCurrentPosition(LocationPoint point) {
    if (!mounted) return;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('current-position'),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final et = widget.eta;
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 5,
          ),
          onMapCreated: (controller) => _controller = controller,
          polylines: _polylines,
          markers: _markers,
          myLocationEnabled: true,
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
    _controller?.dispose();
    super.dispose();
  }
}
