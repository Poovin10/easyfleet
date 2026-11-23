# Flutter Database Reference Audit

Phase 1B audit artifact for `easyfleet-flutter` at baseline commit `1d29a44`.

## Scope and method

- Static inspection of every checked-in `*.dart` file under `apps/` and `packages/` (103 formatting units; generated build artifacts excluded from source findings).
- Live remote Supabase catalog inspected read-only as `supabase_read_only_user`; see `BACKEND-SCHEMA-INVENTORY.md`.
- No database records, schema objects, RLS policies, RPCs, or project settings were changed during the audit.
- Baseline verification before any corrections:
  - `flutter analyze`: **No issues found**
  - `dart format --output=none --set-exit-if-changed .`: **0 changed**
  - `apps/driver` tests: **1 passed**
  - `apps/transporter` tests: **1 passed**

## Executive summary

The Flutter data layer was written against a legacy “job marketplace” schema. The live Supabase backend is a company-centric fleet operations schema. Eleven table constants in `supabase_tables.dart` do not exist; several additional REST/RPC constants in `api_endpoints.dart` are also stale.

The only database-facing paths already aligned with the live backend are:

- Supabase Auth initialization in both apps.
- Driver signup/sign-in bootstrap through `public.easyfleet_create_driver_account(text)`.
- The default private Storage bucket name `easyfleet-private-documents`.
- The table name `trip_location_breadcrumbs` (but not its column contract).
- Realtime publication of `fleet_trips`, `driver_memberships`, and `trip_location_breadcrumbs`.

## Detailed mismatch register

For every mismatch: Flutter file and line, expected table/column, actual backend table/column, required correction, and impact.

