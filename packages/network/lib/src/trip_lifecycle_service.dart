import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fleet_service.dart';

final tripLifecycleServiceProvider = Provider<TripLifecycleService>((ref) {
  return TripLifecycleService(ref.watch(fleetServiceProvider));
});

/// Trip lifecycle aligned to the backend state machine:
/// PLANNED -> ASSIGNED -> IN_TRANSIT -> CLOSURE_PENDING -> COMPLETED,
/// with CANCELLED from PLANNED/ASSIGNED. Transitions are RPC-owned and
/// idempotent; history is read from `fleet_audit_events` (published).
class TripLifecycleService {
  TripLifecycleService(this._fleet);

  final FleetService _fleet;

  static const allowedTransitions = <String, Set<String>>{
    'PLANNED': {'ASSIGNED', 'CANCELLED'},
    'ASSIGNED': {'IN_TRANSIT', 'CANCELLED'},
    'IN_TRANSIT': {'CLOSURE_PENDING'},
    'CLOSURE_PENDING': {'COMPLETED', 'IN_TRANSIT'},
  };

  bool canAdvance(String current, String next) =>
      allowedTransitions[current]?.contains(next) ?? false;

  Future<void> start({
    required String companyId,
    required String tripId,
    int? startingOdometerKm,
    String? idempotencyKey,
  }) => _fleet.startTrip(
    companyId: companyId,
    tripId: tripId,
    startingOdometerKm: startingOdometerKm,
    idempotencyKey: idempotencyKey,
  );

  Future<String> submitClosure({
    required String companyId,
    required String tripId,
    int? closingOdometerKm,
    double? actualDistanceKm,
    double bataEarned = 0,
    double bataAdvance = 0,
    bool deliveryConfirmed = false,
    String? podObjectPath,
    String? closureNotes,
    String? idempotencyKey,
  }) => _fleet.submitClosure(
    companyId: companyId,
    tripId: tripId,
    closingOdometerKm: closingOdometerKm,
    actualDistanceKm: actualDistanceKm,
    bataEarned: bataEarned,
    bataAdvance: bataAdvance,
    deliveryConfirmed: deliveryConfirmed,
    podObjectPath: podObjectPath,
    closureNotes: closureNotes,
    idempotencyKey: idempotencyKey,
  );

  Future<void> reviewClosure({
    required String companyId,
    required String closureId,
    required bool approve,
    String? note,
  }) => _fleet.reviewClosure(
    companyId: companyId,
    closureId: closureId,
    decision: approve ? 'APPROVED' : 'REJECTED',
    reviewerNote: note,
  );

  Future<void> cancel({
    required String companyId,
    required String tripId,
    required String reason,
  }) => _fleet.cancelTrip(companyId: companyId, tripId: tripId, reason: reason);

  Future<List<AuditEvent>> history(String tripId) => _fleet.tripHistory(tripId);

  Stream<List<AuditEvent>> watchHistory(String tripId) =>
      _fleet.watchTripHistory(tripId);
}
