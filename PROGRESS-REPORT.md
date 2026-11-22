# EasyFleet Driver & EasyFleet Transporter — Flutter Migration Progress Report

**Report date:** 22 November 2026  
**Workspace:** `/home/ubuntu/easyfleet-flutter`  
**Status:** Phase 0 foundation complete; Phase 1 core-loop models/services/routes scaffolded  
**Repository state:** No Git repository is initialised in `/home/ubuntu`, so there are no commit hashes. All work described here is present in the local filesystem.

---

## 1. Executive summary

The work so far has moved the two EasyFleet Android apps toward a shared Flutter monorepo while keeping the existing Supabase backend as the source of truth.

Two findings shaped the work:

1. **WonderMove was treated as a reference, not a backend to copy.** It is a Flutter fleet-operations app with useful patterns for Riverpod, GoRouter, Dio, Freezed, permissions, connectivity, and one-shot location capture. Its Kratos/Ory auth, API URLs, tenants, and branding were deliberately excluded.
2. **The real core product is a driver–transporter marketplace**, not generic fleet ERP. The user clarified that the essential loop is: DL-based driver identity → GST-based transporter identity → job market → appointment → synced trip lifecycle → phone/truck GPS tracking. This has been promoted to the highest priority in the planning document and reflected in the scaffold.

At present, the monorepo contains two app shells and seven shared packages. It compiles cleanly under Flutter static analysis, both smoke tests pass, and the core-loop domain models and Supabase service contracts exist. The UI feature screens are still placeholders; they have navigational routes but are not yet implemented.

---

## 2. Product concept captured

The clarified product model is now recorded in:

- `/home/ubuntu/REA-APK-Analysis/WonderMove-Adoption-Matrix.md`
- `/home/ubuntu/easyfleet-flutter/README.md`

### 2.1 Core loop

1. **Driver identity**
   - Sign-up uses a globally unique Driving Licence number.
   - Driver declares licence class and experience by vehicle category:
     - bulker
     - oil tanker
     - open truck
     - trailer
     - LMC cab
     - container
     - tipper
     - flatbed
   - DL document is uploaded for manual approval.

2. **Transporter identity**
   - Sign-up uses a globally unique company GSTIN.
   - Transporter provides legal name and GST certificate.
   - GST document is uploaded for manual approval.

3. **Job market**
   - Transporter posts jobs.
   - Jobs specify licence class, vehicle experience, location, pay, and description.
   - Drivers search/filter jobs and apply.

4. **Find and appoint**
   - Transporter reviews applicants.
   - Transporter appoints a driver.
   - Supabase Realtime mirrors the appointment into both apps.

5. **Trip lifecycle**
   - Assignment activates GPS consent and trip operations.
   - Stages implemented as a state machine:
     `assigned → reporting → loading → transit → unloading → podPending → completed`
   - Cancellation is allowed from intermediate stages.
   - Every stage transition writes an immutable `trip_events` row.

6. **GPS tracking**
   - Driver phone breadcrumbs continue from the existing EasyFleet native design.
   - Transporter can bind truck GPS devices by IMEI.
   - Phone breadcrumbs and truck-device positions are intended to feed the same live map.

7. **Fleet ERP**
   - Inspections, fuel, loading receipts, unload, payouts, wallet, accounting, alerts, exceptions, invoicing, and documents remain part of the broader product but are supporting functionality after the core loop.

---

## 3. Reverse engineering and discovery completed

The following analysis artefacts were produced before the Flutter scaffold:

| Artefact | Path / tool | Purpose |
|---|---|---|
| WonderMove adoption matrix | `/home/ubuntu/REA-APK-Analysis/WonderMove-Adoption-Matrix.md` | Final capability matrix, priorities, decisions, sequencing |
| REA evidence bundle | `/home/ubuntu/REA-APK-Analysis/rea-evidence-bundle.json` | 19 retained evidence records from static APK analysis |
| WonderMove APK | Static REA + Dart AOT inspection | Identified Flutter structure and feature areas |
| EasyFleet Driver APK | Static REA + JADX | Identified package name, Supabase usage, live-tracking service |
| EasyFleet Transporter APK | Static REA + JADX | Identified package name and transporter-side structure |

