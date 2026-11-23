import 'dart:async';

import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_maps/easyfleet_maps.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'company_gate.dart';
import 'gps_devices_screen.dart';

/// Live fleet map fed by device last-known positions (realtime).
class FleetMapScreen extends ConsumerStatefulWidget {
  const FleetMapScreen({super.key});

  @override
  ConsumerState<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends ConsumerState<FleetMapScreen> {
  StreamController<List<VehiclePosition>>? _controller;
  StreamSubscription<List<GpsDevice>>? _subscription;
  String? _companyId;

  void _bind(String companyId) {
    if (_companyId == companyId) return;
    _companyId = companyId;
    _subscription?.cancel();
    _controller?.close();
    _controller = StreamController<List<VehiclePosition>>.broadcast();
    _subscription = ref
        .read(gpsDeviceServiceProvider)
        .watchDevices(companyId)
        .listen((devices) {
          final positions = devices
              .where((d) => d.lastLatitude != null && d.lastLongitude != null)
              .map(
                (d) => VehiclePosition(
                  vehicleId: d.vehicleId ?? d.id,
                  vehicleNumber:
                      d.vehicleNumber ?? d.label ?? d.externalDeviceId,
                  latitude: d.lastLatitude!,
                  longitude: d.lastLongitude!,
                  updatedAt: d.lastSeenAt ?? DateTime.now(),
                ),
              )
              .toList();
          _controller?.add(positions);
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membership = ref.watch(companyContextProvider).value;
    final devices = ref.watch(gpsDevicesProvider);
    if (membership != null) _bind(membership.companyId);

    return AppScaffold(
      title: 'Live fleet map',
      body: Column(
        children: [
          Expanded(
            child: _controller == null
                ? const LoadingView()
                : LiveFleetMap(positions: _controller!.stream),
          ),
          SizedBox(
            height: 140,
            child: AsyncView(
              value: devices,
              isEmpty: (list) => list.isEmpty,
              emptyMessage: 'No devices with positions yet.',
              builder: (list) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.sm),
                children: [
                  for (final device in list)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: SizedBox(
                          width: 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                device.vehicleNumber ??
                                    device.label ??
                                    device.externalDeviceId,
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              StatusChip(
                                status:
                                    device.isStale && device.status == 'ACTIVE'
                                    ? 'OFFLINE'
                                    : device.status,
                                dense: true,
                              ),
                              Text(
                                device.lastSeenAt == null
                                    ? 'No position yet'
                                    : device.lastSeenAt!
                                          .toLocal()
                                          .toString()
                                          .split('.')
                                          .first,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