| # | Flutter file and line | Expected | Actual backend | Required correction | Potential impact |
|---:|---|---|---|---|---|
| 1 | `packages/network/lib/src/supabase_tables.dart:3` | Table `driver_profiles` | No such table. Driver identity is `driver_accounts`; licence data is `driver_licences`. | Remove constant; use `driverAccounts` and `driverLicences`. | Any query using the constant returns PostgREST 404 `Could not find the table`. |
| 2 | `packages/network/lib/src/supabase_tables.dart:4` | Table `transporter_companies` | No such table. Company data is `companies`; ownership is `company_memberships`. | Remove constant; use `companies` and `company_memberships`. | GST onboarding queries return 404. |
| 3 | `packages/network/lib/src/supabase_tables.dart:5` | Table `job_postings` | No marketplace tables exist. | Remove constant; mark marketplace feature unsupported until a product/backend decision is made. | Job search/post fails with 404. |
| 4 | `packages/network/lib/src/supabase_tables.dart:6` | Table `job_applications` | No marketplace tables exist. | Remove constant; mark marketplace feature unsupported. | Apply/list/appoint flows fail with 404. |
| 5 | `packages/network/lib/src/supabase_tables.dart:7` | Table `assignments` | No such table. Nearest domain equivalents are `company_drivers`, `driver_memberships`, and `fleet_trips`. | Remove constant; do not create a parallel table without justification. | Assignment insert/stream fails with 404. |
| 6 | `packages/network/lib/src/supabase_tables.dart:8` | Table `gps_devices` | No such table. Vehicles are `fleet_vehicles`; it has no `imei`, `sim_number`, or `transporter_id`. | Remove constant; map vehicle reads to `fleet_vehicles`; mark device binding unsupported. | Device list/bind fails with 404. |
| 7 | `packages/network/lib/src/supabase_tables.dart:9` | Table `gps_positions` | No such table. Live breadcrumb table is `trip_location_breadcrumbs`. | Remove constant; use `trip_location_breadcrumbs` keyed by `trip_id`. | Device-position stream fails with 404. |
| 8 | `packages/network/lib/src/supabase_tables.dart:10` | Table `trips` | No such table. Live table is `fleet_trips`. | Remove constant; use `fleetTrips`. | Stage update fails with 404. |
| 9 | `packages/network/lib/src/supabase_tables.dart:11` | Table `trip_events` | No such table. Audit history is `fleet_audit_events`; closures are `trip_closures`. | Remove constant; use audit/closure tables where appropriate. | Event insert/stream fails with 404. |
| 10 | `packages/network/lib/src/supabase_tables.dart:12`, `packages/network/lib/src/gps_device_service.dart:56-58` | `trip_location_breadcrumbs.transporter_id` | Column absent. Live columns include `trip_id`, `latitude`, `longitude`, `accuracy_meters`, `recorded_at`. | Filter by `trip_id`; derive company scope through `fleet_trips.company_id`. | `.eq('transporter_id', ...)` fails with PostgREST 400/42703. |
| 11 | `packages/network/lib/src/supabase_tables.dart:13`, `packages/auth/lib/src/permissions_service.dart:14` | Table `user_permissions` with `user_id`, `permission` | No such table. Permissions are represented by `company_memberships.role/status` and helper functions such as `is_company_member`, `is_company_manager`, `is_company_operator`. | Derive permissions from active company memberships. | Permission provider returns 404; currently no UI consumes it, but future gates would be wrong. |
| 12 | `packages/network/lib/src/onboarding_service.dart:30-33` | Storage object path `$userId/$kind-<ts>.<ext>` and public URL | Private bucket policies require driver paths `.../<driver_account_id>/<licence\|identity\|profile>/...` and company paths `<company_id>/company_documents/...`. Bucket is private, so `getPublicUrl` is not a usable document reference. | Resolve driver-account/company IDs; build scoped paths; return the storage path, not a public URL. | Uploads rejected by Storage RLS; returned URL unusable. |
| 13 | `packages/network/lib/src/onboarding_service.dart:42-48` | Upsert `driver_profiles` with `dl_number`, `license_class`, `dl_document_url`, `dl_verification='pending'` | `driver_licences` has `driver_account_id`, `dl_fingerprint`, `licence_class`, `verification_status`, `issuing_state`, `valid_from`, `valid_until`. `verification_source` is required. Authenticated role has SELECT only on this table. | Call a narrowly scoped `SECURITY DEFINER` RPC that inserts/updates `driver_licences` for `auth.uid()`. | 404 plus RLS denial; DL never persisted. |
| 14 | `packages/network/lib/src/onboarding_service.dart:57-63` | Upsert `transporter_companies` with `gst`, `legal_name`, `gst_document_url`, `gst_verification='pending'` | `companies` has `gstin`, `legal_name`, `gst_certificate_path`; no GST verification column. Authenticated role has SELECT only. | Call a scoped RPC that updates an existing company where caller is OWNER/ADMIN; store path in `gst_certificate_path`. | 404 plus RLS denial; GST never persisted. |
| 15 | `packages/network/lib/src/onboarding_service.dart:70-78` | Read `dl_verification` or `gst_verification`, lowercase names | Read `driver_licences.verification_status` (`PENDING`/`VERIFIED`/`FAILED`/`EXPIRED`/`REVIEW_REQUIRED`); GST status must be inferred from `gst_certificate_path`. | Map backend status strings to `VerificationStatus`. | 404 or `ValueNotInRange` in `onboarding_controller.dart:63`. |
| 16 | `packages/auth/lib/src/onboarding_controller.dart:75-86`, `98-109` | Pass Supabase Auth user ID as document owner/table ID | Storage/DL paths require `driver_accounts.id`; GST requires `company_memberships.company_id`. | Resolve IDs in service from `auth.uid()` before upload/write. | Upload violates RLS or writes wrong identifier. |
| 17 | `packages/network/lib/src/marketplace_service.dart:24,40` | Query `job_postings`; filter `required_license_classes`, `vehicle_category`, `pickup_location`, `created_at` | No equivalent table. | Replace with explicit unsupported error; do not fabricate tables. | Search fails 404. |
| 18 | `packages/network/lib/src/marketplace_service.dart:44-62` | Insert `job_postings` | No equivalent table. | Unsupported. | Post job fails 404. |
| 19 | `packages/network/lib/src/marketplace_service.dart:66-76,81,90,123` | `job_applications` with `job_id`, `driver_id`, `applied_at`, `cover_note`, `experience_snapshot`, `assignment_id` | No equivalent table. | Unsupported. | Apply/list/appoint flows fail 404. |
| 20 | `packages/network/lib/src/marketplace_service.dart:106-128` | Insert `assignments`, two-step appointment | No equivalent table; backend appointment concepts are `company_drivers` and `driver_memberships`, written through company flows/RPCs. | Unsupported; avoid non-atomic client writes. | Appointment fails 404; existing data could be partially written if a replacement is added naively. |
| 21 | `packages/network/lib/src/marketplace_service.dart:134-145` | Realtime stream on `assignments` | Not published; table absent. | Unsupported. | Stream errors. |
| 22 | `packages/network/lib/src/gps_device_service.dart:19-27` | Query `gps_devices.transporter_id`, `imei` | `fleet_vehicles.company_id`, `registration_number`, `status`, `vehicle_type`. | Map reads to `fleet_vehicles`; synthesize `GpsDevice` view model fields. | Query fails 404; current RLS denies direct writes. |
| 23 | `packages/network/lib/src/gps_device_service.dart:35-41` | Upsert `gps_devices` on `imei` | No GPS registry; `fleet_vehicles` has no `imei` or `sim_number` and no INSERT policy for authenticated. | Mark binding unsupported; use `easyfleet_create_vehicle` for vehicle creation. | Binding fails 404/RLS. |
| 24 | `packages/network/lib/src/gps_device_service.dart:48-52` | Stream `gps_positions` | No such table. | Use `trip_location_breadcrumbs` by `trip_id`. | Stream fails 404. |
| 25 | `packages/network/lib/src/trip_lifecycle_service.dart:44-53` | Insert `trip_events` with `stage`, `occurred_at`, `actor_id` | No such table. Audit events are `fleet_audit_events` (`event_type`, `event_time`, `actor_user_id`). Writes are through `easyfleet_write_audit_event`. | Move transitions to backend RPCs; do not direct-insert audit rows. | Event insert fails 404/RLS. |
| 26 | `packages/network/lib/src/trip_lifecycle_service.dart:55-58` | Update `trips.stage` | `fleet_trips.status` with allowed values `PLANNED`, `ASSIGNED`, `IN_TRANSIT`, `CLOSURE_PENDING`, `COMPLETED`, `CANCELLED`; lifecycle writes are via `easyfleet_start_trip`, `easyfleet_submit_trip_closure`, `easyfleet_review_trip_closure`. | Map stages to statuses and call RPCs; direct UPDATE is denied by RLS. | Update fails 404/RLS. |
| 27 | `packages/network/lib/src/trip_lifecycle_service.dart:61-66` | Stream `trip_events` ordered by `occurred_at` | `fleet_audit_events` exists but is not in `supabase_realtime`; use one-shot select or add to publication later. | Replace with select-backed stream; document no live updates. | Stream errors or silently stale. |
| 28 | `packages/auth/lib/src/permissions_service.dart:13-21` | `user_permissions.permission` lowercase strings | `company_memberships.role` values `OWNER`, `ADMIN`, `COMPLIANCE`, `DISPATCHER`, `VIEWER`; `status` values `PENDING`, `ACTIVE`, `SUSPENDED`, `REVOKED`. | Derive permission strings from active memberships. | Provider fails 404; future authorization checks would be wrong. |
| 29 | `packages/network/lib/src/api_endpoints.dart:7,33` | REST/RPC `create_driver_account` | Actual function is `easyfleet_create_driver_account(text)`. | Update constants; keep the existing working RPC call in `auth_controller.dart:57-60` unchanged. | Unused constants are misleading; accidental use would 404. |
| 30 | `packages/network/lib/src/api_endpoints.dart:8,34` | `get_my_driver_account` | No such RPC. | Remove constant; fetch `driver_accounts` by `auth_user_id` under RLS. | Accidental use would 404. |
| 31 | `packages/network/lib/src/api_endpoints.dart:11-16` | `trips`, `driver_trips`, `driver_job_vacancies`, `driver_job_applications` | Actual tables: `fleet_trips`, `companies`, `company_memberships`; no marketplace. | Update/remove constants. | Latent 404s. |
| 32 | `packages/network/lib/src/api_endpoints.dart:19-25` | `driver_fuel_entries`, `driver_adblue_entries`, `driver_expenses`, `driver_pod_entries`, `driver_breakdown_reports`, `driver_bank_details`, `driver_earnings_ledger` | Actual: `trip_fuel_entries`, `trip_expenses`, `trip_closures`, `fleet_maintenance_jobs`, `driver_ledger_entries`; no AdBlue or bank-details tables. | Map to real tables; remove unsupported ones. | Latent 404s. |
| 33 | `packages/network/lib/src/api_endpoints.dart:28` | Generic `/storage/v1/object` | Bucket policy requires scoped object paths; no generic object endpoint is used by client code. | Remove or document as unused. | No runtime impact. |
| 34 | `packages/network/lib/src/api_endpoints.dart:35-37` | `capture_driver_location`, `get_driver_current_trip`, `get_driver_history` | No such RPCs. Breadcrumb INSERT policy and `fleet_trips` SELECT cover these needs. | Remove constants; use table access. | Latent 404s. |
| 35 | `packages/sync/lib/src/sync_service.dart:46-50` | RPC `delete_row` | No such RPC; backend intentionally has no generic delete function. | Fail fast with unsupported error instead of calling nonexistent RPC. | Queued deletes fail; currently no callers. |
| 36 | `packages/network/lib/src/marketplace_service.dart:40,85,94,128`, `packages/network/lib/src/gps_device_service.dart:25` | `fromJson` on snake_case PostgREST rows | Generated Freezed serializers expect camelCase keys (for example `job_posting.g.dart:11-37`, `assignment.g.dart:11-20`, `gps_device.g.dart:11-20`). | Add `@JsonKey(name: ...)` mappings or explicit row normalizers. | Model fields deserialize as null even if the underlying tables existed. |
| 37 | `packages/domain/lib/src/enums.dart:27` | Comment says every transition appends to `trip_events` | No `trip_events`; lifecycle events are audit/closure records. | Update comment. | Documentation only. |