### 3.1 Key discoveries

- WonderMove is Flutter `com.wonderwhy.wondermove`, version `1.0.99`, Dart `3.13.3`.
- It has 529 first-party Dart source URIs across roughly 36 feature areas.
- It uses Riverpod, GoRouter, Dio, Freezed, geolocator, secure storage, and biometrics/passkeys.
- It has **no map SDK** and no continuous live-tracking implementation in the complete package URI inventory.
- EasyFleet Driver already has a stronger breadcrumb pipeline:
  - 100 ms initial request cadence
  - 15 s updates
  - 10 s minimum interval
  - notification channel `EASYFLEET_TRACKING`
  - local Room outbox `driver_outbox`
  - sync to Supabase `trip_location_breadcrumbs`
- Existing native package identities:
  - Driver: `com.easyfleet.driver`
  - Transporter: `com.easyfleet.transporter`
- Supabase project observed:
  - `https://iktekjnisqmbjtoictnc.supabase.co`
  - private storage bucket: `easyfleet-private-documents`

### 3.2 Limitations of the analysis

- APK analysis was static only; apps were not executed.
- Dart AOT string/identifier observations are lower bounds and do not expose method bodies.
- API paths observed in WonderMove are string literals, not proof of runtime calls.
- No mapping file was supplied.

---

## 4. Decisions made

| Decision | Outcome |
|---|---|
| App architecture | Flutter monorepo using Dart pub workspaces, not Melos |
| Apps | Two Flutter apps: Driver and Transporter |
| Backend | Existing EasyFleet Supabase project remains authoritative |
| WonderMove usage | Product/architecture reference only; no Kratos/Ory, no WonderMove URLs, no WonderMove brand/tenant data |
| State management | Riverpod |
| Navigation | GoRouter |
| Models | Freezed + json_serializable |
| HTTP/network | Dio plus Supabase Flutter SDK for Auth/Realtime/Storage |
| Local persistence | sqflite outbox for offline queueing |
| Maps | `google_maps_flutter` currently wired into shared maps package |
| Locales | All seven: `en`, `es`, `hi`, `kn`, `ml`, `ta`, `te` |
| DL/GST verification | Document upload + manual approval |
| GPS sources | Both phone breadcrumbs and transporter-bound truck GPS devices |
| Priority | Core marketplace loop is P0; generic fleet ERP is P1/P2 |
| Deferred | Assistant/charts and OCR invoice workflows are Phase 3 only |

---

## 5. Monorepo structure created

Root path: `/home/ubuntu/easyfleet-flutter`

```text
easyfleet-flutter/
├── apps/
│   ├── driver/
│   └── transporter/
├── packages/
│   ├── core/
│   ├── auth/
│   ├── network/
│   ├── domain/
│   ├── ui/
│   ├── sync/
│   └── maps/
├── scripts/
│   ├── codegen.sh
│   └── verify.sh
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

### 5.1 Root workspace

The root `pubspec.yaml` declares a Dart pub workspace containing:

```text
apps/driver
apps/transporter
packages/core
packages/auth
packages/network
packages/domain
packages/ui
packages/sync
packages/maps
```

Every member package and app contains:

```yaml
resolution: workspace
```

This was required after the initial `flutter pub get` error about workspace membership.

---

## 6. Toolchain installed

Flutter and Dart were installed under:

```text
/tmp/opencode/flutter-sdk/flutter/bin/flutter
```

Installed versions:

- Flutter `3.50.1`
- Dart `3.14.0`

Analytics was disabled.

---

## 7. Shared packages implemented

### 7.1 `packages/core`

Purpose: configuration, routes, theme, deep links, localization.

Key files:

```text
packages/core/lib/easyfleet_core.dart
packages/core/lib/src/config/environment_config.dart
packages/core/lib/src/router/app_routes.dart
packages/core/lib/src/deep_links/deep_links.dart
packages/core/lib/src/theme/app_theme.dart
packages/core/l10n.yaml
packages/core/lib/src/l10n/app_en.arb
packages/core/lib/src/l10n/app_es.arb
packages/core/lib/src/l10n/app_hi.arb
packages/core/lib/src/l10n/app_kn.arb
packages/core/lib/src/l10n/app_ml.arb
packages/core/lib/src/l10n/app_ta.arb
packages/core/lib/src/l10n/app_te.arb
packages/core/lib/src/l10n/generated/app_localizations*.dart
```

Implemented:

- `EnvironmentConfig` reading build-time defines:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - storage bucket configuration
  - flavour support: dev/staging/prod
- Shared route catalogue including:
  - splash/login/home/settings
  - driver profile and transporter company profile
  - jobs and job detail
  - applications and candidates
  - assignments
  - GPS devices
  - trips, live tracking, fleet map, vehicle status, accounting
- Deep-link parser for `https://app.easyfleet.in/trip/{id}`
- Light and dark Flutter themes
- ARB files and generated localizations for seven locales

