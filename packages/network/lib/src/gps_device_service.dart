import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final gpsDeviceServiceProvider = Provider<GpsDeviceService>((ref) {
  return GpsDeviceService(ref.watch(supabaseClientProvider));
});

/// Binds transporter-owned GPS trackers to trucks and exposes their live positions.
class GpsDeviceService {
  GpsDeviceService(this._client);

  final SupabaseClient _client;

  Future<List<GpsDevice>> devicesForTransporter(String transporterId) async {
    final rows = await _client
        .from(Tables.gpsDevices)
        .select()
        .eq('transporter_id', transporterId)
        .order('imei');
    return rows
        .map((row) => GpsDevice.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> bindDevice({
    required String imei,
    required String transporterId,
    required String vehicleNumber,
    String? simNumber,
  }) {
    return _client.from(Tables.gpsDevices).upsert({
      'imei': imei.toUpperCase(),
      'transporter_id': transporterId,
      'vehicle_number': vehicleNumber,
      'sim_number': simNumber,
      'status': 'active',
    }, onConflict: 'imei');
  }

  /// Device positions and phone breadcrumbs are merged by the maps package.
  Stream<List<Map<String, dynamic>>> watchDevicePositions(
    String transporterId,
  ) {
    return _client
        .from(Tables.gpsPositions)
        .stream(primaryKey: ['id'])
        .eq('transporter_id', transporterId);
  }

  Stream<List<Map<String, dynamic>>> watchPhonePositions(String transporterId) {
    return _client
        .from(Tables.tripLocationBreadcrumbs)
        .stream(primaryKey: ['id'])
        .eq('transporter_id', transporterId);
  }
}
