# EasyFleet Flutter — Phase 1 Read-Only Baseline Audit

**Audit date:** 22 November 2026  
**Status:** COMPLETE — awaiting review and approval  
**Scope:** Existing EasyFleet Supabase schema, original Driver/Transporter Android apps, Flutter monorepo, GPS implementation/evidence, and transaction/security controls.  
**Primary workspace:** `/home/ubuntu/easyfleet-flutter`  
**Analysis workspace:** `/home/ubuntu/REA-APK-Analysis`  
**Report file:** `/home/ubuntu/easyfleet-flutter/PHASE1-READ-ONLY-BASELINE-AUDIT.md`

---

## 0. Execution restrictions and compliance

The following restrictions were observed:

| Restriction | Compliance |
|---|---|
| Read-only inspection | Yes |
| No source modifications | Yes — no existing source file was changed |
| No database modifications | Yes — only HTTP `GET`/`OPTIONS` probes were run |
| No migrations | Yes — no SQL migration was created |
| No APK installation or rebuilding | Yes |
| No deletion or replacement of existing files | Yes |
| Preserve all current project data | Yes |

The only file created during this audit is this report.

---

## 1. Executive verdict

The Flutter migration is currently a **foundation scaffold**, not a functionally equivalent replacement for the two native apps.

The most important conclusions are:

1. **Existing EasyFleet functionality must be preserved.** The native Driver and Transporter apps contain substantial offline-first business logic that is not present in Flutter: job market, trip lifecycle, POD, logbook, fuel/AdBlue/expenses, wallet, company/GST/fleet control, recruitment, dispatch, accounting ledgers, approvals, biometric-authorised settlement, document queues, and 15-minute WorkManager synchronization.

2. **The live Supabase schema does not match the Flutter assumptions.** Nine of ten Phase 1A tables assumed by Flutter do not exist in the live PostgREST schema cache. The table `trips` does not exist; the nearest table is `fleet_trips`, with a different column model.

3. **The Flutter data layer is not yet usable.** Most services write snake_case database columns but generated Freezed models expect camelCase JSON keys. This will break deserialization for jobs, applications, assignments, trips, events, GPS devices, profiles, and company records.

4. **Core Phase 1A UI is absent.** Every feature destination renders `PlaceholderScreen`. Critical routes such as onboarding and trip detail exist in the route catalogue but are not registered; the transporter app has no job-posting route; deep links are parsed in a unit test but not wired into navigation.

5. **The native GPS pipeline has not been ported.** Driver declares `geolocator`, `permission_handler`, notifications, and WorkManager dependencies, but no Dart code uses them. There is no foreground service, no breadcrumb writer, no WorkManager task, and no idempotency propagation.

6. **Transaction and security controls are not implementation-ready.** Appointment creation, trip-stage transitions, DL/GST uniqueness, identity verification, document access, and offline idempotency all depend on server-side controls that are either unverified or explicitly not present in the repository.

7. **WonderMove evidence is narrower than earlier wording implied.** WonderMove supports one-shot location capture, permission/accuracy helper identifiers, a `LocationPoint` model, and geotagged-photo identifiers. The evidence does **not** establish continuous tracking, breadcrumbs, offline sync, truck-device ingestion, or any map SDK.

**Recommendation:** Do not start Phase 1A implementation until the schema strategy, backend control-plane verification, RLS/RPC design, serialization fix, and platform identity issues are reviewed and approved.

---

## 2. Evidence sources and limitations

### 2.1 Sources inspected

| Source | Path / identifier |
|---|---|
| Prior progress report | `/home/ubuntu/easyfleet-flutter/PROGRESS-REPORT.md` |
| Project README | `/home/ubuntu/easyfleet-flutter/README.md` |
| Adoption matrix | `/home/ubuntu/REA-APK-Analysis/WonderMove-Adoption-Matrix.md` |
| REA evidence bundle | `/home/ubuntu/REA-APK-Analysis/rea-evidence-bundle.json` |
| WonderMove APK artefacts | `/home/ubuntu/REA-APK-Analysis/originals/` |
| Native Driver APK | `/home/ubuntu/REA-APK-Analysis/originals/EasyFleet-Driver.apk` |
| Native Transporter APK | `/home/ubuntu/REA-APK-Analysis/originals/EasyFleet-Transporter.apk` |
| Flutter workspace | `/home/ubuntu/easyfleet-flutter` |
| Flutter package graph/source | `apps/*`, `packages/*` |
| Live Supabase data-plane probes | `GET`/`OPTIONS` only; key redacted |

### 2.2 Limitations

- APK analysis is static only; APKs were not executed.
- Dart AOT strings are lower bounds and do not expose method bodies.
- No original native source tree or de-obfuscation mapping file was available.
- A Supabase publishable/anon-equivalent key was recovered from the native APK for read-only probes, but the value is redacted in this report.
- No service-role or read-only database key was found. Therefore the following could **not** be verified:
  - exact RLS policy bodies and commands
  - trigger and function definitions
  - storage policy definitions
  - realtime publication membership
  - authoritative catalog metadata via `information_schema`, `pg_policies`, `pg_trigger`, `pg_proc`, `storage.policies`, `pg_publication_tables`
- Absence claims marked “404 / not in schema cache” are strong data-plane evidence but should be confirmed with privileged catalog access when available.
- No native builds were run; iOS/Android platform issues were identified from configuration files only.

---

# TASK 1 — SUPABASE SCHEMA AUDIT

## 3. Access and configuration findings

| Item | Result |
|---|---|
| Supabase project URL | Confirmed from Flutter config, README, adoption matrix, and native APKs: `https://iktekjnisqmbjtoictnc.supabase.co` |
| Storage bucket name | `easyfleet-private-documents`, described in docs as private |
| Publishable/anon key | Found embedded in native APKs; recovered in memory and redacted in this report |
| Service role / secret key | Not found in local files, env vars, shell history, REA bundle, or APK byte scan |
| Supabase CLI config / migrations | None found |
| SQL migration files | None found |
| REA evidence bundle schema records | None; bundle contains WonderMove/native APK static-analysis evidence only |

## 4. Live read-only probe results

| Probe | Result | Interpretation |
|---|---|---|
| `GET /rest/v1/` without key | `401 No API key found` | Endpoint reachable |
| `GET /rest/v1/` with publishable key | `401 Secret API key required` | OpenAPI/catalog requires stronger key |
| `GET /auth/v1/settings` | `200` | Email auth enabled; signup enabled; autoconfirm false; anonymous users disabled; passkeys disabled |
| `GET /storage/v1/bucket` | `200 []` | No buckets visible to anon |
| `GET /storage/v1/bucket/easyfleet-private-documents` | `400 NoSuchBucket` | Bucket not visible to anon; existence/policies unverified |
| `GET /realtime/v1/api/tenants/.../publications` | `401 API key missing` | Realtime publication unverified |

## 5. Tables and columns actually observed

Anon `SELECT` is denied on all discovered tables, which is consistent with authenticated-only RLS but does not prove policy correctness. Column presence was probed safely using `?select=<candidate>&limit=0`; `400 42703` indicated absence.

### 5.1 `trip_location_breadcrumbs` — exists

Confirmed columns:

```text
id
trip_id
latitude
longitude
recorded_at
created_at
```

Confirmed absent among probed candidates:

```text
accuracy
sync_state
idempotency_key
driver_id
transporter_id
device_id
updated_at
status
stage
tripId
recordedAt
```