Notes:

- `flutter gen-l10n` required `flutter: generate: true` in `packages/core/pubspec.yaml`.
- The deprecated `synthetic-package` setting was removed from `l10n.yaml`.

---

### 7.2 `packages/auth`

Purpose: Supabase Auth session, biometric unlock, permissions, onboarding state, shared login UI.

Key files:

```text
packages/auth/lib/easyfleet_auth.dart
packages/auth/lib/src/auth_controller.dart
packages/auth/lib/src/auth_state.dart
packages/auth/lib/src/biometric_service.dart
packages/auth/lib/src/permissions_service.dart
packages/auth/lib/src/onboarding_controller.dart
packages/auth/lib/src/ui/login_screen.dart
```

Implemented:

- `AuthController` as a Riverpod notifier.
- Supabase auth state listener.
- Generic email/password login screen.
- Biometric unlock service using `local_auth` and `flutter_secure_storage`.
- Permissions service.
- `OnboardingController` with:
  - `OnboardingRole.driver`
  - `OnboardingRole.transporter`
  - `VerificationStatus`
  - DL submission call
  - GST submission call
  - verification status refresh

Important limitation:

- There are no full DL/GST onboarding screens yet. The controller and service contract exist; the UI still needs to be built.

Fixes applied:

- Supabase `AuthState` conflict was resolved with a `hide AuthState` import.
- Auth-state subscription changed from `ref.listen` on the stream to an explicit `listen` plus `ref.onDispose(subscription.cancel)`.
- `local_auth` v3 API usage updated to `authenticate(... biometricOnly: ..., persistAcrossBackgrounding: ...)`.
- `FlutterSecureStorage` constructor updated for v11.

---

### 7.3 `packages/network`

Purpose: Dio client, Supabase REST/RPC helpers, interceptors, and Phase 1 core service contracts.

Key files:

```text
packages/network/lib/easyfleet_network.dart
packages/network/lib/src/api_endpoints.dart
packages/network/lib/src/connectivity_service.dart
packages/network/lib/src/dio_client.dart
packages/network/lib/src/interceptors.dart
packages/network/lib/src/supabase_data_source.dart
packages/network/lib/src/supabase_tables.dart
packages/network/lib/src/onboarding_service.dart
packages/network/lib/src/marketplace_service.dart
packages/network/lib/src/gps_device_service.dart
packages/network/lib/src/trip_lifecycle_service.dart
```

Implemented earlier:

- Dio client.
- Auth/trace/connectivity/permission/forbidden interceptors.
- Supabase REST/RPC wrapper.
- Connectivity service.

Added for the core loop:

#### `SupabaseTables`

Constants for:

```text
driver_profiles
transporter_companies
job_postings
job_applications
assignments
gps_devices
gps_positions
trips
trip_events
trip_location_breadcrumbs
user_permissions
```

#### `OnboardingService`

- Uploads DL/GST documents to private Supabase Storage.
- Writes `driver_profiles` with:
  - `dl_number`
  - `license_class`
  - `dl_document_url`
  - `dl_verification = pending`
- Writes `transporter_companies` with:
  - `gst`
  - `legal_name`
  - `gst_document_url`
  - `gst_verification = pending`
- Reads verification status.

Implementation detail: document bytes are `Uint8List`, matching the Supabase Storage API.

#### `MarketplaceService`

- `searchJobs(...)` filters by:
  - licence classes using Supabase `overlaps`
  - vehicle category
  - pickup location using `ilike`
