import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final tripLifecycleServiceProvider = Provider<TripLifecycleService>((ref) {
  return TripLifecycleService(ref.watch(supabaseClientProvider));
});

/// Trip history reader aligned to the live schema.
///
/// The backend owns lifecycle transitions through SECURITY DEFINER RPCs and
/// stores history in `fleet_audit_events`. There are no `trips` or
/// `trip_events` tables. See `MISSING-BACKEND-CAPABILITIES.md` (M-07/M-08).
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

  /// Lifecycle writes must use the backend RPCs, not direct table updates.
  Never advance({
    required String tripId,
    required TripStage from,
    required TripStage to,
    String? actorId,
    String? note,
    double? latitude,
    double? longitude,
  }) => throw UnsupportedError(
    'Direct trip-stage writes are not available. Use '
    'easyfleet_start_trip, easyfleet_submit_trip_closure, or '
    'easyfleet_review_trip_closure instead.',
  );

  /// One-shot audit-history read.
  ///
  /// `fleet_audit_events` is not in the Realtime publication, so this stream
  /// delivers the current rows once and does not push updates.
  Stream<List<Map<String, dynamic>>> watchEvents(String tripId) =>
      Stream.fromFuture(
        _client
            .from(Tables.fleetAuditEvents)
            .select()
            .eq('entity_type', 'TRIP')
            .eq('entity_id', tripId)
            .order('event_time'),
      );
}