### 5.2 `companies` — exists

Confirmed columns:

```text
id
gstin
legal_name
name
status
created_at
updated_at
```

Confirmed absent among probed candidates:

```text
gst
trade_name
gst_verification
gst_document_url
email
phone
address
permissions
user_id
owner_id
```

### 5.3 `company_memberships` — exists

Confirmed columns:

```text
id
company_id
user_id
role
status
created_at
updated_at
```

Confirmed absent: `permissions`.

### 5.4 `fleet_trips` — exists

Confirmed columns:

```text
id
vehicle_id
scheduled_date
origin
destination
material
status
started_at
completed_at
created_at
updated_at
created_by
```

Confirmed absent among probed candidates:

```text
stage
vehicle_number
driver_id
transporter_id
assignment_id
gps_device_id
party_name
loading_point
unloading_point
tonnage
current_location_label
scheduled_at
gps_imei
```

### 5.5 `fleet_vehicles` — exists

Confirmed columns:

```text
id
registration_number
company_id
status
created_at
updated_at
make
model
vehicle_type
created_by
```

Confirmed absent among probed candidates:

```text
imei
transporter_id
vehicle_number
sim_number
last_seen_at
last_latitude
last_longitude
gps_imei
device_id
```

## 6. Tables confirmed absent

The following returned `404 PGRST205: Could not find the table in the schema cache`.

### 6.1 Flutter Phase 1A tables absent

```text
trips
driver_profiles
transporter_companies
job_postings
job_applications
assignments
gps_devices
gps_positions
trip_events
user_permissions
```

### 6.2 Native/alternative names also absent

```text
driver_trips
driver_location_breadcrumbs
driver_job_vacancies
driver_job_applications
driver_fuel_entries
driver_adblue_entries
driver_expenses
driver_pod_entries
driver_breakdown_reports
driver_bank_details
driver_earnings_ledger
driver_outbox
fleet_companies
fleet_transporters
alerts
inspections
payouts
vehicles
parties
expenses
fuel_entries
adblue_entries
pod_entries
breakdown_reports
bank_details
earnings_ledger
app_config
app_versions
permissions
users
profiles
drivers
transporters
fleet_drivers
fleet_gps_devices
fleet_gps_positions
fleet_job_postings
fleet_assignments
fleet_trip_events
fleet_breadcrumbs
locations
positions
device_positions
gps_data
gps_locations
```

> **Important contradiction:** `README.md` and `PROGRESS-REPORT.md` state or imply that `trips` already exists. Live probing shows `public.trips` is **not** in the schema cache. The closest existing table is `fleet_trips`, with an incompatible schema.

## 7. Flutter service assumptions vs actual schema

| Flutter table / field assumption | Flutter evidence | Actual status | Severity |
|---|---|---|---|
| `driver_profiles` with `dl_number`, `license_class`, `dl_verification`, `dl_document_url` | `packages/network/lib/src/supabase_tables.dart:3`; `onboarding_service.dart:41-47` | Table absent | Critical |
| `transporter_companies` with `gst`, verification/document fields | `supabase_tables.dart:4`; `onboarding_service.dart:56-62` | Table absent; `companies` exists with `gstin` and no verification fields | Critical |
| `job_postings` | `supabase_tables.dart:5`; `marketplace_service.dart:24-57` | Table absent | Critical |
| `job_applications` | `supabase_tables.dart:6`; `marketplace_service.dart:60-89` | Table absent | Critical |
| `assignments` | `supabase_tables.dart:7`; `marketplace_service.dart:101-132` | Table absent | Critical |
| `gps_devices` with unique `imei` | `supabase_tables.dart:8`; `gps_device_service.dart:18-42` | Table absent | Critical |
| `gps_positions` | `supabase_tables.dart:9`; `gps_device_service.dart:45-50` | Table absent | Critical |
| `trips` with `stage` | `supabase_tables.dart:10`; `trip_lifecycle_service.dart:55-58` | Table absent; `fleet_trips` has `status`, not `stage` | Critical |
| `trip_events` | `supabase_tables.dart:11`; `trip_lifecycle_service.dart:44-66` | Table absent | Critical |
| `trip_location_breadcrumbs.transporter_id` | `gps_device_service.dart:52-57` | Column absent | Critical |
| `trip_location_breadcrumbs.idempotency_key` | Native evidence and Flutter sync design | Column absent | High |
| `trip_location_breadcrumbs.accuracy` | Native evidence and domain model | Column absent | High |
| `user_permissions` | `permissions_service.dart:13-16` | Table absent | Critical |
| Private Storage bucket with signed/authorized reads | `onboarding_service.dart:31-32` | Bucket/policies unverified; anon sees none | High |
| Realtime on assignments/events/positions/breadcrumbs | Four `.stream(...)` calls | Publication unverified; 3 target tables absent | Critical |
| RPCs `create_driver_account`, `register_company`, `get_my_companies`, `post_journal_entry`, `delete_row`, etc. | `api_endpoints.dart`, `sync_service.dart` | Unverified with read-only key | Medium |

## 8. Constraints, indexes, policies, triggers, functions

Because privileged catalog access was unavailable, these are **required but unverified**:

### 8.1 Constraints

- Unique normalized `dl_number`
- Unique normalized GSTIN/GST
- Unique `gps_devices.imei`
- Foreign keys for:
  - `job_postings.transporter_id`
  - `job_applications.job_id`, `driver_id`, `assignment_id`
  - `assignments.driver_id`, `transporter_id`, `job_id`, `application_id`
  - `gps_devices.transporter_id`
  - `gps_positions.gps_device_id`, `transporter_id`
  - `trips.assignment_id`, `gps_device_id`
  - `trip_events.trip_id`
  - `trip_location_breadcrumbs.trip_id`
  - `user_permissions.user_id`
- Append-only enforcement for `trip_events`

### 8.2 Indexes implied by Flutter queries

```text
job_postings(status, created_at desc)
job_postings.required_license_classes (GIN/array support)
job_postings.vehicle_category
job_postings.pickup_location (trigram/GIN for ilike)
job_applications(job_id, applied_at)
job_applications(driver_id, applied_at desc)
assignments(driver_id, transporter_id)
gps_devices(transporter_id)
gps_positions(transporter_id)
trip_events(trip_id, occurred_at)
trip_location_breadcrumbs(transporter_id, recorded_at)  -- impossible until column exists
user_permissions(user_id)
```

### 8.3 RLS policies required

- Driver: own profile, own applications, own assignments/trips/events/breadcrumbs; select open jobs.
- Transporter: own company/membership scope, own job posts, applicants for own jobs, own assignments/devices/positions/trips/events.
- Storage: owner-only upload paths; verifier-only reads; no public reads for private documents.
- Realtime: only rows permitted by SELECT policy.
- No client UPDATE/DELETE on event/position append-only tables.

### 8.4 Functions/triggers required

- Driver/company account creation
- Job application with server-derived driver identity and experience snapshot
- Atomic appointment creation
- Atomic trip-stage transition
- Position/breadcrumb ingestion with idempotency
- Document submission after upload
- `updated_at` maintenance
- Safe deletion/soft-delete of assignments
- Replacement or strict allow-listing of generic `delete_row`

---

# TASK 2 — EXISTING ANDROID PROJECTS AUDIT

## 9. Native Driver app — confirmed capabilities