- `postJob(...)` writes a job posting.
- `applyToJob(...)` writes an application with experience snapshot.
- `applicantsForJob(...)` lists applicants.
- `applicationsForDriver(...)` lists driver applications.
- `appointDriver(...)`:
  - inserts an `assignments` row
  - updates `job_applications.status` to `appointed`
  - sets `assignment_id`
- `watchAssignments(userId)` streams assignment rows from Supabase Realtime and filters for either `driver_id` or `transporter_id`.

Note: Supabase stream filter builder did not provide an `or` filter, so the stream is narrowed in Dart after applying RLS.

#### `GpsDeviceService`

- Lists devices for a transporter.
- Binds a device by IMEI with `onConflict: 'imei'`.
- Streams `gps_positions`.
- Streams phone breadcrumbs from `trip_location_breadcrumbs`.

These two streams are intended to be merged into `LiveFleetMap`.

#### `TripLifecycleService`

- Defines allowed transitions:

```text
assigned    → reporting | cancelled
reporting   → loading   | cancelled
loading     → transit   | cancelled
transit     → unloading | cancelled
unloading   → podPending| cancelled
podPending  → completed | cancelled
```

- `canAdvance(...)` validates transitions.
- `advance(...)`:
  - inserts a `trip_events` row
  - updates `trips.stage`
- `watchEvents(tripId)` streams trip events.

---

### 7.4 `packages/domain`

Purpose: pure Freezed models shared by both apps.

Key files:

```text
packages/domain/lib/easyfleet_domain.dart
packages/domain/lib/src/enums.dart
packages/domain/lib/src/models/*.dart
packages/domain/lib/src/models/*.freezed.dart
packages/domain/lib/src/models/*.g.dart
```

Original models:

- `LocationPoint`
- `LocationBreadcrumb`
- `Trip`
- `VehiclePosition`
- `DriverProfile`
- `Inspection`
- `Payout`
- `AlertItem`

Core-loop additions:

| Model | Important fields |
|---|---|
| `DriverProfile` | `dlNumber`, `licenseClass`, `experienceByVehicle`, `dlVerification`, `dlDocumentUrl`, `transporterId`, `currentAssignmentId` |
| `TransporterCompany` | `gst`, `legalName`, `tradeName`, `gstVerification`, `gstDocumentUrl` |
| `JobPosting` | `transporterId`, `requiredLicenseClasses`, `requiredExperience`, `vehicleCategory`, pay/location fields, `status` |
| `JobApplication` | `jobId`, `driverId`, `status`, `experienceSnapshot`, `assignmentId` |
| `Assignment` | `driverId`, `transporterId`, `jobId`, `applicationId`, `status`, `appointedAt` |
| `GpsDevice` | `imei`, `transporterId`, `vehicleNumber`, `simNumber`, `status`, last known position |
| `TripEvent` | `tripId`, `stage`, `occurredAt`, `actorId`, `note`, latitude/longitude |

New enums:

```text
LicenseClass
VehicleCategory
VerificationStatus
JobStatus
ApplicationStatus
AssignmentStatus
GpsDeviceStatus
TripStage
```

`Trip` was changed:

- Removed the old flat `TripStatus`.
- Added `TripStage stage`.
- Added `transporterId`, `assignmentId`, and `gpsDeviceId`.

Code generation:

```bash
cd packages/domain
dart run build_runner build
```

This generated 24 Freezed/JSON outputs for 15 hand-written domain model/enum files.

---

### 7.5 `packages/ui`

Purpose: shared design-system widgets.

Key files:

```text
packages/ui/lib/easyfleet_ui.dart
packages/ui/lib/src/widgets/app_scaffold.dart
packages/ui/lib/src/widgets/connectivity_gate.dart
packages/ui/lib/src/widgets/date_range_field.dart
packages/ui/lib/src/widgets/empty_view.dart
packages/ui/lib/src/widgets/error_view.dart
packages/ui/lib/src/widgets/force_update_gate.dart
packages/ui/lib/src/widgets/loading_view.dart
packages/ui/lib/src/widgets/searchable_dropdown.dart
packages/ui/lib/src/widgets/section_header.dart
packages/ui/lib/src/widgets/splash_screen.dart
```

