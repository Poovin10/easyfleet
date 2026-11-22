import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams connectivity state to gates and retry logic.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.any((result) => result != ConnectivityResult.none),
  );
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).value ?? true;
});

/// Thrown by the connectivity interceptor when there is no network.
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException: device is offline';
}