APK: `/home/ubuntu/REA-APK-Analysis/originals/EasyFleet-Driver.apk`  
Package: `com.easyfleet.driver`

### 9.1 App shell

- Tabs: Home, Trips, Logbook, Jobs, Wallet.
- Home tiles: assigned trips, find job vacancies, trip details/route, odometer/fuel/AdBlue/expense logging, breakdown emergency, auto-sync status.
- Evidence: `MainActivityKt.EasyFleetDriverApp`, `DriverHomeScreen`; evidence IDs include `ev_1d0eae...`, `ev_00dd4b...`.

### 9.2 Auth and driver identity

- Password sign-in, signup, recovery, refresh.
- Calls `create_driver_account` and `get_my_driver_account` RPCs.
- Session persists access token, refresh token, company ID, driver account ID.
- Driver registration UI with password confirmation.
- DL identity in wallet: `DL Number`, `DL Verification Status`, `Upload Front DL`, `Upload Back DL`, `driver_documents`.
- Company enrollment states: `isCompanyEnrolled`, `FLEET ENROLLED`, `Apply & Enroll in Fleet`.
- Evidence: `DriverSessionManager`, `DriverAuthScreen`, `DriverWalletScreen`; representative IDs `ev_e79060...`, `ev_1ff221...`, `ev_461ff5...`.

### 9.3 Job market

- `FindJobsScreen`: “Transport Vacancies & Open Trip Offers”, route/city/cargo/truck-type search.
- `JobVacancy` model.
- Local tables: `driver_job_vacancies`, `driver_job_applications`.
- Evidence: `ev_ccd0e5...`, `ev_687361...`, `ev_4e5248...`.

### 9.4 Trip lifecycle and POD

- Actions: acknowledge/accept trip, start trip and transit, odometer readings, record unloading/delivery, upload signed POD, stop tracking.
- POD submission queued to `/rest/v1/trip_closures`.
- Evidence: `DriverTripsScreen` `ev_fabc2b...`, `DriverSyncWorker.processOutboxQueue` `ev_3b85a2...`.

### 9.5 Logbook

- Unified Road Logbook: Diesel, AdBlue, Expenses, Breakdown.
- Structured records: `AdBlueEntryRecord`, `BreakdownReportRecord`, `DriverExpenseRecord`, `FuelEntryRecord`.
- Outbox endpoints:
  - `TRIP_EVENT` → `/rest/v1/trip_events`
  - `FUEL_ENTRY` → `/rest/v1/trip_fuel_entries`
  - `EXPENSE_ENTRY` → `/rest/v1/trip_expenses`
  - `BREAKDOWN_REPORT` → `/rest/v1/trip_breakdowns`
  - `POD_SUBMISSION` → `/rest/v1/trip_closures`
- Evidence: `UnifiedLogbookScreen` `ev_620c06...`.

### 9.6 Wallet and earnings

- Wallet shows DL identity, enrollment, last payout.
- Local tables: `driver_bank_details`, `driver_earnings_ledger`.
- Payout execution not established from Driver APK.

### 9.7 GPS

- `LiveTrackingService` foreground service.
- Fused location client; notification channel `EASYFLEET_TRACKING`.
- `LocationRequest.Builder(100, 15000L).setMinUpdateIntervalMillis(10000L)`.
- Local table `driver_location_breadcrumbs`.
- Sync to `/rest/v1/trip_location_breadcrumbs?idempotency_key=eq.<key>`.
- Runtime permission requests for fine location and POST_NOTIFICATIONS on SDK 33+.
- Evidence: `ev_1d5396...`, `ev_3205e0...`, manifest `ev_edf6c5...`.

### 9.8 Offline storage and sync

Local tables:

```text
driver_profile
driver_trip_cache
driver_outbox
driver_document_queue
driver_job_vacancies
driver_job_applications
driver_fuel_entries
driver_adblue_entries
driver_breakdown_reports
driver_bank_details
driver_location_breadcrumbs
driver_expenses
driver_pod_entries
driver_earnings_ledger
```

`DriverSyncWorker` methods:

```text
doWork
processOutboxQueue
processDocumentQueue
processLocationBreadcrumbsQueue
```

- Recovery SQL resets `UPLOADING` rows to `PENDING`.
- Periodic 15-minute WorkManager job with `NetworkType.CONNECTED`.

### 9.9 Deep links

- Manifest app link: `https://app.easyfleet.in/trip/`.
- `MainActivity.onCreate` reads `intent.data`, validates host, parses trip ID.

### 9.10 Notifications

- Local foreground tracking notification confirmed.
- Remote push/FCM not observed in bounded searches.

---

## 10. Native Transporter app — confirmed capabilities

APK: `/home/ubuntu/REA-APK-Analysis/originals/EasyFleet-Transporter.apk`  
Package: `com.easyfleet.transporter`

### 10.1 App shell

Tabs: Dashboard, Fleet, Recruitment, Accounts, Review.

Dashboard indicates:

```text
EASYFLEET TRANSPORTER ERP
3 BUSINESS MODELS SUPPORTED
Fleet Control & Dashboard
Customer Invoices
Trip Profitability
Driver Recruitment
Review & Approvals Queue
Accounting & Ledgers
Receivables / Payables / Net Margin
```

Evidence: `EasyFleetApp` `ev_8d7245...`.

### 10.2 Auth, company registration, membership

- Password sign-in, signup, recovery, refresh.
- RPCs: `get_my_companies`, `register_company`.
- `CompanyMembership` fields: `companyId`, `companyName`, `role`, `status`.
- Auth flow states: LOGIN, REGISTER, FORGOT, REGISTER_COMPANY, SELECT_COMPANY.
- Company-missing block: `CRITICAL ERROR: Active Company Identity Missing. Financial operations blocked.`
- Evidence: `TransporterSessionManager` `ev_ad0b24...`, `TransporterAuthFlow` `ev_e465ab...`.

### 10.3 GST and fleet control

- `SavedFleetScreen`: Company & Fleet Control.
- GSTIN form: “Company Verification & GSTIN”, legal name, 15-char GSTIN, GST certificate PDF, NOT VERIFIED.
- Vehicle form: registration number, vehicle type, odometer.
- Driver form: full name, phone.
- `CompanyProfileRecord`: `gstin`, `gstCertificateUri`, `companyName`, `phone`, `email`, `address`.

### 10.4 Recruitment

- Candidate pool: “Search Open-to-Work drivers & manage job postings”.
- Vacancy posting: title, truck type, location, offered monthly pay.
- Hire driver and register in fleet.
- Candidate states: `ON_TRIP`, `AVAILABLE`.

### 10.5 Dispatch and profitability

- Dispatches & Route Control.
- Origin/destination, material, tonnes, GC/consignment number, checkpoints, GPS.
- Operating expenses, freight revenue, material sales, net contribution, gross material margin, supplier collection liability, provisional contribution.
- Three explicit business models:
  - `MODEL_1_CUSTOMER_MATERIAL_FREIGHT`
  - `MODEL_2_TRANSPORTER_PURCHASE_RESALE`
  - `MODEL_3_SUPPLIER_DIRECT_DELIVERY`

### 10.6 Review, POD approval, settlement