Implemented:

- Common app scaffold.
- Loading, error, and empty states.
- Connectivity gate.
- Force-update gate.
- Date range field.
- Searchable dropdown.
- Section header.
- Splash screen.

Fixes applied:

- Searchable dropdown null item type was corrected.
- `SectionHeader` conditional widget construction was made null-safe with `?action`.

---

### 7.6 `packages/sync`

Purpose: offline outbox and breadcrumb queue.

Key files:

```text
packages/sync/lib/easyfleet_sync.dart
packages/sync/lib/src/outbox_entry.dart
packages/sync/lib/src/outbox_repository.dart
packages/sync/lib/src/sync_service.dart
```

Implemented:

- sqflite database `easyfleet_sync.db`.
- `outbox` table with:
  - `table_name`
  - `operation`
  - `payload`
  - `idempotency_key`
  - `created_at`
  - `attempts`
  - `status`
  - `last_error`
- `location_breadcrumbs` table with:
  - `trip_id`
  - latitude/longitude
  - accuracy
  - `recorded_at`
  - `idempotency_key`
  - `sync_state`
- `OutboxRepository` methods:
  - `enqueue`
  - `pending`
  - `markSynced`
  - `markFailed`
  - `deleteSynced`
- `SyncService` flushes pending entries through `SupabaseDataSource` when online.

Fixes applied:

- Added missing `dio` dependency because the sync service uses `SupabaseDataSource`.
- Missing `outbox_entry.dart` import added to `sync_service.dart`.
- Constructor simplified to positional parameters to satisfy lints.

---

### 7.7 `packages/maps`

Purpose: live map widgets using `google_maps_flutter`.

Key files:

```text
packages/maps/lib/easyfleet_maps.dart
packages/maps/lib/src/live_fleet_map.dart
packages/maps/lib/src/trip_route_map.dart
```

Implemented:

#### `LiveFleetMap`

- Accepts `Stream<List<VehiclePosition>>`.
- Renders vehicle markers.
- Uses vehicle number as marker title.
- Uses trip ID or “No active trip” as snippet.
- Uses marker rotation for heading.
- Enables my-location layer.

#### `TripRouteMap`

- Accepts breadcrumb stream, current-position stream, and optional ETA.
- Draws trip trail as a `Polyline`.
- Shows current-position marker.
- Shows ETA card when supplied.

Current limitation:

- These widgets are built but are not yet rendered by the app shell screens.
- They are not yet connected to the new `GpsDeviceService` streams.

---

## 8. Apps implemented

### 8.1 Driver app

Path: `/home/ubuntu/easyfleet-flutter/apps/driver`

Key files:

```text
apps/driver/lib/main.dart
apps/driver/lib/app.dart
apps/driver/lib/src/router/app_router.dart
apps/driver/lib/src/features/placeholder_screen.dart
apps/driver/test/smoke_test.dart
apps/driver/pubspec.yaml
```

Implemented:

- `main.dart`
  - `WidgetsFlutterBinding.ensureInitialized()`
  - reads `EnvironmentConfig`
  - calls `Supabase.initialize(...)`
  - runs `ProviderScope(child: DriverApp())`
- `DriverApp`
  - `MaterialApp.router`
  - shared light/dark theme
  - GoRouter config
  - seven locale delegates and supported locales
- Router
  - splash
  - login
  - shell with bottom navigation
  - routes:
    - home
    - jobs and job detail
    - my applications
    - assignments
    - driver DL profile
    - trips
    - live tracking
    - settings
- Bottom navigation:
  - Home
  - Jobs
  - Trips
  - Map
  - Settings

Current UI status:

- All feature destinations render `PlaceholderScreen`, which explains that implementation follows the adoption matrix.

### 8.2 Transporter app

Path: `/home/ubuntu/easyfleet-flutter/apps/transporter`

Key files:

```text
apps/transporter/lib/main.dart
apps/transporter/lib/app.dart
apps/transporter/lib/src/router/app_router.dart
apps/transporter/lib/src/features/placeholder_screen.dart
apps/transporter/test/smoke_test.dart
apps/transporter/pubspec.yaml
```

Implemented:

