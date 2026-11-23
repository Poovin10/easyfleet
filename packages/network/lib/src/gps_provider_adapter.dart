import 'package:dio/dio.dart';

/// A normalized GPS position ready for `easyfleet_ingest_device_positions`.
class NormalizedPosition {
  const NormalizedPosition({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.speedKmh,
    this.heading,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? speedKmh;
  final double? heading;
  final double? accuracyMeters;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
    if (speedKmh != null) 'speed_kmh': speedKmh,
    if (heading != null) 'heading': heading,
    if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
  };
}

/// Provider-independent adapter contract. Each GPS vendor implements this
/// interface; credentials are fetched server-side per company and never
/// hardcoded. New providers are added by registering a `gps_providers` row
/// and (when the API is not HTTP/JSON) a new adapter class.
abstract class GpsProviderAdapter {
  Future<List<NormalizedPosition>> fetchPositions({
    required Map<String, dynamic> credentials,
    required Map<String, dynamic> config,
    required String externalDeviceId,
    DateTime? since,
  });
}

/// Config-driven adapter for any HTTP/JSON GPS API.
///
/// Config keys (stored per company alongside encrypted credentials):
/// - `base_url` (required): API origin, e.g. `https://gps.vendor.com`
/// - `positions_path`: path appended to base_url, default `/positions`
/// - `auth_style`: `bearer` | `header` | `query` | `basic`
/// - `auth_header`: header name for `header` style (default `Authorization`)
/// - `auth_query_param`: query param name for `query` style (default `key`)
/// - `credential_key`: which credential field holds the token
///   (default `api_key`)
/// - `device_param`: query parameter carrying the device id (default `device_id`)
/// - `since_param`: optional query parameter for a start-time filter
/// - `items_pointer`: JSON pointer to the position array (default `/data`;
///   empty string means the response body itself is the array)
/// - `field_map`: maps normalized field -> vendor field name
/// - `time_format`: `iso8601` | `epoch_seconds` | `epoch_millis`
class GenericHttpJsonAdapter implements GpsProviderAdapter {
  GenericHttpJsonAdapter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<List<NormalizedPosition>> fetchPositions({
    required Map<String, dynamic> credentials,
    required Map<String, dynamic> config,
    required String externalDeviceId,
    DateTime? since,
  }) async {
    final baseUrl = (config['base_url'] as String? ?? '').trim();
    if (baseUrl.isEmpty) {
      throw StateError('GPS provider base_url is not configured');
    }
    final path = config['positions_path'] as String? ?? '/positions';
    final url = '$baseUrl$path';
    final authStyle = config['auth_style'] as String? ?? 'bearer';
    final credentialKey = config['credential_key'] as String? ?? 'api_key';
    final token = credentials[credentialKey]?.toString() ?? '';
    final deviceParam = config['device_param'] as String? ?? 'device_id';
    final sinceParam = config['since_param'] as String?;

    final query = <String, dynamic>{deviceParam: externalDeviceId};
    if (since != null && sinceParam != null && sinceParam.isNotEmpty) {
      query[sinceParam] = since.toUtc().toIso8601String();
    }
    final headers = <String, String>{'Accept': 'application/json'};
    switch (authStyle) {
      case 'bearer':
        headers['Authorization'] = 'Bearer $token';
      case 'header':
        final name = config['auth_header'] as String? ?? 'Authorization';
        headers[name] = token;
      case 'query':
        final name = config['auth_query_param'] as String? ?? 'key';
        query[name] = token;
      case 'basic':
        final username = credentials['username']?.toString() ?? '';
        final password = credentials['password']?.toString() ?? token;
        headers['Authorization'] = 'Basic ${basicAuth(username, password)}';
    }

    final response = await _dio.get<dynamic>(
      url,
      queryParameters: query,
      options: Options(
        headers: headers,
        responseType: ResponseType.json,
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final items = _extractItems(
      response.data,
      config['items_pointer'] as String? ?? '/data',
    );
    final fieldMap = Map<String, dynamic>.from(
      config['field_map'] as Map? ?? const {},
    );
    final timeFormat = config['time_format'] as String? ?? 'iso8601';

    final positions = <NormalizedPosition>[];
    for (final item in items) {
      if (item is! Map) continue;
      final row = Map<String, dynamic>.from(item);
      final lat = _dbl(row[fieldMap['latitude'] ?? 'latitude']);
      final lng = _dbl(row[fieldMap['longitude'] ?? 'longitude']);
      final ts = _time(row[fieldMap['recorded_at'] ?? 'timestamp'], timeFormat);
      if (lat == null || lng == null || ts == null) continue;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
      positions.add(
        NormalizedPosition(
          latitude: lat,
          longitude: lng,
          recordedAt: ts,
          speedKmh: _dbl(row[fieldMap['speed_kmh'] ?? 'speed']),
          heading: _dbl(row[fieldMap['heading'] ?? 'heading']),
          accuracyMeters: _dbl(row[fieldMap['accuracy_meters'] ?? 'accuracy']),
        ),
      );
    }
    positions.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return positions;
  }

  static String basicAuth(String username, String password) {
    final bytes = '$username:$password'.codeUnits;
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      buffer
        ..write(chars[b0 >> 2])
        ..write(chars[((b0 & 3) << 4) | (b1 >> 4)])
        ..write(
          i + 1 < bytes.length ? chars[((b1 & 15) << 2) | (b2 >> 6)] : '=',
        )
        ..write(i + 2 < bytes.length ? chars[b2 & 63] : '=');
    }
    return buffer.toString();
  }

  List<dynamic> _extractItems(dynamic data, String pointer) {
    if (pointer.isEmpty) {
      return data is List ? data : const [];
    }
    dynamic current = data;
    for (final segment in pointer.split('/').where((s) => s.isNotEmpty)) {
      if (current is Map) {
        current = current[segment];
      } else if (current is List) {
        final index = int.tryParse(segment);
        current = index == null ? null : current[index];
      } else {
        return const [];
      }
    }
    return current is List ? current : const [];
  }

  double? _dbl(Object? v) => v == null ? null : double.tryParse(v.toString());

  DateTime? _time(Object? v, String format) {
    if (v == null) return null;
    switch (format) {
      case 'epoch_seconds':
        final n = num.tryParse(v.toString());
        return n == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (n * 1000).round(),
                isUtc: true,
              );
      case 'epoch_millis':
        final n = num.tryParse(v.toString());
        return n == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(n.round(), isUtc: true);
      default:
        return DateTime.tryParse(v.toString());
    }
  }
}
