import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final tripLifecycleServiceProvider = Provider<TripLifecycleService>((ref) {
  return TripLifecycleService(ref.watch(supabaseClientProvider));
});

/// Immutable trip-stage log; both apps read the same stream.
class TripLifecycleService {
  TripLifecycleService(this._client);

  final SupabaseClient _client;

  static const allowedTransitions = <TripStage, Set<TripStage>>{
    TripStage.assigned: {TripStage.reporting, TripStage.cancelled},
    TripStage.reporting: {TripStage.loading, TripStage.cancelled},
    TripStage.loading: {TripStage.transit, TripStage.cancelled},
    TripStage.transit: {TripStage.unloading, TripStage.cancelled},
    TripStage.unloading: {TripStage.podPending, TripStage.cancelled},
    TripStage.podPending: {TripStage.completed, TripStage.cancelled},
  };

  bool canAdvance(TripStage current, TripStage next) {
    return allowedTransitions[current]?.contains(next) ?? false;
  }

  Future<void> advance({
    required String tripId,
    required TripStage from,
    required TripStage to,
    String? actorId,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    if (!canAdvance(from, to)) {
      throw StateError('Invalid trip transition: ${from.name} -> ${to.name}');
    }

    await _client.from(Tables.tripEvents).insert({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'trip_id': tripId,
      'stage': to.name,
      'occurred_at': DateTime.now().toIso8601String(),
      'actor_id': actorId,
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
    });

    await _client
        .from(Tables.trips)
        .update({'stage': to.name})
        .eq('id', tripId);
  }

  Stream<List<Map<String, dynamic>>> watchEvents(String tripId) {
    return _client
        .from(Tables.tripEvents)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('occurred_at');
  }
}