- Same Supabase initialization and MaterialApp.router wiring as Driver.
- Router routes:
  - home
  - candidates / find drivers
  - appointments
  - GPS devices
  - GST profile
  - fleet map
  - vehicle status
  - accounting
  - settings
- Bottom navigation:
  - Home
  - Hire
  - Drivers
  - Map
  - Settings

Current UI status:

- All feature destinations render `PlaceholderScreen`.

---

## 9. Native platform configuration

### 9.1 Android application IDs

Preserved from the original native apps:

```text
Driver:      com.easyfleet.driver
Transporter: com.easyfleet.transporter
```

Changed in:

```text
apps/driver/android/app/build.gradle.kts
apps/transporter/android/app/build.gradle.kts
apps/driver/android/app/src/main/kotlin/com/easyfleet/driver/MainActivity.kt
apps/transporter/android/app/src/main/kotlin/com/easyfleet/transporter/MainActivity.kt
apps/driver/ios/Runner.xcodeproj/project.pbxproj
apps/transporter/ios/Runner.xcodeproj/project.pbxproj
```

### 9.2 Android manifests

Driver manifest now includes:

- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_LOCATION`
- `POST_NOTIFICATIONS`
- `WAKE_LOCK`
- `RECEIVE_BOOT_COMPLETED`
- app link intent filter for:

```text
https://app.easyfleet.in/trip/
```

- Google Maps API key metadata placeholder:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}"/>
```

Transporter manifest includes:

- network, notification, media, biometric, wake-lock, boot, foreground-service permissions
- Google Maps metadata placeholder

Both app Gradle files set:

```kotlin
minSdk = 29
manifestPlaceholders["MAPS_API_KEY"] =
    project.findProperty("mapsApiKey")?.toString() ?: ""
```

### 9.3 Remaining native publication requirements

- Publish `assetlinks.json` at `app.easyfleet.in` for Android App Links verification.
- Add `mapsApiKey=<key>` to each app’s `android/gradle.properties`.
- Configure iOS location/biometric usage descriptions where required.
- Run native builds once an Android SDK or macOS/iOS toolchain is available.

---

## 10. Dependency versions resolved

Important package versions from the workspace:

```text
flutter_riverpod      3.5.0
go_router             18.1.4
supabase_flutter      2.18.3
dio                   5.11.1
freezed               4.0.3
freezed_annotation    3.1.0
json_serializable     6.15.2
build_runner          2.17.1
google_maps_flutter   2.19.0
geolocator            14.1.2
permission_handler    13.0.2
flutter_secure_storage 11.2.0
local_auth            3.0.2
connectivity_plus     6.1.5
sqflite               2.4.6
in_app_update         5.0.0
```

`connectivity_plus` was reduced from `^7.3.2` to `^6.1.5` because `7.x` pulls `nm ^0.6.0`/`dbus ^0.8`, which conflicts with `geolocator_linux` requiring `dbus ^0.7.3`.

---

## 11. Issues encountered and fixed

| Issue | Fix |
|---|---|
| `flutter create` from repo root failed with workspace error | Avoided root `flutter create`; platform folders were generated in `/tmp/opencode/ef-scaffold` and copied into apps |
| Workspace members missing `resolution: workspace` | Added `resolution: workspace` to all apps/packages |
| `connectivity_plus 7.x` conflicted with `geolocator_linux` through `dbus` | Downgraded to `connectivity_plus ^6.1.5` |
| Barrel files named `core.dart`, `auth.dart`, etc. did not match package imports | Renamed all barrels to `easyfleet_<package>.dart` |
| Supabase `AuthState` name conflict with app `AuthState` | Imported Supabase with `hide AuthState` |
| Supabase auth stream `ref.listen` typing problem | Switched to explicit `listen` with `ref.onDispose` |
| `local_auth` v3 API changes | Updated `authenticate` arguments |
| `FlutterSecureStorage` v11 API changes | Updated constructor and removed obsolete Android options |
| `List<int>` not assignable to `Uint8List` in Supabase Storage | Changed onboarding/controller document bytes to `Uint8List` |
| Supabase Realtime stream builder had no `.or(...)` | Filtered assignment rows in Dart after RLS |
| `SupabaseDataSource` assumed `response.data` was a map | Normalized both `List` and `{ items: [...] }` shapes |
| Missing `dio` dependency in `sync` | Added `dio` to `packages/sync/pubspec.yaml` |
| Missing `easyfleet_domain` dependency in `auth` and `network` | Added explicit path dependencies |
| Freezed generation needed after new models | Ran `dart run build_runner build` in `packages/domain` |
| Relative imports in smoke tests triggered lint | Changed to `package:easyfleet_driver/app.dart` and `package:easyfleet_transporter/app.dart` |
| Flutter 3.50 deprecation warnings for `material.dart` | Ignored globally in `analysis_options.yaml` pending intentional migration |