- Review & Approvals Centre.
- POD pending/completed states.
- Approve POD & Settle, Request Fix, Dispatch via WhatsApp.
- Payout settlement text: amounts, advances, net payable.
- Biometric re-auth before ERP posting:
  - `BiometricPrompt`
  - `Authorise ERP Transaction`
  - `Authenticate to post journal entries and settle trip`
  - On success inserts trip closure/outbox and starts `TransporterSyncWorker.syncNow`
  - Message states payout requires verified UPI beneficiary and was not initiated.

### 10.7 Accounting and ERP

- Accounting & ERP Ledgers: double-entry ledgers, receivables, payables.
- Customers, vendors, invoices, bills.
- Chart of accounts sync: `/rest/v1/chart_of_accounts?company_id=eq.`
- COA fields: `account_code`, `account_name`, `account_type`, `sub_category`, `is_system_account`, `company_id`.
- `BLOCKED_COA` state with recovery SQL.
- Journal posting RPC `post_journal_entry`.
- Evidence: `ev_ac5779...`, `ev_b30691...`.

### 10.8 Offline storage and sync

Local tables:

```text
vehicles
drivers
trips
transporter_outbox
company_profile
customers
vendors
chart_of_accounts
journal_entries
journal_lines
customer_invoices
vendor_bills
trip_closures
job_vacancies
job_applications
transporter_document_queue
```

Event types include:

```text
COMPANY_PROFILE_UPDATE
VEHICLE_ADD
DRIVER_ADD
CUSTOMER_ADD
VENDOR_ADD
TRIP_ADD
JOB_VACANCY_ADD
TRIP_STATUS_UPDATE
CUSTOMER_INVOICE_ADD
VENDOR_BILL_ADD
TRIP_CLOSURE
```

- Periodic 15-minute WorkManager job with `NetworkType.CONNECTED`.
- Sync scheduled in `MainActivity.onCreate`.

### 10.9 Deep links and notifications

- No transporter app-link filter or DeepLink/AppLink class observed in bounded search.
- No remote push/FCM observed.
- `FOREGROUND_SERVICE` declared, but no first-party foreground service observed in transporter component list.

---

## 11. Native vs Flutter parity summary

| Area | Native status | Flutter status |
|---|---|---|
| Auth sign-in | Implemented | Implemented |
| Signup/recovery/company selection | Implemented | Missing |
| Driver DL identity/documents | Implemented | Placeholder/controller only |
| Transporter GST/fleet forms | Implemented | Placeholder |
| Job market | Implemented | Placeholder/service defective |
| Appointment/hiring | Implemented | Placeholder/non-atomic service |
| Trip lifecycle/POD | Implemented | Placeholder/client-only service |
| GPS tracking | Implemented in Driver | Dependencies only |
| Offline queues/sync | Implemented in both apps | Generic, broken, unwired |
| Document queue | Implemented in both apps | Missing |
| Wallet/earnings/logbook | Implemented in Driver | Mostly missing |
| Recruitment/dispatch | Implemented in Transporter | Placeholder |
| Accounting/ERP | Implemented in Transporter | Missing |
| Review/POD settlement | Implemented with biometrics | Missing |
| Deep links | Implemented in Driver | Parser only |
| Local notifications | Implemented for GPS | Dependency only |

---

# TASK 3 — FLUTTER WORKSPACE AUDIT

## 12. Implemented functionality verified from code

| Area | Evidence |
|---|---|
| Pub workspace with 9 members | `pubspec.yaml:1-18`; every member has `resolution: workspace` |
| Codegen and verify scripts | `scripts/codegen.sh`, `scripts/verify.sh` |
| Environment config/theme/routes | `packages/core/lib/src/config/environment_config.dart`, `theme/app_theme.dart`, `router/app_routes.dart` |
| Seven-locale l10n | `packages/core/lib/src/l10n/app_*.arb`; generated localizations |
| Deep-link parser | `packages/core/lib/src/deep_links/deep_links.dart:4-13` |
| Supabase initialization | both `lib/main.dart:8-17` |
| Auth controller and password login UI | `packages/auth/lib/src/auth_controller.dart`, `ui/login_screen.dart` |
| Biometric service and permissions provider | `packages/auth/lib/src/biometric_service.dart`, `permissions_service.dart` |
| Onboarding controller | `packages/auth/lib/src/onboarding_controller.dart` |
| Dio client/interceptors | `packages/network/lib/src/dio_client.dart`, `interceptors.dart` |
| Supabase REST/RPC wrapper | `packages/network/lib/src/supabase_data_source.dart` |
| Freezed domain models | `packages/domain/lib` |
| Shared UI widgets | `packages/ui/lib/src/widgets/*` |
| sqflite outbox schema/CRUD | `packages/sync/lib/src/outbox_repository.dart` |
| Map widgets | `packages/maps/lib/src/live_fleet_map.dart`, `trip_route_map.dart` |
| Android/iOS shells | `apps/*/android`, `apps/*/ios` |

## 13. Critical Flutter defects

### C1 — Snake_case ↔ camelCase mapping is broken

Services write/read snake_case columns:

- `marketplace_service.dart:41-57`, `61-71`, `101-110`
- `gps_device_service.dart:35-41`
- `onboarding_service.dart:41-62`
- `trip_lifecycle_service.dart:45-52`

Generated `fromJson` expects camelCase keys:

- `job_posting.g.dart:9-37` — `transporterId`, `requiredLicenseClasses`, `payPerTrip`, `createdAt`
- `job_application.g.dart:9-26` — `jobId`, `driverId`, `appliedAt`
- `assignment.g.dart:9-21` — `driverId`, `transporterId`, `appointedAt`
- `gps_device.g.dart:9-21` — `transporterId`, `lastSeenAt`
- Similar mismatches in profile, trip, event, company, breadcrumb models

`MarketplaceService._normalize()` only copies the map; it does not translate keys. No `@JsonField`/`@JsonKey` annotations or snake_case build configuration exist.

**Impact:** Most core-loop deserialization will throw on required-null casts.

### C2 — No schema/migrations/RLS in repository

No `.sql`, migration, policy, or Supabase config files exist. All security depends on unverified backend state.

### C3 — Private documents use public URLs

`packages/network/lib/src/onboarding_service.dart:24-33` uploads to the private bucket and calls `getPublicUrl(path)`. The bucket is documented as private in `environment_config.dart:27-30` and prior reports.

Either reads break or identity documents are exposed. Neither outcome is acceptable.

### C4 — Feature UI absent and routes incomplete

- Driver/Transporter feature routes render `PlaceholderScreen`.
- `AppRoutes.onboarding` and `AppRoutes.tripDetail` are not registered in app routers.
- Transporter has no job-posting route.
- Deep link parser is only used in a test; no `/trip/:tripId` GoRoute or platform-link listener exists.

### C5 — Offline outbox cannot round-trip and is never invoked

- `OutboxEntry.payload` is a `Map`, but SQLite column is `TEXT`.
- `OutboxEntry.fromMap` casts payload back to `Map`.
- `sync_service.dart:44` casts `entry.payload['id'] as String`.
- `syncServiceProvider.flush()` has no call sites.
- Idempotency key is stored locally but not sent to the server.
- RPC `delete_row` does not exist in the repository.
- Only `DioException` is caught.

### C6 — Fail-open configuration and debug signing

- `environment_config.dart:22-25` defaults Supabase URL to production.
- Missing anon key becomes empty string but app still calls `Supabase.initialize`.
- Invalid `APP_FLAVOR` silently selects `prod`.
- Both Android release configs sign with `debug`.
- `anonKey` is deprecated in favor of `publishableKey`.