## Confirmed alignments (no correction needed)

| Area | File and line | Backend object |
|---|---|---|
| Supabase client init | `apps/driver/lib/main.dart:12-15`, `apps/transporter/lib/main.dart:12-15` | Project URL + publishable key via `--dart-define` |
| Driver signup | `packages/auth/lib/src/auth_controller.dart:63-83` | `auth.users` + `user_metadata.app_role='driver'` |
| Driver-account bootstrap | `packages/auth/lib/src/auth_controller.dart:47-61` | `public.easyfleet_create_driver_account(text)`, `SECURITY DEFINER`, granted to `authenticated` |
| Driver sign-in bootstrap | `packages/auth/lib/src/ui/login_screen.dart:59-64` | Same RPC when driver signup is enabled |
| Storage bucket | `packages/core/lib/src/config/environment_config.dart:30-33` | `storage.buckets.easyfleet-private-documents` (private, 20 MiB) |
| Realtime | `packages/network/lib/src/gps_device_service.dart:54-59` | `trip_location_breadcrumbs` is published, but column filter must change (see #10) |

## Local persistence note

`packages/sync/lib/src/outbox_repository.dart:20-43` creates local SQLite tables `outbox` and `location_breadcrumbs`. These are **not** Supabase tables and are not mismatches. The local `location_breadcrumbs.sync_state` column has no backend counterpart; it is an offline queue marker only.