---

## 12. Scripts and documentation added

### 12.1 `scripts/codegen.sh`

Runs:

```bash
flutter pub get
(cd packages/core && flutter gen-l10n)
(cd packages/domain && dart run build_runner build)
```

### 12.2 `scripts/verify.sh`

Runs:

```bash
flutter analyze
(cd apps/driver && flutter test)
(cd apps/transporter && flutter test)
```

### 12.3 README updates

`/home/ubuntu/easyfleet-flutter/README.md` now documents:

- monorepo layout
- core product loop
- setup commands
- runtime configuration
- Google Maps key setup
- preserved Android application IDs
- app-link requirement
- package dependency direction
- required Supabase tables for Phase 1

---

## 13. Verification performed

### 13.1 Static analysis

Command:

```bash
export PATH=/tmp/opencode/flutter-sdk/flutter/bin:$PATH
flutter analyze
```

Latest result:

```text
No issues found!
```

### 13.2 Smoke tests

Driver:

```text
00:00 +0: loading .../apps/driver/test/smoke_test.dart
00:00 +0: driver app compiles and deep links parse
00:00 +1: All tests passed!
```

Transporter:

```text
00:00 +0: loading .../apps/transporter/test/smoke_test.dart
00:00 +0: transporter app compiles and shared routes resolve
00:00 +1: All tests passed!
```

Full verify script result:

```text
Analyzing easyfleet-flutter...
No issues found!
...
All tests passed!
Verification complete.
```

### 13.3 Native build status

A native Android build was attempted indirectly via `flutter build bundle`, but it failed because this environment has no Android SDK:

```text
Target build_hooks failed: Error: Android SDK could not be found.
```

Therefore:

- Dart compilation: verified
- Static analysis: verified
- Smoke tests: verified
- APK/IPA build: not performed

---

## 14. What is implemented vs not implemented

### Implemented

- Flutter monorepo and workspace configuration
- Two app entrypoints and router shells
- Supabase initialization
- Shared theme and seven-locale l10n
- Login screen and auth controller
- Biometric and permission services
- Deep-link parser and Android intent filter
- Shared UI primitives
- Offline outbox database
- Freezed domain models for ERP and core-loop entities
- Trip lifecycle state machine service
- DL/GST onboarding service contract
- Job market service contract
- Appointment/Realtime service contract
- GPS device binding/stream service contract
- Live map and trip map widgets
- Android/iOS package identifiers
- Verification scripts

### Not yet implemented

- Full DL onboarding UI
- Full GST onboarding UI
- Document picker/camera and upload UX
- Job posting form
- Job search/filter list UI
- Job detail and apply UI
- Applicant shortlist/appoint UI
- Appointed driver dashboard UI
- GPS permission flow tied to appointment
- Continuous 15 s background breadcrumb service in Flutter
- Truck-device position merge into map UI
- Trip stage control screens
- Inspections/LR/unload/fuel/wallet/payout/accounting screens
- Alerts/exceptions UI
- Force-update backend configuration
- Supabase schema, RLS policies, triggers, and indexes
- Native release builds and device testing

---

## 15. Supabase schema required next

The scaffold currently assumes these tables exist or will be added:

```text
driver_profiles
transporter_companies
job_postings
job_applications
assignments
gps_devices
gps_positions
trip_events
trips                         existing/expected
trip_location_breadcrumbs     existing/expected
user_permissions
```

Important constraints expected by the code:

