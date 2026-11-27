import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'company_service.dart';
import 'supabase_data_source.dart';
import 'supabase_tables.dart';

final fleetServiceProvider = Provider<FleetService>((ref) {
  return FleetService(ref.watch(supabaseClientProvider));
});

/// Fleet operations: vehicles, drivers, trips, fuel, expenses, maintenance,
/// closures and ledger. All writes go through idempotent SECURITY DEFINER RPCs.
class FleetService {
  FleetService(this._client);

  final SupabaseClient _client;

  // -- Vehicles -------------------------------------------------------------

  Future<List<FleetVehicle>> vehicles(String companyId) async {
    final rows = await _client
        .from(Tables.fleetVehicles)
        .select()
        .eq('company_id', companyId)
        .order('registration_number');
    return rows.map(FleetVehicle.fromJson).toList();
  }

  Future<String> createVehicle({
    required String companyId,
    required String registrationNumber,
    String vehicleType = 'TRUCK',
    String? make,
    String? model,
    int? manufacturingYear,
    double? capacityTonnes,
    int? odometerKm,
    String? notes,
  }) async {
    final vehicleId = newId();
    await _client.rpc<dynamic>(
      RpcNames.createVehicle,
      params: {
        'p_company_id': companyId,
        'p_vehicle_id': vehicleId,
        'p_registration_number': registrationNumber.trim(),
        'p_vehicle_type': vehicleType,
        'p_make': make,
        'p_model': model,
        'p_manufacturing_year': manufacturingYear,
        'p_capacity_tonnes': capacityTonnes,
        'p_odometer_km': odometerKm,
        'p_notes': notes,
      },
    );
    return vehicleId;
  }

  Future<List<Map<String, dynamic>>> vehicleDocuments(
    String companyId,
    String vehicleId,
  ) async {
    final rows = await _client
        .from(Tables.vehicleDocuments)
        .select()
        .eq('company_id', companyId)
        .eq('vehicle_id', vehicleId)
        .order('created_at', ascending: false);
    return rows.map(Map<String, dynamic>.from).toList();
  }

