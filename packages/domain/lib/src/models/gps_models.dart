import 'parse.dart';

/// Row from `public.gps_providers`.
class GpsProvider {
  const GpsProvider({
    required this.id,
    required this.displayName,
    required this.adapterKind,
    this.credentialFields = const [],
    this.defaultConfig = const {},
  });

  factory GpsProvider.fromJson(Map<String, dynamic> j) => GpsProvider(
    id: strReq(j['id']),
    displayName: strReq(j['display_name']),
    adapterKind: strReq(j['adapter_kind'], 'GENERIC_HTTP_JSON'),
    credentialFields: (j['credential_fields'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
    defaultConfig: jsonMap(j['default_config']),
  );

  final String id;
  final String displayName;
  final String adapterKind;
  final List<Map<String, dynamic>> credentialFields;
  final Map<String, dynamic> defaultConfig;
}

/// Masked credential metadata from `easyfleet_list_gps_credentials`.
class GpsCredential {
  const GpsCredential({
    required this.id,
    required this.providerId,
    required this.label,
    this.config = const {},
    this.updatedAt,
  });

  factory GpsCredential.fromJson(Map<String, dynamic> j) => GpsCredential(
    id: strReq(j['id']),
    providerId: strReq(j['provider_id']),
    label: strReq(j['label'], 'default'),
    config: jsonMap(j['config']),
    updatedAt: dt(j['updated_at']),
  );

  final String id;
  final String providerId;
  final String label;
  final Map<String, dynamic> config;
  final DateTime? updatedAt;
}

/// Row from `public.gps_devices`.
class GpsDevice {
  const GpsDevice({
    required this.id,
    required this.companyId,
    required this.providerId,
    required this.externalDeviceId,
    this.credentialId,
    this.imei,
    this.simNumber,
    this.label,
    this.vehicleId,
    required this.status,
    this.lastSeenAt,
    this.lastLatitude,
    this.lastLongitude,
    this.vehicleNumber,
  });

  factory GpsDevice.fromJson(Map<String, dynamic> j) => GpsDevice(
    id: strReq(j['id']),
    companyId: strReq(j['company_id']),
    providerId: strReq(j['provider_id']),
    externalDeviceId: strReq(j['external_device_id']),
    credentialId: str(j['credential_id']),
    imei: str(j['imei']),
    simNumber: str(j['sim_number']),
    label: str(j['label']),
    vehicleId: str(j['vehicle_id']),
    status: strReq(j['status'], 'UNBOUND'),
    lastSeenAt: dt(j['last_seen_at']),
    lastLatitude: dbl(j['last_latitude']),
    lastLongitude: dbl(j['last_longitude']),
    vehicleNumber: str(
      j['fleet_vehicles'] is Map
          ? j['fleet_vehicles']['registration_number']
          : null,
    ),
  );

  final String id;
  final String companyId;
  final String providerId;
  final String externalDeviceId;
  final String? credentialId;
  final String? imei;
  final String? simNumber;
  final String? label;
  final String? vehicleId;
  final String status;
  final DateTime? lastSeenAt;
  final double? lastLatitude;
  final double? lastLongitude;
  final String? vehicleNumber;

  /// A device is considered stale when no position arrived for 30 minutes.
  bool get isStale =>
      lastSeenAt == null ||
      DateTime.now().difference(lastSeenAt!) > const Duration(minutes: 30);

  bool get isBound => vehicleId != null && vehicleId!.isNotEmpty;
}

/// Row from `public.gps_device_positions`.
class GpsPosition {
  const GpsPosition({
    required this.id,
    required this.deviceId,
    required this.companyId,
    this.tripId,
    required this.latitude,
    required this.longitude,
    this.speedKmh,
    this.heading,
    required this.recordedAt,
  });

  factory GpsPosition.fromJson(Map<String, dynamic> j) => GpsPosition(
    id: strReq(j['id']),
    deviceId: strReq(j['device_id']),
    companyId: strReq(j['company_id']),
    tripId: str(j['trip_id']),
    latitude: dbl(j['latitude']) ?? 0,
    longitude: dbl(j['longitude']) ?? 0,
    speedKmh: dbl(j['speed_kmh']),
    heading: dbl(j['heading']),
    recordedAt: dtReq(j['recorded_at']),
  );

  final String id;
  final String deviceId;
  final String companyId;
  final String? tripId;
  final double latitude;
  final double longitude;
  final double? speedKmh;
  final double? heading;
  final DateTime recordedAt;
}