- `driver_profiles.dl_number` unique
- `transporter_companies.gst` unique
- `gps_devices.imei` unique
- `job_postings.required_license_classes` array-compatible with Supabase `overlaps`
- `trip_events` append-only
- RLS restricting:
  - driver rows to that driver
  - transporter rows to that transporter/company
  - documents through policies compatible with private bucket access

No SQL migration file has been created yet.

---

## 16. Open questions

1. Are the existing Supabase tables authoritative, or is schema evolution allowed?
2. Who approves DL/GST documents:
   - EasyFleet back-office only?
   - transporter admin?
   - both?
3. What is the truck GPS feed format:
   - vendor HTTP API?
   - raw TCP/HTTP IMEI gateway?
   - SIM-based tracker platform?
4. Should job market search use plain Supabase filters now and full-text search later?
5. Which background-location plugin should own the 15 s breadcrumb loop on Android?
6. Should driver phone breadcrumbs and truck-device positions be merged server-side into a database view or client-side in `packages/maps`?

---

## 17. Recommended next steps

### Phase 1A — Supabase foundation

1. Create SQL migrations for the core tables.
2. Add unique constraints.
3. Add RLS policies for driver/transporter separation.
4. Add indexes for:
   - job search filters
   - assignments by driver/transporter
   - breadcrumbs by trip/time
   - GPS positions by transporter/time
   - trip events by trip/time

### Phase 1B — Identity onboarding

1. Build DL onboarding form.
2. Build GST onboarding form.
3. Add document picker/camera.
4. Wire upload + submit to `OnboardingService`.
5. Add approval-pending and rejected states.

### Phase 1C — Job market

1. Transporter job-posting form.
2. Driver job search/filter list.
3. Job detail screen.
4. Apply flow.
5. Applicant list for transporter.
6. Shortlist/appoint flow.

### Phase 1D — Assignment and lifecycle

1. Both-app assignment cards via Realtime.
2. GPS permission and consent step.
3. Trip stage controls.
4. Event history timeline.
5. Role-based allowed actions.

### Phase 1E — GPS and map

1. Implement Flutter background breadcrumb service.
2. Wire breadcrumbs to `TripRouteMap`.
3. Bind truck GPS devices.
4. Wire device positions and phone breadcrumbs to `LiveFleetMap`.
5. Add map API keys and test on physical devices.

### Phase 1F — Verification

1. Add unit tests for transition validation and service mapping.
2. Add widget tests for onboarding and job flows.
3. Add integration tests with a staging Supabase project.
4. Run debug builds on Android and iOS.

---

## 18. Important paths

| Item | Path |
|---|---|
| Flutter monorepo | `/home/ubuntu/easyfleet-flutter` |
| This report | `/home/ubuntu/easyfleet-flutter/PROGRESS-REPORT.md` |
| Project README | `/home/ubuntu/easyfleet-flutter/README.md` |
| Adoption matrix | `/home/ubuntu/REA-APK-Analysis/WonderMove-Adoption-Matrix.md` |
| REA evidence bundle | `/home/ubuntu/REA-APK-Analysis/rea-evidence-bundle.json` |
| Driver app | `/home/ubuntu/easyfleet-flutter/apps/driver` |
| Transporter app | `/home/ubuntu/easyfleet-flutter/apps/transporter` |
| Shared domain models | `/home/ubuntu/easyfleet-flutter/packages/domain/lib/src/models` |
| Supabase service contracts | `/home/ubuntu/easyfleet-flutter/packages/network/lib/src` |
| Code generation script | `/home/ubuntu/easyfleet-flutter/scripts/codegen.sh` |
| Verification script | `/home/ubuntu/easyfleet-flutter/scripts/verify.sh` |
| Flutter SDK | `/tmp/opencode/flutter-sdk/flutter/bin/flutter` |
| Temporary scaffold source | `/tmp/opencode/ef-scaffold` |

---

## 19. Current bottom line

The scaffold now reflects the correct product, not just the original generic fleet ERP interpretation. The two Flutter apps have a working shared foundation, the DL/GST/job/appointment/tracking concepts are represented in the domain and network layers, and the repository passes analysis and smoke tests. The next implementation work should be the Supabase schema and the actual onboarding/job-marketplace screens, followed by the assignment lifecycle and live GPS wiring.