  /// Registers a compliance document after its bytes have been uploaded to
  /// the private bucket. The backend validates the company/vehicle/path shape.
  Future<String> addVehicleDocument({
    required String companyId,
    required String vehicleId,
    required String documentType,
    required String storageObjectPath,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    final documentId = await _client.rpc<String>(
      RpcNames.addVehicleDocument,
      params: {
        'p_company_id': companyId,
        'p_vehicle_id': vehicleId,
        'p_document_type': documentType,
        'p_storage_object_path': storageObjectPath,
        'p_document_number': documentNumber,
        'p_issue_date': issueDate?.toIso8601String().split('T').first,
        'p_expiry_date': expiryDate?.toIso8601String().split('T').first,
      },
    );
    return documentId;
  }

  // -- Company drivers --------------------------------------------------------

  Future<List<CompanyDriver>> companyDrivers(String companyId) async {
    final rows = await _client
        .from(Tables.companyDrivers)
        .select('*, driver_accounts(display_name)')
        .eq('company_id', companyId)
        .order('created_at');
    final drivers = rows.map(CompanyDriver.fromJson).toList();
    // Attach membership status (readable by company history reviewers).
    final memberships = await _client
        .from(Tables.driverMemberships)
        .select('driver_account_id, status')
        .eq('company_id', companyId);
    final statusByDriver = {
      for (final m in memberships)
        m['driver_account_id'] as String: m['status'] as String,
    };
    return drivers
        .map(
          (d) => CompanyDriver(
            id: d.id,
            companyId: d.companyId,
            driverAccountId: d.driverAccountId,
            localDriverCode: d.localDriverCode,
            employmentRole: d.employmentRole,
            displayName: d.displayName,
            membershipStatus: statusByDriver[d.driverAccountId],
          ),
        )
        .toList();
  }

  Future<String> addCompanyDriver({
    required String companyId,
    required String driverAccountId,
    String? localDriverCode,
  }) async {
    final result = await _client.rpc<dynamic>(
      RpcNames.addCompanyDriver,
      params: {
        'p_company_id': companyId,
        'p_driver_account_id': driverAccountId,
        'p_local_driver_code': localDriverCode,
      },
    );
    return result.toString();
  }

  /// Registers a driver who does not use the Driver app. The backend creates
  /// the account (with no auth user) and an approved company membership.
  Future<String> addManualDriver({
    required String companyId,
    required String displayName,
    String? phoneE164,
    String? localDriverCode,
  }) async {
    final result = await _client.rpc<dynamic>(
      RpcNames.addManualCompanyDriver,
      params: {
        'p_company_id': companyId,
        'p_display_name': displayName.trim(),
        'p_phone_e164': phoneE164?.trim(),
        'p_local_driver_code': localDriverCode?.trim(),
      },
    );
    return result.toString();
  }

  // -- Trips ------------------------------------------------------------------

  static const _tripSelect =
      '*, fleet_vehicles(registration_number), driver_accounts(display_name), companies(name)';

  Future<List<FleetTrip>> companyTrips(
    String companyId, {
    List<String>? statuses,
  }) async {
    var query = _client
        .from(Tables.fleetTrips)
        .select(_tripSelect)
        .eq('company_id', companyId);
    if (statuses != null && statuses.isNotEmpty) {
      query = query.inFilter('status', statuses);
    }
    final rows = await query.order('created_at', ascending: false);
    return rows.map(FleetTrip.fromJson).toList();
  }

  Future<List<FleetTrip>> myDriverTrips() async {
    final account = await CompanyService(_client).myDriverAccount();
    if (account == null) return const [];
    final rows = await _client
        .from(Tables.fleetTrips)
        .select(_tripSelect)
        .eq('driver_account_id', account.id)
        .order('created_at', ascending: false);
    return rows.map(FleetTrip.fromJson).toList();
  }

  Future<FleetTrip?> trip(String tripId) async {
    final row = await _client
        .from(Tables.fleetTrips)
        .select(_tripSelect)
        .eq('id', tripId)
        .maybeSingle();
    return row == null ? null : FleetTrip.fromJson(row);
  }

  Future<String> createTrip({
    required String companyId,
    required String origin,
    required String destination,
    required DateTime scheduledDate,
    String? vehicleId,
    String? companyDriverId,
    String? driverAccountId,
    String? gcNumber,
    String? material,
    double? tonnes,
    double? freightRate,
    double bataAdvance = 0,
    double? plannedDistanceKm,
    String? idempotencyKey,
  }) async {
    final tripId = newId();
    await _client.rpc<dynamic>(
      RpcNames.createTrip,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_origin': origin.trim(),
        'p_destination': destination.trim(),
        'p_scheduled_date': scheduledDate.toIso8601String().split('T').first,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_vehicle_id': vehicleId,
        'p_company_driver_id': companyDriverId,
        'p_driver_account_id': driverAccountId,
        'p_gc_number': gcNumber,
        'p_material': material,
        'p_tonnes': tonnes,
        'p_freight_rate': freightRate,
        'p_bata_advance': bataAdvance,
        'p_planned_distance_km': plannedDistanceKm,
      },
    );
    return tripId;
  }