## 14. High Flutter defects

| ID | Finding | Evidence |
|---|---|---|
| H1 | Session-only auth gating; no role/verification gating | Both `app_router.dart:20-27`; `auth_state.dart` has no role/verification |
| H2 | Supabase tokens stored via default local storage, not `flutter_secure_storage` | `main.dart` calls `Supabase.initialize` without `FlutterAuthClientOptions(localStorage: ...)` |
| H3 | Service contracts incomplete/unsafe | `onboarding_service.dart` drops experience/company fields; `searchJobs` lacks experience/pay filters; appointment non-atomic; trips not created |
| H4 | Realtime streams start empty and target absent/unconfigured tables | `marketplace_service.dart:122-132`, `gps_device_service.dart:45-57`, `trip_lifecycle_service.dart:61-67` |
| H5 | Stream subscription and router lifecycle leaks | Map widgets call `.listen` without cancelling; GoRouter recreated without disposal |
| H6 | Platform config gaps | iOS bundle IDs wrong; missing iOS usage descriptions; transporter lacks location permissions; Maps key empty fallback; no `assetlinks.json` |
| H7 | No signup/recover/OTP/company-selection UI | Login screen only performs password sign-in |
| H8 | Unwired services create false confidence | No call sites for sync, marketplace, lifecycle, GPS device, maps, biometric, permissions, onboarding providers |

## 15. Dependency and architecture assessment

- No package dependency cycles were found.
- Package direction is broadly correct: `domain` pure; `network → core,domain`; `auth → core,domain,network`; apps depend on all.
- Problems:
  - `core` generated l10n imports `flutter_localizations` but does not declare it directly.
  - `domain` depends on Flutter unnecessarily.
  - Driver declares GPS/notification/WorkManager dependencies but does not use them.
  - Transporter declares maps/GPS-related packages but lacks matching permissions.
  - `AuthInterceptor` uses process-global Supabase singleton state.
  - Connectivity provider defaults to online before first stream event.
  - Map widgets leak stream subscriptions.
  - Analysis options globally ignore `deprecated_member_use` and exclude generated code, weakening static-analysis claims.

## 16. Tests and verification claims

Actual tests:

- `apps/driver/test/smoke_test.dart` — constructor assertion + deep-link string parse
- `apps/transporter/test/smoke_test.dart` — constructor assertion + route constant equality

No package-level tests exist for:

- JSON mapping
- trip transitions
- appointment logic
- onboarding
- sync flush
- GPS binding
- RLS/Realtime/Storage
- native builds

`flutter analyze` and smoke tests may pass, but they do not validate functionality.

---

# TASK 4 — GPS AUDIT AND PROVIDER-INDEPENDENT DESIGN

## 17. What WonderMove evidence actually establishes

### 17.1 Established

From WonderMove APK evidence and string observations:

- Permissions: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- Declared geolocator component: `com.baseflow.geolocator.GeolocatorLocationService`, `foregroundServiceType="location"`
- Plugin methods inspected: `onCreate()` logs service creation; `onStartCommand()` returns `START_STICKY`; no location request/listener/notification/breadcrumb logic in those bodies
- Dart identifiers: `Geolocator`, `LocationSettings`, `LocationServiceDisabledException`, `InvalidPermissionException`, `AndroidPosition`
- First-party identifiers:
  - `LocationPoint` model
  - `captureDriverLocation`
  - `ensureLocationAccess`
  - `isLocationServiceEnabled`
  - `openLocationSettings`
  - `getCurrentPosition`
  - `getLastKnownPosition`
  - `forceAndroidLocationManager`
  - `/driver/capturedLocation`
- Geotag identifiers: `PhotoLocation`, `currentPhotoLocation`, `InspectionPhotoStrip`, `TyrePhotoSlots`

### 17.2 Not established

The evidence does **not** establish:

- Continuous live tracking
- Position streams or background breadcrumbs
- WorkManager-based GPS sync
- Truck/device GPS ingestion
- Offline breadcrumb queue
- Any map SDK (`google_maps_flutter`, Mapbox, `flutter_map`)
- Route polylines, ETA, fleet markers, live map
- Runtime proof that `/driver/capturedLocation` is called
- Exact request payload or persistence semantics

**Conclusion:** WonderMove is a reference for one-shot capture, permission/accuracy handling, and geotagging only.

## 18. What EasyFleet native Driver establishes

- `LiveTrackingService` foreground service with fused location client.
- Notification channel `EASYFLEET_TRACKING`.
- Request configuration: `LocationRequest.Builder(100, 15000L).setMinUpdateIntervalMillis(10000L)`; final explicit minimum interval is 10 seconds.
- Local `driver_location_breadcrumbs`.
- `DriverSyncWorker.processLocationBreadcrumbsQueue`.
- Supabase REST target `/rest/v1/trip_location_breadcrumbs` with `idempotency_key=eq.<key>`.
- Local sync states `LOCAL`, `PENDING`, `UPLOADING`, `FAILED`, `FAILED_PERMANENT`, `SYNCED`.
- Retry policy observed: `attempt_count < 5` for at least outbox queue.
- Runtime permission request for fine location and POST_NOTIFICATIONS.
- The native idempotency URL filter is a string observation; its effectiveness depends on server-side unique constraints/RPC semantics and must not be assumed.

## 19. Flutter GPS status

- Driver declares `geolocator`, `permission_handler`, `flutter_local_notifications`, `workmanager`, but no Dart code imports them.
- No foreground service, notification channel, permission flow, breadcrumb writer, WorkManager task, one-shot capture, or geotagged photo service exists.
- `packages/maps` widgets exist but are not wired to app routes or services.
- Map widgets leak stream subscriptions.
- Transporter map uses `myLocationEnabled: true` but transporter manifest has no location permission and no geolocator dependency.

## 20. Provider-independent architecture design

### 20.1 Goals

1. One canonical position model for phone and device sources.
2. UI knows nothing about vendor APIs or IMEI formats.
3. Adding a vendor requires an adapter/config, not app changes.
4. Offline-first with end-to-end idempotency.
5. Server-authoritative trip/session/RLS rules.
6. Preserve EasyFleet native tracking semantics.

### 20.2 Canonical model

Introduce an append-only fact model, e.g. `position_events`:

```text
id                    uuid/ulid primary key
idempotency_key       text unique not null
trip_id               uuid null
vehicle_id            uuid null
device_id             uuid null
driver_id             uuid null
transporter_id        uuid null
source_kind           DRIVER_PHONE | VEHICLE_DEVICE
source_ref            text
vendor                text
latitude              double
longitude             double
accuracy_m            double null
altitude_m            double null
speed_mps             double null
heading_deg           double null
recorded_at           timestamptz
received_at           timestamptz default now()
sequence              bigint null
valid                 boolean default true
raw_ref               text null
created_at            timestamptz default now()
```

Constraints:

- `unique(idempotency_key)`
- indexes:
  - `(trip_id, recorded_at desc)`
  - `(vehicle_id, recorded_at desc)`
  - `(transporter_id, received_at desc)`
- append-only; no client UPDATE/DELETE
- RLS: driver inserts only for own active assigned trip; transporter reads only own rows

Read model:

```text
vehicle_positions
```

A view/projection joining latest positions with `gps_devices`, `fleet_vehicles`, and trip metadata. Both map widgets consume this read model.

