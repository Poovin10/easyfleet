import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Transporter fleet map. Positions are streamed from Supabase Realtime.
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
  GoogleMapController? _controller;
  Set<Marker> _markers = const <Marker>{};

  @override
  void initState() {
    super.initState();
    widget.positions.listen(_onPositions);
  }

  void _onPositions(List<VehiclePosition> positions) {
    if (!mounted) return;
    setState(() {
      _markers = positions.map(_markerFor).toSet();
    });
  }

  Marker _markerFor(VehiclePosition position) {
    return Marker(
      markerId: MarkerId(position.vehicleId),
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading ?? 0,
      infoWindow: InfoWindow(
        title: position.vehicleNumber,
        snippet: position.tripId ?? 'No active trip',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: widget.initialTarget, zoom: 5),
      onMapCreated: (controller) => _controller = controller,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