  Future<void> startTrip({
    required String companyId,
    required String tripId,
    int? startingOdometerKm,
    String? idempotencyKey,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.startTrip,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_starting_odometer_km': startingOdometerKm,
        'p_idempotency_key': idempotencyKey ?? newId(),
      },
    );
  }

  Future<void> cancelTrip({
    required String companyId,
    required String tripId,
    required String reason,
    String? idempotencyKey,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.cancelTrip,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_reason': reason.trim(),
        'p_idempotency_key': idempotencyKey ?? newId(),
      },
    );
  }

  // -- Closures / POD -----------------------------------------------------------

  Future<List<TripClosure>> closuresForTrip(String tripId) async {
    final rows = await _client
        .from(Tables.tripClosures)
        .select()
        .eq('trip_id', tripId)
        .order('submission_number', ascending: false);
    return rows.map(TripClosure.fromJson).toList();
  }

  Future<List<TripClosure>> pendingClosures(String companyId) async {
    final rows = await _client
        .from(Tables.tripClosures)
        .select()
        .eq('company_id', companyId)
        .eq('status', 'SUBMITTED')
        .order('submitted_at');
    return rows.map(TripClosure.fromJson).toList();
  }

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
  }) async {
    final closureId = newId();
    await _client.rpc<dynamic>(
      RpcNames.submitTripClosure,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_closure_id': closureId,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_closing_odometer_km': closingOdometerKm,
        'p_actual_distance_km': actualDistanceKm,
        'p_bata_earned': bataEarned,
        'p_bata_advance': bataAdvance,
        'p_delivery_confirmed': deliveryConfirmed,
        'p_pod_object_path': podObjectPath,
        'p_closure_notes': closureNotes,
      },
    );
    return closureId;
  }

  Future<void> reviewClosure({
    required String companyId,
    required String closureId,
    required String decision,
    String? reviewerNote,
    String? idempotencyKey,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.reviewTripClosure,
      params: {
        'p_company_id': companyId,
        'p_closure_id': closureId,
        'p_decision': decision,
        'p_reviewer_note': reviewerNote,
        'p_idempotency_key': idempotencyKey ?? newId(),
      },
    );
  }

  // -- Fuel / expenses ------------------------------------------------------------

  Future<List<FuelEntry>> fuelEntries(String tripId) async {
    final rows = await _client
        .from(Tables.tripFuelEntries)
        .select()
        .eq('trip_id', tripId)
        .order('entry_time');
    return rows.map(FuelEntry.fromJson).toList();
  }

  Future<String> addFuelEntry({
    required String companyId,
    required String tripId,
    required String fuelType,
    required double litres,
    required double amount,
    double? ratePerLitre,
    String? pumpName,
    int? odometerKm,
    String? billReference,
    String? notes,
    String? idempotencyKey,
  }) async {
    final entryId = newId();
    await _client.rpc<dynamic>(
      RpcNames.addFuelEntry,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_entry_id': entryId,
        'p_fuel_type': fuelType,
        'p_litres': litres,
        'p_amount': amount,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_rate_per_litre': ratePerLitre,
        'p_pump_name': pumpName,
        'p_odometer_km': odometerKm,
        'p_bill_reference': billReference,
        'p_notes': notes,
      },
    );
    return entryId;
  }

  Future<List<ExpenseEntry>> expenseEntries(String tripId) async {
    final rows = await _client
        .from(Tables.tripExpenses)
        .select()
        .eq('trip_id', tripId)
        .order('created_at');
    return rows.map(ExpenseEntry.fromJson).toList();
  }

  Future<List<ExpenseEntry>> pendingExpenses(String companyId) async {
    final rows = await _client
        .from(Tables.tripExpenses)
        .select()
        .eq('company_id', companyId)
        .eq('approval_status', 'PENDING')
        .order('created_at');
    return rows.map(ExpenseEntry.fromJson).toList();
  }

  Future<String> addExpenseEntry({
    required String companyId,
    required String tripId,
    required String category,
    required double amount,
    String? description,
    int? odometerKm,
    String? billReference,
    String? receiptObjectPath,
    String? idempotencyKey,
  }) async {
    final entryId = newId();
    await _client.rpc<dynamic>(
      RpcNames.addExpenseEntry,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_entry_id': entryId,
        'p_category': category,
        'p_amount': amount,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_description': description,
        'p_odometer_km': odometerKm,
        'p_bill_reference': billReference,
        'p_receipt_object_path': receiptObjectPath,
      },
    );
    return entryId;
  }

  Future<void> reviewExpense({
    required String companyId,
    required String entryId,
    required String decision,
    String? note,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.reviewExpense,
      params: {
        'p_company_id': companyId,
        'p_entry_id': entryId,
        'p_decision': decision,
        'p_note': note,
        'p_idempotency_key': newId(),
      },
    );
  }

  // -- Maintenance -----------------------------------------------------------------

  Future<List<MaintenanceJob>> maintenanceJobs(String companyId) async {
    final rows = await _client
        .from(Tables.fleetMaintenanceJobs)
        .select('*, fleet_vehicles(registration_number)')
        .eq('company_id', companyId)
        .order('reported_at', ascending: false);
    return rows.map(MaintenanceJob.fromJson).toList();
  }

  Future<String> reportBreakdown({
    required String companyId,
    required String tripId,
    required String issueDescription,
    int? odometerKm,
    String? workshopLocation,
    String? idempotencyKey,
  }) async {
    final jobId = newId();
    await _client.rpc<dynamic>(
      RpcNames.reportBreakdown,
      params: {
        'p_company_id': companyId,
        'p_trip_id': tripId,
        'p_job_id': jobId,
        'p_issue_description': issueDescription.trim(),
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_odometer_km': odometerKm,
        'p_workshop_location': workshopLocation,
      },
    );
    return jobId;
  }

  Future<void> updateMaintenanceJob({
    required String companyId,
    required String jobId,
    required String status,
    String? workshopName,
    double? estimatedCost,
    double? serviceBillAmount,
    int? releaseOdometerKm,
    String? notes,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.updateMaintenanceJob,
      params: {
        'p_company_id': companyId,
        'p_job_id': jobId,
        'p_status': status,
        'p_workshop_name': workshopName,
        'p_estimated_cost': estimatedCost,
        'p_service_bill_amount': serviceBillAmount,
        'p_release_odometer_km': releaseOdometerKm,
        'p_notes': notes,
        'p_idempotency_key': newId(),
      },
    );
  }

  // -- Ledger ------------------------------------------------------------------------

  Future<List<LedgerEntry>> companyLedger(
    String companyId, {
    String? driverAccountId,
  }) async {
    var query = _client
        .from(Tables.driverLedgerEntries)
        .select('*, driver_accounts(display_name)')
        .eq('company_id', companyId);
    if (driverAccountId != null) {
      query = query.eq('driver_account_id', driverAccountId);
    }
    final rows = await query.order('created_at', ascending: false);
    return rows.map(LedgerEntry.fromJson).toList();
  }

  Future<List<LedgerEntry>> myDriverLedger() async {
    final account = await CompanyService(_client).myDriverAccount();
    if (account == null) return const [];
    final rows = await _client
        .from(Tables.driverLedgerEntries)
        .select()
        .eq('driver_account_id', account.id)
        .order('created_at', ascending: false);
    return rows.map(LedgerEntry.fromJson).toList();
  }

  Future<void> addLedgerEntry({
    required String companyId,
    required String driverAccountId,
    required String entryType,
    required double amount,
    String? tripId,
    String? description,
    String? idempotencyKey,
  }) async {
    await _client.rpc<dynamic>(
      RpcNames.addLedgerEntry,
      params: {
        'p_company_id': companyId,
        'p_entry_id': newId(),
        'p_driver_account_id': driverAccountId,
        'p_entry_type': entryType,
        'p_amount': amount,
        'p_idempotency_key': idempotencyKey ?? newId(),
        'p_trip_id': tripId,
        'p_description': description,
      },
    );
  }

  // -- History / telemetry ---------------------------------------------------------------

  Future<List<AuditEvent>> tripHistory(String tripId) async {
    final rows = await _client
        .from(Tables.fleetAuditEvents)
        .select()
        .eq('entity_id', tripId)
        .order('event_time');
    return rows.map(AuditEvent.fromJson).toList();
  }

  Stream<List<AuditEvent>> watchTripHistory(String tripId) {
    return _client
        .from(Tables.fleetAuditEvents)
        .stream(primaryKey: ['id'])
        .eq('entity_id', tripId)
        .map(
          (rows) =>
              rows.map(AuditEvent.fromJson).toList()
                ..sort((a, b) => a.eventTime.compareTo(b.eventTime)),
        );
  }

  Future<List<BreadcrumbPoint>> tripLocations(String tripId) async {
    final rows = await _client
        .from(Tables.tripUnifiedLocations)
        .select()
        .eq('trip_id', tripId)
        .order('recorded_at');
    return rows.map(BreadcrumbPoint.fromJson).toList();
  }

  Stream<List<BreadcrumbPoint>> watchTripLocations(String tripId) {
    return _client
        .from(Tables.tripLocationBreadcrumbs)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .map(
          (rows) =>
              rows.map(BreadcrumbPoint.fromJson).toList()
                ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)),
        );
  }
}
