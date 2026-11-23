import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'company_service.dart';
import 'gps_provider_adapter.dart';
import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final gpsDeviceServiceProvider = Provider<GpsDeviceService>((ref) {
  return GpsDeviceService(ref.watch(supabaseClientProvider));
});

/// Provider-independent GPS integration: device registry, per-company
/// encrypted credentials, vehicle mapping and position ingestion.
class GpsDeviceService {
  GpsDeviceService(this._client);

  final SupabaseClient _client;

  Future<List<GpsProvider>> providers() async {
    final rows = await _client.from(Tables.gpsProviders).select();
    return rows.map(GpsProvider.fromJson).toList();
  }

  Future<List<GpsCredential>> credentials(String companyId) async {
    final rows = await _client.rpc<List<dynamic>>(
      RpcNames.listGpsCredentials,
      params: {'p_company_id': companyId},
    );
    return rows
        .map((r) => GpsCredential.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<String> saveCredentials({
    required String companyId,
    required String providerId,
    required String label,
    required Map<String, dynamic> credentials,
    required Map<String, dynamic> config,
  }) async {
    final result = await _client.rpc<dynamic>(
      RpcNames.setGpsCredentials,
      params: {
        'p_company_id': companyId,
        'p_provider_id': providerId,
        'p_label': label,
        'p_credentials_json': credentials,
        'p_config': config,
      },
    );
    return result.toString();
  }

  Future<List<GpsDevice>> devices(String companyId) async {
    final rows = await _client
        .from(Tables.gpsDevices)
        .select('*, fleet_vehicles(registration_number)')
        .eq('company_id', companyId)
        .order('created_at');
    return rows.map(GpsDevice.fromJson).toList();
  }

  Future<String> registerDevice({
    required String companyId,
    required String providerId,
    required String externalDeviceId,
    String? credentialId,
    String? imei,
    String? simNumber,
    String? label,
  }) async {
    final deviceId = newId();
    final result = await _client.rpc<dynamic>(
      RpcNames.registerGpsDevice,
      params: {
        'p_company_id': companyId,
        'p_device_id': deviceId,
        'p_provider_id': providerId,
        'p_external_device_id': externalDeviceId.trim(),
        'p_credential_id': credentialId,
        'p_imei': imei,
        'p_sim_number': simNumber,
        'p_label': label,
      },
    );
    return result.toString();
  }

  Future<void> assignDevice({
    required String companyId,
    required String deviceId,
    String? vehicleId,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.assignGpsDevice,
      params: {
        'p_company_id': companyId,
        'p_device_id': deviceId,
        'p_vehicle_id': vehicleId,
      },
    );
  }

  Future<void> setDeviceStatus({
    required String companyId,
    required String deviceId,
    required String status,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.setGpsDeviceStatus,
      params: {
        'p_company_id': companyId,
        'p_device_id': deviceId,
        'p_status': status,
      },
    );
  }

  Future<List<GpsPosition>> devicePositions(
    String deviceId, {
    int limit = 200,
  }) async {
    final rows = await _client
        .from(Tables.gpsDevicePositions)
        .select()
        .eq('device_id', deviceId)
        .order('recorded_at', ascending: false)
        .limit(limit);
    return rows.map(GpsPosition.fromJson).toList();
  }

  Stream<List<GpsDevice>> watchDevices(String companyId) {
    return _client
        .from(Tables.gpsDevices)
        .stream(primaryKey: ['id'])
        .eq('company_id', companyId)
        .map((rows) => rows.map(GpsDevice.fromJson).toList());
  }

  /// Fetches positions from the provider API using the company's stored
  /// credentials and ingests them server-side. Returns the number of new
  /// points recorded. Works with any provider configured through the
  /// generic HTTP/JSON adapter.
  Future<int> syncDevice({
    required String companyId,
    required GpsDevice device,
    DateTime? since,
  }) async {
    if (device.credentialId == null) {
      throw StateError('Device has no provider credentials configured');
    }
    final bundle = await _client.rpc<Map<String, dynamic>>(
      RpcNames.getGpsCredentials,
      params: {'p_credential_id': device.credentialId},
    );
    final adapter = GenericHttpJsonAdapter();
    final positions = await adapter.fetchPositions(
      credentials: Map<String, dynamic>.from(bundle['credentials'] as Map),
      config: Map<String, dynamic>.from(bundle['config'] as Map),
      externalDeviceId: device.externalDeviceId,
      since: since,
    );
    if (positions.isEmpty) return 0;
    final result = await _client.rpc<dynamic>(
      RpcNames.ingestDevicePositions,
      params: {
        'p_company_id': companyId,
        'p_device_id': device.id,
        'p_positions': positions.map((p) => p.toJson()).toList(),
        'p_idempotency_key': newId(),
      },
    );
    return int.tryParse(result.toString()) ?? 0;
  }
}
