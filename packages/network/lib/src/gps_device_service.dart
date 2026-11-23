import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final gpsDeviceServiceProvider = Provider<GpsDeviceService>((ref) {
  return GpsDeviceService(ref.watch(supabaseClientProvider));
});

/// Fleet vehicle and location access aligned to the live schema.
///
/// The backend has no `gps_devices` or `gps_positions` tables. Vehicles are
/// stored in `fleet_vehicles`; phone positions are `trip_location_breadcrumbs`
/// scoped by `trip_id`. See `MISSING-BACKEND-CAPABILITIES.md` (M-02).
class GpsDeviceService {
  GpsDeviceService(this._client);

  final SupabaseClient _client;

  /// Lists company vehicles as a read-only tracker-style view.
  Future<List<GpsDevice>> devicesForTransporter(String companyId) async {
    final rows = await _client
        .from(Tables.fleetVehicles)
        .select()
        .eq('company_id', companyId)
        .order('registration_number');
    return rows
        .map(
          (row) => GpsDevice(
            id: row['id'] as String,
            imei: (row['registration_number'] as String?) ?? '',
            transporterId: companyId,
            status: _deviceStatus(row['status'] as String?),
            vehicleNumber: row['registration_number'] as String?,
          ),
        )
        .toList();
  }

  /// The backend has no GPS device registry.
  Never bindDevice({
    required String imei,
    required String transporterId,
    required String vehicleNumber,
    String? simNumber,
  }) => throw UnsupportedError(
    'GPS device binding is not available. Create a fleet vehicle with the '
    'easyfleet_create_vehicle RPC instead.',
  );

  /// The backend has no `gps_positions` table.
  Never watchDevicePositions(String transporterId) => throw UnsupportedError(
    'GPS device positions are not available. Use '
    'watchPhonePositions(tripId) for trip_location_breadcrumbs.',
  );

  /// Streams phone breadcrumbs for one trip.
  Stream<List<Map<String, dynamic>>> watchPhonePositions(String tripId) {
    return _client
        .from(Tables.tripLocationBreadcrumbs)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId);
  }

  GpsDeviceStatus _deviceStatus(String? backendStatus) =>
      switch (backendStatus) {
        'AVAILABLE' || 'ASSIGNED' || 'ON_TRIP' => GpsDeviceStatus.active,
        'IN_MAINTENANCE' => GpsDeviceStatus.faulty,
        'INACTIVE' => GpsDeviceStatus.offline,
        _ => GpsDeviceStatus.unbound,
      };
}