### 20.3 Core interfaces

```dart
enum PositionSourceKind { driverPhone, vehicleDevice }
enum PositionSourceStatus { idle, starting, active, degraded, stopped, error }

class PositionFix {
  // idempotencyKey, kind, tripId, vehicleId, deviceId, driverId,
  // transporterId, sourceRef, vendor, latitude, longitude,
  // accuracyM, altitudeM, speedMps, headingDeg, recordedAt,
  // sequence, rawPayloadRef
}

abstract interface class LocationSource {
  PositionSourceKind get kind;
  String get vendor;
  Stream<PositionFix> watchFixes();
  Future<PositionFix> captureOnce({LocationAccuracyPreference accuracy});
  Future<void> startTripSession(TripTrackingSession session);
  Future<void> stopTripSession(String tripId, {String reason});
  Stream<PositionSourceStatus> watchStatus();
  Future<void> dispose();
}

abstract interface class VendorPositionAdapter {
  String get vendorCode;
  Future<List<PositionFix>> fetchSince(DateTime? cursor);
  PositionFix normalize(dynamic vendorPayload, DeviceBinding binding);
  Future<VendorHealth> checkHealth();
}

abstract interface class PositionIngestor {
  Future<IngestReceipt> ingest(PositionFix fix);
  Future<IngestBatchReceipt> ingestBatch(List<PositionFix> fixes);
}
```

### 20.4 Source implementations

**PhoneLocationSource**

- OS permission handling via `permission_handler`
- service-enabled checks
- explicit `LocationSettings` and Android fallback
- foreground service of type `location`
- configurable 10–15 s cadence
- ongoing notification equivalent to `EASYFLEET_TRACKING`
- write locally before network
- one-shot capture for check-in/check-out/geotagging
- stop on complete/cancel/logout/consent withdrawal/reassignment

**VehicleDeviceSource / vendor gateway**

- Runs server-side, not in the app
- Holds vendor credentials in a vault
- Resolves IMEI → device binding
- Calls vendor APIs/webhooks
- Normalizes through `VendorPositionAdapter`
- Writes through `PositionIngestor`
- App only binds devices, shows health/last-seen, and reads normalized positions

Vendor adapters own authentication, cursors, timestamp parsing, coordinate unit conversion, speed/heading normalization, duplicate handling, and schema drift.

### 20.5 Ingestion boundary

```text
Driver phone --JWT--> ingest_position RPC --> position_events
Vendor gateway --scoped service role--> ingest_position RPC --> position_events
```

RPC requirements:

- `INSERT ... ON CONFLICT (idempotency_key) DO NOTHING RETURNING *`
- derive `transporter_id` from trip/device binding, never client input
- validate active trip/session and source authorization
- reject stale/out-of-bounds/duplicate fixes
- append-only audit

### 20.6 Offline breadcrumbs

Local `position_outbox`:

```text
id
idempotency_key unique
payload_json
created_at
attempts
next_attempt_at
status PENDING|FAILED|SYNCED|DEAD
last_error
```

Rules:

1. Capture writes to local DB first.
2. Worker batches pending rows.
3. Send idempotency key in every request.
4. Mark synced only after server confirmation.
5. Exponential backoff with jitter; cap attempts; dead-letter.
6. Retention/TTL and storage cap.
7. Reschedule on connectivity, boot, and app resume.
8. Surface sync lag and dead rows as exceptions/alerts.

### 20.7 Unified trip tracking

- Appointment creates `TripTrackingSession`.
- Consent/permission collected before continuous tracking.
- `advance_trip_stage` RPC writes event and updates stage atomically and opens/closes tracking sessions.
- Phone and device positions join by `trip_id` or `vehicle_id`.
- Both apps subscribe to Realtime on normalized read models.

---

# TASK 5 — TRANSACTION AND SECURITY AUDIT

## 21. Top transactional/security blockers

| ID | Severity | Finding | Evidence | Failure scenario |
|---|---|---|---|---|
| F1 | Critical | Appointment creation is two independent writes with caller-supplied IDs | `marketplace_service.dart:93-120` | Network loss after assignment insert leaves inconsistent application state; retry creates duplicate assignment; malicious caller can spoof tenant IDs if RLS weak |
| F2 | Critical | Trip-stage machine enforced only in Dart; event insert and stage update split; actor ID spoofable | `trip_lifecycle_service.dart:18-59` | Concurrent transitions produce conflicting audit rows; partial write desynchronizes log and state; any user with trip ID can advance/cancel |
| F3 | Critical | Tenant isolation depends on unverified RLS | `marketplace_service.dart:122-132`; `gps_device_service.dart:18-57`; no migrations | Dart `.where()` after receiving rows is not a security boundary; missing/weak RLS leaks all assignments/applicants/positions |
| F4 | Critical | Private bucket documents exposed through permanent public URLs | `onboarding_service.dart:24-33` | Guessable URL leaks DL/GST documents; public bucket misconfiguration exposes identity documents |
| F5 | High | DL/GST uniqueness only documented, not enforced | `driver_profile.dart:13-14`; `transporter_company.dart:12-13`; no migrations | Duplicate identities; approval-state resets; weak RLS allows profile overwrite |
| F6 | High | Offline idempotency key stored locally but never sent | `outbox_entry.dart:22,33`; `sync_service.dart:38` | Ambiguous ack causes duplicate server writes |
| F7 | High | Generic `delete_row` RPC with client-supplied table name | `sync_service.dart:46-50` | Tampered outbox row may delete records outside tenant if dynamic SQL/SECURITY DEFINER is unsafe |
| F8 | High | No role/verification gating; role client-asserted | `auth_state.dart`; both routers; `onboarding_controller.dart:54-57` | Unverified users reach privileged UI; UI gating mistaken for authorization |
| F9 | High | Upload and profile write non-atomic; storage path unsanitized | `onboarding_service.dart:30-63` | Orphaned docs; broken references; path traversal risk |
| F10 | High | Breadcrumb queue declared but not implemented; native idempotency pattern unsafe | `outbox_repository.dart:33-44`; no methods; matrix:137-140 | Duplicate GPS rows; stale positions; cross-tenant injection if RLS weak |
| F11 | Medium | Predictable client-generated IDs | `marketplace_service.dart:100`; `trip_lifecycle_service.dart:45`; `onboarding_service.dart:30` | Collisions/enumeration; storage overwrite |
| F12 | Medium | Sync failure handling and stream lifecycle gaps | `sync_service.dart:44`; `connectivity_service.dart:11-13`; map widgets | Cast errors abort flush; offline initially masked; stale listeners retain data |
| F13 | High | Search/apply flows lack server-side eligibility checks | `marketplace_service.dart:18-90` | Unapproved/wrong-licence drivers apply; forged experience snapshot; applicant leakage |

## 22. Required transactional controls

1. Single `SECURITY DEFINER` RPCs with fixed `search_path`:
   - `appoint_driver(p_application_id, p_vehicle_number)`
   - `advance_trip_stage(p_trip_id, p_expected_stage, p_next_stage, p_lat, p_lng, p_note)`
   - `apply_to_job(p_job_id, p_cover_note)`
   - `submit_dl`, `submit_gst`
   - `capture_breadcrumb` / `ingest_position`
