import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('live-schema model parsing', () {
    test('FleetTrip parses snake_case rows and joins', () {
      final trip = FleetTrip.fromJson({
        'id': 't1',
        'company_id': 'c1',
        'origin': 'Kochi',
        'destination': 'Chennai',
        'status': 'IN_TRANSIT',
        'tonnes': '10.5',
        'freight_rate': '25000',
        'bata_advance': '500',
        'scheduled_date': '2026-11-24',
        'fleet_vehicles': {'registration_number': 'KL01AB1234'},
        'driver_accounts': {'display_name': 'Ravi'},
        'companies': {'name': 'Test Co'},
      });
      expect(trip.isInTransit, isTrue);
      expect(trip.isActive, isTrue);
      expect(trip.tonnes, 10.5);
      expect(trip.vehicleNumber, 'KL01AB1234');
      expect(trip.driverName, 'Ravi');
      expect(trip.companyName, 'Test Co');
      expect(trip.scheduledDate, DateTime(2026, 11, 24));
    });

    test('JobPosting parses licence class arrays', () {
      final job = JobPosting.fromJson({
        'id': 'j1',
        'company_id': 'c1',
        'title': 'HMV driver',
        'required_licence_classes': ['HMV', 'HMV_PLUS'],
        'status': 'OPEN',
        'rate_amount': '25000',
        'rate_unit': 'PER_TRIP',
      });
      expect(job.isOpen, isTrue);
      expect(job.requiredLicenceClasses, ['HMV', 'HMV_PLUS']);
      expect(job.rateAmount, 25000);
    });

    test('GpsDevice staleness and binding', () {
      final fresh = GpsDevice.fromJson({
        'id': 'd1',
        'company_id': 'c1',
        'provider_id': 'generic_http_json',
        'external_device_id': 'DEV-1',
        'status': 'ACTIVE',
        'vehicle_id': 'v1',
        'last_seen_at': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toUtc()
            .toIso8601String(),
      });
      final stale = GpsDevice.fromJson({
        'id': 'd2',
        'company_id': 'c1',
        'provider_id': 'generic_http_json',
        'external_device_id': 'DEV-2',
        'status': 'ACTIVE',
        'last_seen_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toUtc()
            .toIso8601String(),
      });
      expect(fresh.isStale, isFalse);
      expect(fresh.isBound, isTrue);
      expect(stale.isStale, isTrue);
      expect(stale.isBound, isFalse);
    });

    test('CompanySubscription validity and trial state', () {
      final active = CompanySubscription.fromJson({
        'id': 's1',
        'company_id': 'c1',
        'plan_id': 'TRANSPORTER_MONTHLY',
        'status': 'ACTIVE',
        'started_at': '2026-11-01T00:00:00Z',
        'valid_until': DateTime.now()
            .add(const Duration(days: 10))
            .toUtc()
            .toIso8601String(),
      });
      final expired = CompanySubscription.fromJson({
        'id': 's2',
        'company_id': 'c1',
        'plan_id': 'TRANSPORTER_MONTHLY',
        'status': 'ACTIVE',
        'started_at': '2026-10-01T00:00:00Z',
        'valid_until': DateTime.now()
            .subtract(const Duration(days: 1))
            .toUtc()
            .toIso8601String(),
      });
      expect(active.isValid, isTrue);
      expect(active.isTrial, isFalse);
      expect(expired.isValid, isFalse);
    });

    test('LedgerEntry credit/debit classification', () {
      LedgerEntry entry(String type) => LedgerEntry.fromJson({
        'id': 'l1',
        'company_id': 'c1',
        'driver_account_id': 'd1',
        'entry_type': type,
        'amount': '100',
        'approval_status': 'APPROVED',
      });
      expect(entry('PAYMENT').isCredit, isTrue);
      expect(entry('BATA_EARNED').isCredit, isTrue);
      expect(entry('ADVANCE').isCredit, isFalse);
      expect(entry('APPROVED_DEDUCTION').isCredit, isFalse);
    });

    test('Company GST verification fields parse', () {
      final company = Company.fromJson({
        'id': 'c1',
        'name': 'Test Co',
        'legal_name': 'Test Company Pvt Ltd',
        'status': 'ACTIVE',
        'gstin': '29ABCDE1234F1Z5',
        'gst_certificate_path': 'c1/company_documents/gst.jpg',
        'gst_verification_status': 'FAILED',
        'gst_rejection_reason': 'Blurry document',
      });
      expect(company.gstVerificationStatus, 'FAILED');
      expect(company.gstRejectionReason, 'Blurry document');
      expect(company.gstSubmitted, isTrue);
    });

    test('BreadcrumbPoint carries GPS source identification', () {
      final point = BreadcrumbPoint.fromJson({
        'id': 'b1',
        'trip_id': 't1',
        'latitude': '9.9',
        'longitude': '76.2',
        'recorded_at': '2026-11-23T08:00:00Z',
        'source': 'GPS_DEVICE',
        'device_id': 'd1',
      });
      expect(point.source, 'GPS_DEVICE');
      expect(point.deviceId, 'd1');
      expect(point.latitude, 9.9);
    });
  });
}
