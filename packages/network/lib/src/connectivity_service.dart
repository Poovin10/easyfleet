import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams connectivity state to gates and retry logic.
///
/// Emits the current state first so the UI never assumes a connection that
/// may not exist, then follows live connectivity changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).value ?? true;
});

/// A stable stream for UI gates (Riverpod 3 StreamProviders expose values,
/// not the underlying stream). Emits the current state before live changes.
final connectivityGateStreamProvider = Provider<Stream<bool>>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});

/// Thrown by the connectivity interceptor when there is no network.
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException: device is offline';
}