2. Row locks (`SELECT ... FOR UPDATE`) for appointment and stage transitions.
3. Server-derived `auth.uid()`, role, tenant, and timestamps.
4. DB constraints:
   - unique normalized DL/GST
   - unique IMEI
   - unique active assignment per driver/application
   - unique idempotency keys
   - FKs everywhere
   - append-only events/positions
5. Signed short-TTL document URLs; store object path, not public URL.
6. Idempotency keys in every payload; `ON CONFLICT DO NOTHING`.
7. No dynamic table-name RPC.
8. Role/verification derived from DB/JWT and included in `AuthState`; RLS remains authoritative.
9. Realtime publication and RLS negative tests for Driver A / Transporter B / unauthenticated.

---

# TASK 6 — FINAL GAP MATRIX

Severity: **C** Critical, **H** High, **M** Medium, **L** Low.  
“Unverified” means the audit could not confirm the item with available read-only access; it is not proof of absence.

| ID | Existing functionality | Flutter implementation status | Missing functionality | Evidence and file paths | Severity | Recommended implementation | Dependencies |
|---|---|---|---|---|---|---|---|
| G01 | Live Supabase schema with `companies`, `company_memberships`, `fleet_trips`, `fleet_vehicles`, `trip_location_breadcrumbs` | Flutter assumes a different table set | Reconcile canonical schema before any feature work | Live probes; `supabase_tables.dart:2-13`; `README.md:95-97` | C | Decide whether existing `fleet_*`/`companies` are canonical or Phase 1A tables will be added | Owner decision; read-only DB/service key |
| G02 | `trips` absent; `fleet_trips` has `status`, not `stage` | `Trip` model and lifecycle service use `trips.stage` | Trip table mapping or new schema; stage field compatibility | Live probes; `trip.dart`; `trip_lifecycle_service.dart:55-58` | C | Map Flutter to `fleet_trips` or add approved trip schema; never assume `trips` exists | Schema decision; migration approval later |
| G03 | Native Driver DL number, licence, verification, DL document uploads | Placeholder screen; onboarding controller only | DL onboarding UI, experience capture, document upload, approval states | Driver APK `DriverWalletScreen`; `onboarding_controller.dart`; driver router `:78-84` | C | Build DL onboarding with server-derived identity and signed document access | Schema, RLS, Storage policies, document queue |
| G04 | Native Transporter GSTIN, legal name, GST certificate, company membership | Placeholder screen; GST service only | GST onboarding/registration, company selection, verification states | Transporter APK `SavedFleetScreen`; transporter router `:69-75` | C | Build GST onboarding and company selection using existing `companies`/`company_memberships` semantics | Schema decision, membership RPCs, RLS |
| G05 | Native job market: vacancy search by route/cargo/truck type, apply/enroll | Placeholder + defective service | Job posting, search/filter, detail, apply UI; eligibility checks | Driver APK `FindJobsScreen`; Transporter `RecruitmentScreen`; `marketplace_service.dart:18-89` | C | Implement RPC-backed jobs flow with server-side licence/experience validation | Tables/RPCs, RLS, model mapping fix |
| G06 | Native hiring and company enrollment | Placeholder; non-atomic `appointDriver()` | Atomic appointment, shortlist state, both-app sync | `marketplace_service.dart:93-132`; native enrollment strings | C | `appoint_driver` RPC with row locks, constraints, Realtime | Transaction design, RLS, Realtime publication |
| G07 | Native Driver trip lifecycle: accept, start, odometer, unload, POD | Placeholder; client-only stage service | Trip stage controls, POD upload, immutable event timeline | Driver APK `DriverTripsScreen`; `trip_lifecycle_service.dart:18-67` | C | Atomic `advance_trip_stage` RPC plus real UI; append-only events | Trip schema, RPCs, RLS, Realtime |
| G08 | Native `trip_events`, fuel, expenses, breakdowns, closures endpoints | Flutter `trip_events` table absent; other tables absent | Entire ERP event schema and sync mapping | Native `DriverSyncWorker`; live probes | C | Freeze native-to-Supabase endpoint map and schema contract | Owner decision, backend catalog access |
| G09 | Native foreground GPS service with breadcrumbs and sync | Dependencies declared but no Dart usage | Foreground service, permission flow, breadcrumb writer, WorkManager task | Driver APK `LiveTrackingService`; `apps/driver/pubspec.yaml:16-19`; no `lib/` usage | C | Implement provider-independent phone source and idempotent local outbox | Platform plugins, notification channel, schema, RLS |
| G10 | Native 15-minute WorkManager sync with outbox/document/location queues | Generic outbox broken and never invoked | Working scheduler, queue state machine, document queue, retry/backoff/dead-letter | Native `DriverSyncWorker`/`TransporterSyncWorker`; `sync_service.dart` | C | Rebuild sync using atomic claim/lease, idempotency keys, bounded retries | Schema, RPCs, connectivity, platform config |
| G11 | Native idempotency key usage/attempt semantics | Key stored locally but never sent | End-to-end idempotency | `outbox_entry.dart:22,33`; `sync_service.dart:38`; matrix:137-140 | C | Send key in payload/RPC; unique server constraint; return original row on duplicate | DB constraints, RPC design |
| G12 | Transporter observes GPS/checkpoints; vehicle GPS devices are core requirement | `GpsDeviceService` binds/streams only | Vendor adapters, server-side gateway, normalization, health monitoring | `gps_device_service.dart:12-58` | H | Implement `VendorPositionAdapter` + server ingest gateway | Vendor API decision, secret vault, schema |
| G13 | Live map required at launch; native has no map SDK | Map widgets exist but unwired; subscriptions leak | Wire maps to normalized position streams; cancel subscriptions | `live_fleet_map.dart`, `trip_route_map.dart`; routers | H | Connect map widgets to read model and app routes | Maps key, permissions, position schema |
| G14 | Native Driver app link `/trip/{id}` parsed into trip ID | Parser + smoke test only | Platform link listener, GoRoute, trip detail screen | Driver manifest/MainActivity; `deep_links.dart`; smoke test | H | Wire app-link stream into GoRouter and add trip detail route | `app_links` dependency, route, platform config |
| G15 | Native signup, recovery, company registration/selection | Password login only | Signup/recover UI, account/company RPC calls, company switcher | Native `DriverSessionManager`, `TransporterSessionManager`; `login_screen.dart` | H | Implement auth flows using native RPC names or approved replacements | Auth design, RPC verification, schema |
| G16 | Native company enrollment/role context; Supabase `company_memberships` exists | Session-only gating; no role/verification in `AuthState` | Role, verification, company scope in state and router guards | `auth_state.dart`; both routers; live table `company_memberships` | C | Derive role/company/verification from DB/JWT; add route guards; keep RLS authoritative | RLS, auth metadata, membership RPCs |
| G17 | Native private document bucket and queued uploads | Public URL used in private bucket | Short-lived signed URLs; document queue; owner-only paths | `onboarding_service.dart:24-33`; `environment_config.dart:27-30` | C | Store object path; mint signed URL; add Storage policies and cleanup | Storage policy verification, RLS, signed URL API |
| G18 | Native Transporter accounting/ERP: COA, journals, invoices, bills, profitability | Missing | Entire accounting domain/service/UI | Transporter APK `AccountingScreen`, `TransporterSyncWorker` | H | Port ERP after core loop; include COA blocking and journal idempotency | Accounting schema, RPCs, product decision |
| G19 | Native Review/POD settlement with biometric authorisation | Biometric service exists but unused; no review UI | Review queue, POD approval, biometric re-auth, settlement audit | Transporter APK `ReviewScreen`; `biometric_service.dart` | H | Wire biometric into settlement RPC call with audit trail | Transactions, role gating, RLS, platform config |
| G20 | Native Driver local tracking notification | Notification dependency only | Notification channel and ongoing tracking notification | Driver APK `EASYFLEET_TRACKING`; `apps/driver/pubspec.yaml:18` | H | Implement foreground notification as part of phone location source | Android FGS config, plugin choice |
| G21 | Remote push not observed in native apps | No push dependency | Confirm requirement; do not assume FCM parity | Bounded native searches returned no FirebaseMessaging/MessagingService | L | Product decision; add FCM only if required | Product decision, backend notification config |
| G22 | Native package IDs `com.easyfleet.driver` / `com.easyfleet.transporter` | Android IDs correct; iOS bundle IDs are `com.easyfleet.easyfleetDriver` / `...Transporter` | Correct iOS bundle IDs before any App Store build | `apps/*/ios/Runner.xcodeproj/project.pbxproj:386,567,589` | H | Update iOS product bundle identifiers to preserve native identities | Apple developer account, provisioning profiles |
| G23 | Release apps must not be debuggable | Both Android release configs sign with debug | Release signing config and prod manifest hardening | `apps/*/android/app/build.gradle.kts:33-39` | H | Configure release keystore, minify/shrink policy, non-debuggable manifests | Keystore, CI secrets |
| G24 | iOS background location and biometric usage strings | Missing from both Info.plist files | Location/FaceID usage descriptions and background modes where needed | `apps/*/ios/Runner/Info.plist` | H | Add required keys for Driver location and Transporter biometrics | Platform review, Apple privacy strings |
| G25 | Driver manifest has location/FGS permissions; transporter does not | Maps widgets enable my-location in both | Align permissions with actual features; remove unsupported my-location or add transporter location flow | Driver manifest `:2-10`; transporter manifest `:1-11`; `live_fleet_map.dart:55` | M | Decide transporter my-location requirement and align manifests/dependencies | Product decision, OS permissions |
| G26 | Supabase config should be explicit and fail fast | Production URL default; empty key accepted; invalid flavor → prod | Fail-fast validation; publishableKey migration | `environment_config.dart:16-35`; both `main.dart` | H | Validate non-empty config; remove silent prod fallback; use `publishableKey` | Build/CI configuration |
| G27 | Snake_case Supabase rows vs camelCase models | Generated parsers expect camelCase | Model annotations or row normalization | `*.g.dart`; all network services | C | Add `@JsonKey(name: 'snake_case')` or build config `field_rename: snake`; add mapping tests | Codegen config, tests |
| G28 | RLS/policies/triggers/functions expected by Flutter | Unverified; no migrations in repo | Verified control-plane metadata and negative tests | Live probes; no SQL files; `PROGRESS-REPORT.md:996` | C | Obtain read-only DB key, verify catalog, then implement approved policies/RPCs | Owner credential, schema decision |
| G29 | Realtime required for assignments/events/positions/breadcrumbs | Streams implemented; publication unverified; 3 tables absent | Publication membership, SELECT policies, replica identity, initial fetch | Four `.stream(...)` call sites; live probes | C | Add tables to publication (after approval), test RLS, add initial load | Schema, RLS, Realtime config |
| G30 | Native permissions/roles/company scope shape UI | `hasPermission` unused; no gating | Wire permission/role provider or replace with DB-derived state | `permissions_service.dart:7-25`; interceptors `:71-84` | H | Use DB/JWT-derived claims; client helper only for UX | Auth design, RLS |
| G31 | Native offline app has real tests? Not established | Two trivial smoke tests only | Unit/widget/integration tests for core loop and schema assumptions | `apps/*/test/smoke_test.dart` | H | Add mapping, transition, sync, onboarding, jobs, appointment, GPS tests | Test environment, staging Supabase |
| G32 | GPS history is sensitive data | No privacy/consent lifecycle in Flutter | Consent, retention TTL, access audit, precision controls | GPS audit §6 | H | Implement privacy controls with tracking session and retention policy | Product/legal decision, schema |
| G33 | Vendor credentials must not be in apps | No vendor integration exists | Server-side secret vault and webhook signature validation | GPS architecture §20.4 | H | Use gateway service role scoped to position ingest | Vendor decision, infrastructure |

