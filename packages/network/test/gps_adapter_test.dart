import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canned-response HTTP adapter so the GPS adapter is tested without network.
class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this.body);

  final Object body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('GenericHttpJsonAdapter', () {
    test('maps vendor fields, bearer auth and ISO timestamps', () async {
      final http = _FakeHttpAdapter({
        'data': [
          {
            'device_id': 'DEV-001',
            'lat': '9.9312',
            'lng': '76.2673',
            'ts': '2026-11-23T08:00:00Z',
            'spd': 45,
            'dir': 180,
          },
        ],
      });
      final dio = Dio()..httpClientAdapter = http;
      final adapter = GenericHttpJsonAdapter(dio: dio);

      final positions = await adapter.fetchPositions(
        credentials: {'api_key': 'secret-123'},
        config: {
          'base_url': 'https://gps.vendor.com',
          'positions_path': '/v1/positions',
          'auth_style': 'bearer',
          'device_param': 'imei',
          'items_pointer': '/data',
          'field_map': {
            'latitude': 'lat',
            'longitude': 'lng',
            'recorded_at': 'ts',
            'speed_kmh': 'spd',
            'heading': 'dir',
          },
        },
        externalDeviceId: 'DEV-001',
      );

      expect(positions, hasLength(1));
      expect(positions.first.latitude, 9.9312);
      expect(positions.first.longitude, 76.2673);
      expect(positions.first.speedKmh, 45);
      expect(positions.first.recordedAt.isUtc, isTrue);
      expect(http.lastRequest!.headers['Authorization'], 'Bearer secret-123');
      expect(http.lastRequest!.queryParameters['imei'], 'DEV-001');
      expect(http.lastRequest!.uri.path, '/v1/positions');
    });

    test('supports epoch seconds, query auth and root arrays', () async {
      final http = _FakeHttpAdapter([
        {'latitude': 10.0, 'longitude': 76.0, 'timestamp': 1763884800},
      ]);
      final dio = Dio()..httpClientAdapter = http;
      final adapter = GenericHttpJsonAdapter(dio: dio);

      final positions = await adapter.fetchPositions(
        credentials: {'api_key': 'k'},
        config: {
          'base_url': 'https://gps.example.com',
          'auth_style': 'query',
          'auth_query_param': 'token',
          'items_pointer': '',
          'time_format': 'epoch_seconds',
        },
        externalDeviceId: 'D2',
      );

      expect(positions, hasLength(1));
      expect(http.lastRequest!.queryParameters['token'], 'k');
      expect(positions.first.recordedAt.millisecondsSinceEpoch, 1763884800000);
    });

    test('filters invalid coordinates and missing timestamps', () async {
      final http = _FakeHttpAdapter({
        'data': [
          {
            'latitude': 91.0,
            'longitude': 76.0,
            'timestamp': '2026-11-23T08:00:00Z',
          },
          {
            'latitude': 10.0,
            'longitude': 181.0,
            'timestamp': '2026-11-23T08:00:00Z',
          },
          {'latitude': 10.0, 'longitude': 76.0},
          {
            'latitude': 10.5,
            'longitude': 76.5,
            'timestamp': '2026-11-23T08:05:00Z',
          },
        ],
      });
      final dio = Dio()..httpClientAdapter = http;
      final adapter = GenericHttpJsonAdapter(dio: dio);

      final positions = await adapter.fetchPositions(
        credentials: {'api_key': 'k'},
        config: {'base_url': 'https://gps.example.com'},
        externalDeviceId: 'D3',
      );

      expect(positions, hasLength(1));
      expect(positions.first.latitude, 10.5);
    });

    test('sorts positions chronologically', () async {
      final http = _FakeHttpAdapter({
        'data': [
          {
            'latitude': 10.1,
            'longitude': 76.1,
            'timestamp': '2026-11-23T08:05:00Z',
          },
          {
            'latitude': 10.0,
            'longitude': 76.0,
            'timestamp': '2026-11-23T08:00:00Z',
          },
        ],
      });
      final dio = Dio()..httpClientAdapter = http;
      final adapter = GenericHttpJsonAdapter(dio: dio);

      final positions = await adapter.fetchPositions(
        credentials: {'api_key': 'k'},
        config: {'base_url': 'https://gps.example.com'},
        externalDeviceId: 'D4',
      );

      expect(positions.first.latitude, 10.0);
      expect(positions.last.latitude, 10.1);
    });

    test('requires base_url', () async {
      final adapter = GenericHttpJsonAdapter(dio: Dio());
      expect(
        () => adapter.fetchPositions(
          credentials: {'api_key': 'k'},
          config: {},
          externalDeviceId: 'D5',
        ),
        throwsStateError,
      );
    });

    test('basic auth header is correctly encoded', () {
      expect(GenericHttpJsonAdapter.basicAuth('user', 'pass'), 'dXNlcjpwYXNz');
    });

    test('normalized position JSON matches ingest RPC contract', () {
      final position = NormalizedPosition(
        latitude: 9.9,
        longitude: 76.2,
        recordedAt: DateTime.utc(2026, 11, 23, 8),
        speedKmh: 40,
      );
      final json = position.toJson();
      expect(json['latitude'], 9.9);
      expect(json['recorded_at'], '2026-11-23T08:00:00.000Z');
      expect(json['speed_kmh'], 40);
      expect(json.containsKey('heading'), isFalse);
    });
  });
}