---

## 23. Severity summary

| Severity | Count | Meaning |
|---|---:|---|
| Critical | 16 | Blocks core product or exposes customer data |
| High | 15 | Major parity/security/operational defect |
| Medium | 1 | Significant robustness issue |
| Low | 1 | Cleanup/product decision |

The audit found no area where Phase 1A can begin safely without backend/schema decisions.

---

## 24. Phase 1A entry criteria — recommendation

Do not implement until the following are reviewed and approved:

1. **Schema strategy**
   - Confirm whether existing `companies`, `company_memberships`, `fleet_trips`, `fleet_vehicles`, `trip_location_breadcrumbs` are canonical.
   - Decide whether to add new Phase 1A tables or migrate Flutter to existing names/columns.

2. **Control-plane verification**
   - Obtain a read-only database/service key.
   - Verify constraints, indexes, RLS policies, triggers, functions, storage policies, and realtime publication.

3. **Serialization contract**
   - Add snake_case JSON mapping and tests before wiring any UI.

4. **Backend transaction boundary**
   - Approve RPC list: account creation, company registration, apply, appoint, stage transition, document submit, position ingest.
   - Remove or strictly harden generic `delete_row`.

5. **Storage security**
   - Replace public URLs with signed URLs.
   - Define Storage policies and owner-only object paths.

6. **Auth/roles**
   - Add role, company, and verification to `AuthState` from trusted DB/JWT state.
   - Add router guards; keep RLS authoritative.

7. **Platform identity**
   - Correct iOS bundle IDs.
   - Configure release signing.
   - Add iOS usage descriptions and platform-specific permissions.
   - Publish `assetlinks.json` if Driver app links remain required.

8. **GPS architecture**
   - Approve canonical `position_events`/`vehicle_positions` model.
   - Decide vendor feed mechanism.
   - Implement phone source, offline outbox, and ingest RPC before map UI.

9. **Testing**
   - Add tests for every transactional/security control before feature UI is considered complete.

---

## 25. Open questions for owner review

1. Are the existing `fleet_*` and `companies` tables authoritative, or should new Phase 1A tables be added?
2. Can the owner provide a read-only database/service key for catalog verification?
3. Who performs DL/GST manual approval — EasyFleet back office, transporter admin, or both?
4. Which truck GPS vendor/API format is authoritative?
5. Is remote push required, given no push implementation was observed in the native APKs?
6. Should the Flutter Transporter app preserve the full native accounting/ERP scope in Phase 1, or is core hiring/dispatch/tracking first?
7. What are the correct production iOS bundle IDs and signing/provisioning details?
8. Should the current public-URL document contract be considered a defect to fix before Phase 1A, or is a different Storage policy intended?

---

## 26. Final statement

The Flutter repository has the correct high-level monorepo architecture and a useful foundation, but the native apps carry the actual product logic. The live Supabase schema, Flutter service assumptions, and native data model are not yet aligned.

**No implementation was started.** This report is the baseline for review and approval. Phase 1A should begin only after the decisions and entry criteria in sections 24–25 are approved.
