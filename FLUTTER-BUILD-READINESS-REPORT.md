# EasyFleet Flutter — Build Readiness Report

**Report date:** 22 November 2026  
**Phase:** Flutter Build Stabilization — baseline assessment only  
**Workspace:** `/home/ubuntu/easyfleet-flutter`  
**Scope:** Read-only baseline assessment, required Flutter commands, native-contract comparison, and implementation planning. No implementation was started.

---

## 1. Environment and toolchain versions

| Item | Verified value / result |
|---|---|
| Operating system | Ubuntu 24.04.5 LTS, kernel `7.0.0-1018-aws` |
| Flutter SDK | `/tmp/opencode/flutter-sdk/flutter` |
| Flutter version | `3.50.1`, channel `stable` |
| Framework revision | `ae9b586f34` |
| Engine revision | `4d35714800` |
| Dart SDK | `3.14.0` (stable) |
| DevTools | `2.61.0` |
| Java | OpenJDK `21.0.13.1` |
| Gradle wrapper | `9.5.0-all` (`apps/*/android/gradle/wrapper/gradle-wrapper.properties:5`) |
| Android SDK | **Not installed / not found** |
| `ANDROID_HOME` | unset |
| `ANDROID_SDK_ROOT` | unset |
| `JAVA_HOME` | unset |
| Local Android config | `apps/*/android/local.properties` contains only `flutter.sdk`; no `sdk.dir` |
| Connected devices | Linux desktop only; no Android device/emulator |

`flutter doctor -v` results relevant to this assessment:

```text
[✓] Flutter (Channel stable, 3.50.1, on Ubuntu 24.04.5 LTS ...)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome)
[✗] Linux toolchain - develop for Linux desktop
    ✗ clang++, CMake, ninja, pkg-config required
[✓] Connected device (1 available) • Linux (desktop) • linux • linux-x64
[✓] Network resources
! Doctor found issues in 3 categories.
```

Chrome and Linux-desktop toolchain gaps are **not** blockers for the requested Android builds. The Android SDK gap is a blocker.

---

## 2. Git working-tree status

There is **no Git repository** in the workspace or its parent:

```text
fatal: not a git repository (or any of the parent directories): .git
```

Verified with:

- `git -C /home/ubuntu/easyfleet-flutter status --short --branch`
- `git -C /home/ubuntu/easyfleet-flutter rev-parse --show-toplevel`
- `git -C /home/ubuntu rev-parse --show-toplevel`
- `find /home/ubuntu/easyfleet-flutter -maxdepth 2 -name .git`

A `.gitignore` file exists, but no `.git` directory exists. Therefore no branch, commit hash, staged/untracked diff, or Git working-tree status can be reported.

To compensate, a SHA-256 baseline of **266 source/config files** was captured before running commands and re-verified afterwards. All 266 files matched their baseline hashes. `pubspec.lock` specifically remained unchanged (`b2b80700…`). Ordinary generated artifacts under `build/`, `.dart_tool/`, and Flutter plugin metadata may have been refreshed by the commands; no source/config file changed.

---

## 3. Workspace, entry points, identities, and flavors

The workspace is a Dart pub workspace with two apps and seven shared packages:

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

| Item | Driver | Transporter |
|---|---|---|
| App package | `easyfleet_driver` | `easyfleet_transporter` |
| App entry point | `apps/driver/lib/main.dart:8-17` | `apps/transporter/lib/main.dart:8-17` |
| App widget | `DriverApp` (`apps/driver/lib/app.dart:7-23`) | `TransporterApp` (`apps/transporter/lib/app.dart:7-23`) |
| Android namespace | `com.easyfleet.driver` (`android/app/build.gradle.kts:8`) | `com.easyfleet.transporter` (`android/app/build.gradle.kts:8`) |
| Android application ID | `com.easyfleet.driver` (`android/app/build.gradle.kts:19`) | `com.easyfleet.transporter` (`android/app/build.gradle.kts:19`) |
| iOS product bundle ID | `com.easyfleet.easyfleetDriver` | `com.easyfleet.easyfleetTransporter` |
| Version | `1.0.0+1` | `1.0.0+1` |
| minSdk | `29` | `29` |
| Android product flavors | **None declared** | **None declared** |
| Build types | Default `debug` / `release`; release signs with debug | Default `debug` / `release`; release signs with debug |

No `productFlavors` or `flavorDimensions` were found in either `android/app/build.gradle.kts`. The `APP_FLAVOR` Dart define in `packages/core/lib/src/config/environment_config.dart:15-18` is an application-level flavour only; it does not create Android build variants.

The native Android application IDs documented in `NATIVE-BACKEND-CONTRACT-DISCOVERY.md` are preserved. iOS bundle IDs do not match those native package identities and remain a publication risk.

---

## 4. Driver and Transporter build status

### Commands run

| Command | Exit code | Result |
|---|---:|---|
| `flutter pub get` (workspace root) | 0 | Dependencies resolved; warning about newer incompatible versions |
| `flutter analyze` (workspace root) | 0 | `No issues found! (ran in 7.6s)` |
| `flutter test` (workspace root) | 1 | `Test directory "test" not found.` |
| `cd apps/driver && flutter test` | 0 | 1 smoke test passed |
| `cd apps/transporter && flutter test` | 0 | 1 smoke test passed |
| `cd apps/driver && flutter build apk --debug --no-pub` | 1 | No Android SDK found |
| `cd apps/transporter && flutter build apk --debug --no-pub` | 1 | No Android SDK found |
| `flutter pub outdated` | 0 | One direct dependency constrained below a resolvable version |
| `flutter doctor -v` | 0 | Android toolchain incomplete |

### Exact build output

Driver:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
BUILD_DRIVER_EXIT=1
```

Transporter:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
BUILD_TRANSPORTER_EXIT=1
```

**No APK was produced for either app.** The failure occurs before Android Gradle/Kotlin compilation, so it does not prove that the Android projects are otherwise build-ready. Dart compilation is partially evidenced by `flutter analyze` and the two smoke tests, but native packaging is unverified.

---

## 5. Analyze and test results

### `flutter pub get`

```text
Resolving dependencies...
Downloading packages...
  built_collection 5.1.2 (6.0.0 available)
  connectivity_plus 6.1.5 (7.3.2 available)
  dbus 0.7.15 (0.8.1 available)
  gsettings 0.2.8 (0.2.9 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  nm 0.5.0 (0.6.0 available)
  test_api 0.7.14 (0.7.15 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

This is a dependency-health warning, not a command failure. `pubspec.lock` was not modified.

### `flutter pub outdated`

```text
direct dependencies:
connectivity_plus         *6.1.5   *6.1.5      *7.3.1      7.3.2
transitive dependencies:
dbus                      *0.7.15  *0.7.15      *0.7.15     0.8.1
gsettings                 *0.2.8   *0.2.8       *0.2.8      0.2.9
material_color_utilities  *0.13.0  *0.13.0      *0.13.0     0.13.1
nm                        *0.5.0   *0.5.0       *0.5.0      0.6.0
test_api                  *0.7.14  *0.7.14      *0.7.14     0.7.15
transitive dev_dependencies:
built_collection          *5.1.2   *5.1.2       *5.1.2      6.0.0

1 dependency is constrained to a version that is older than a resolvable version.
```

`connectivity_plus` is pinned at `6.1.5`; the prior progress report documents that `7.x` conflicts with `geolocator_linux` through `dbus`. Any upgrade must be treated as a dependency-graph decision, not a routine bump.

### `flutter analyze`

```text
Analyzing easyfleet-flutter...
No issues found! (ran in 7.6s)
```

Important qualification: `analysis_options.yaml:4-7` excludes `*.g.dart`, `*.freezed.dart`, and generated l10n, and `analysis_options.yaml:9,12` ignores `invalid_annotation_target` and `deprecated_member_use`. The clean analysis result is therefore narrower than full-source verification.

### Tests

Root-level `flutter test` failed only because the workspace root has no `test/` directory:

```text
Test directory "test" not found.
TEST_ROOT_EXIT=1
```

Per-app tests passed:

```text
apps/driver:
00:00 +0: loading .../apps/driver/test/smoke_test.dart
00:00 +0: driver app compiles and deep links parse
00:00 +1: All tests passed!

apps/transporter:
00:00 +0: loading .../apps/transporter/test/smoke_test.dart
00:00 +0: transporter app compiles and shared routes resolve
00:00 +1: All tests passed!
```

The tests are constructor/constant/parser smoke tests only (`apps/driver/test/smoke_test.dart:5-12`, `apps/transporter/test/smoke_test.dart:5-9`). They do not validate business logic, serialization, backend behavior, or platform builds.

---

## 6. Exact blocking errors and source-level readiness defects

### 6.1 Command-level blockers

| ID | Severity | Command / path | Exact error or warning | Effect |
|---|---|---|---|---|
| B1 | **Blocker** | `flutter build apk --debug`, both apps | `[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.` | No APK produced |
| B2 | Low / invocation-only | `flutter test` at workspace root | `Test directory "test" not found.` | Root command fails; per-app tests pass |
| B3 | Warning | `flutter pub get` | `7 packages have newer versions incompatible with dependency constraints.` | Dependency drift; requires review |
| B4 | Warning | `flutter analyze` | No analyzer errors/warnings | Static analysis clean, but generated code excluded |
| B5 | Environment | `flutter doctor -v` | `✗ Unable to locate Android SDK.` | Confirms B1 |

### 6.2 Serialization blockers

| ID | Severity | Evidence | Defect |
|---|---|---|---|
| S1 | **Critical** | `packages/network/lib/src/marketplace_service.dart:41-57`, `61-71`, `74-89`, `101-119`; `packages/domain/lib/src/models/job_posting.g.dart:9-37`; `assignment.g.dart:9-21` | Services write/read snake_case columns (`transporter_id`, `required_license_classes`, `pay_per_trip`, `driver_id`, `appointed_at`) while generated `fromJson` readers expect camelCase (`transporterId`, `requiredLicenseClasses`, `payPerTrip`, `driverId`, `appointedAt`). |
| S2 | **Critical** | `packages/network/lib/src/marketplace_service.dart:135` | `_normalize()` only copies the map; it does not translate keys. |
| S3 | **Critical** | `packages/network/lib/src/onboarding_service.dart:41-62`; profile/company generated parsers | Profile and company writes use `dl_number`, `license_class`, `dl_document_url`, `gst`, `legal_name`; generated models expect camelCase equivalents. |
| S4 | **Critical** | `packages/network/lib/src/trip_lifecycle_service.dart:44-58`; `packages/domain/lib/src/models/trip.dart:11-27`; `trip.g.dart` | Event and trip payloads use `trip_id`, `occurred_at`, `stage`; generated parsers expect `tripId`, `occurredAt`, `stage`-adjacent camelCase fields. |

No `@JsonKey(name: ...)` annotations or build-wide `field_rename: snake` configuration were found. This is a confirmed client-side defect independent of backend schema uncertainty.

### 6.3 Backend contract and schema blockers

These are inherited from the read-only audits; they were **not re-probed** in this assessment. No credentials were accessed or printed.

| ID | Severity | Evidence | Blocker |
|---|---|---|---|
| C1 | **Critical** | `packages/network/lib/src/supabase_tables.dart:3-13`; `PHASE1-READ-ONLY-BASELINE-AUDIT.md:259-276` | Flutter assumes `driver_profiles`, `transporter_companies`, `job_postings`, `job_applications`, `assignments`, `gps_devices`, `gps_positions`, `trips`, `trip_events`, `user_permissions`; prior anon probes reported them absent from the PostgREST schema cache. |
| C2 | **Critical** | `packages/network/lib/src/trip_lifecycle_service.dart:55-58`; `PHASE1-READ-ONLY-BASELINE-AUDIT.md:191-226,328`; `NATIVE-BACKEND-CONTRACT-DISCOVERY.md:500-509` | Flutter writes `trips.stage`; live-confirmed native-compatible table is `fleet_trips` with `status`, not `stage`. |
| C3 | **Critical** | `NATIVE-BACKEND-CONTRACT-DISCOVERY.md:117-126,203,500-518` | Native writes `trip_events`, `trip_fuel_entries`, `trip_expenses`, `trip_breakdowns`, `trip_closures`; live catalog existence and grants are unresolved. |
| C4 | **Critical** | `packages/network/lib/src/gps_device_service.dart:45-57`; `PHASE1-READ-ONLY-BASELINE-AUDIT.md:117-144` | Flutter streams by `transporter_id` on `trip_location_breadcrumbs`; prior probe reported that column absent. Native payload uses `accuracy_meters` and `idempotency_key`; live column support unresolved. |
| C5 | **Critical** | `PHASE1-READ-ONLY-BASELINE-AUDIT.md:77-84,351-408`; `NATIVE-BACKEND-CONTRACT-DISCOVERY.md:520-528` | RLS policies, RPC bodies, triggers, grants, storage policies, and realtime publication were not verified. No migration or Supabase config exists in the repository. |

The implementation gate documented in `NATIVE-BACKEND-CONTRACT-DISCOVERY.md:586-599` and `EASYFLEET-ARCHITECTURE-PLANNING-BACKEND-CONTRACT-v1.md:386-397` remains closed.

### 6.4 Configuration and platform blockers

| ID | Severity | Evidence | Defect |
|---|---|---|---|
| P1 | High | `packages/core/lib/src/config/environment_config.dart:17-18,22-27` | Invalid `APP_FLAVOR` silently selects `prod`; production Supabase URL is the default; empty anon key is accepted. |
| P2 | High | `apps/driver/lib/main.dart:12-15`, `apps/transporter/lib/main.dart:12-15` | `Supabase.initialize` passes `anonKey` and no custom secure localStorage. Prior audit flags deprecated key naming and token-storage risk (`PHASE1-READ-ONLY-BASELINE-AUDIT.md:748-754`). |
| P3 | High | Both `android/app/build.gradle.kts:33-38` | Release builds sign with debug keys. Not an immediate debug-build blocker, but blocks release readiness. |
| P4 | Medium | Both `android/app/build.gradle.kts:24`; driver manifest `:45-47`; transporter manifest `:35-37` | Maps API key placeholder falls back to empty string; no `mapsApiKey` property is configured in either `android/gradle.properties`. Runtime maps will fail or be blank. |
| P5 | Medium | `apps/driver/android/app/src/main/AndroidManifest.xml:2-10`; transporter manifest `:2-10` | Driver declares location/FGS permissions; transporter does not, yet `packages/maps/lib/src/live_fleet_map.dart:55-56` enables my-location. |
| P6 | Medium | `apps/*/ios/Runner.xcodeproj/project.pbxproj:386,567,589` | iOS bundle IDs are `com.easyfleet.easyfleetDriver` / `...Transporter`, not the native Android package identities. iOS usage-description keys were not found in `Info.plist`. |
| P7 | Low | `.gitignore:7-8` | `*.g.dart` and `*.freezed.dart` are ignored. Generated files exist locally, but a clean checkout requires `scripts/codegen.sh:5-7` before analysis/build. |
| P8 | Low | `packages/core/lib/src/l10n/generated/app_localizations.dart:5` | Generated l10n imports `package:flutter_localizations/flutter_localizations.dart`, but `packages/core/pubspec.yaml:9-14` does not declare it directly. |

### 6.5 Routing, UI, and wiring blockers

| ID | Severity | Evidence | Defect |
|---|---|---|---|
| R1 | **Critical** | `apps/driver/lib/src/router/app_router.dart:41-105`; `apps/transporter/lib/src/router/app_router.dart:41-103` | Every feature destination renders `PlaceholderScreen`. |
| R2 | High | `packages/core/lib/src/router/app_routes.dart:7,26,43`; both app routers | `onboarding`, `tripDetail`, and transporter recruitment/job-posting routes are defined in the catalogue but not registered. |
| R3 | High | `packages/core/lib/src/deep_links/deep_links.dart:4-13`; `apps/driver/android/app/src/main/kotlin/com/easyfleet/driver/MainActivity.kt:1-5`; driver router `:28-109` | Deep link is parsed only in a unit test and manifest; no platform-link listener, no `/trip/:id` GoRoute, and no trip detail screen. Route constant uses `/trips/:tripId`, while the Android filter is `/trip/`. |
| R4 | High | Source-wide symbol search | `syncServiceProvider`, `marketplaceServiceProvider`, `tripLifecycleServiceProvider`, `gpsDeviceServiceProvider`, `biometricServiceProvider`, `userPermissionsProvider`, `LiveFleetMap`, and `TripRouteMap` have no app-level call sites. |
| R5 | High | `packages/auth/lib/src/ui/login_screen.dart:30-46,58-94` | Login screen implements password sign-in only; no signup, recovery, company registration, or company selection UI. |
| R6 | High | `apps/*/lib/src/router/app_router.dart:14-27`; `packages/auth/lib/src/auth_state.dart:3-19` | Router guards only `isAuthenticated`; `AuthState` has no role, company, or verification state. |

### 6.6 Offline sync, GPS, and document blockers

| ID | Severity | Evidence | Defect |
|---|---|---|---|
| O1 | **Critical** | `packages/sync/lib/src/outbox_entry.dart:21,28-50`; `packages/sync/lib/src/outbox_repository.dart:25,45` | `payload` is a `Map` in Dart but a `TEXT` column in SQLite; `fromMap` casts it back to `Map`. No JSON encode/decode is performed. |
| O2 | **Critical** | `packages/sync/lib/src/sync_service.dart:28-61`; `outbox_entry.dart:33` | Idempotency key is stored but never sent or verified. |
| O3 | **Critical** | `packages/sync/lib/src/sync_service.dart:46-50` | Generic `delete_row` RPC with client-supplied `table_name`; high-risk and not defined in the repository. |
| O4 | High | `packages/sync/lib/src/sync_service.dart:44,54` | Update filter casts `payload['id'] as String`; only `DioException` is caught. |
| O5 | High | `syncServiceProvider` has no call sites; `packages/network/lib/src/connectivity_service.dart:11-13` | Flush is never invoked; connectivity defaults to online before first stream event. |
| O6 | **Critical** | `apps/driver/pubspec.yaml:16-19`; no Dart imports found for `geolocator`, `permission_handler`, `flutter_local_notifications`, or `workmanager` | Driver declares GPS/notification/WorkManager dependencies but implements no foreground service, permission flow, breadcrumb writer, or scheduler. |
| O7 | High | `packages/maps/lib/src/live_fleet_map.dart:24-28,60-64`; `trip_route_map.dart:28-33,91-95` | Stream subscriptions are started but never cancelled. |
| O8 | **Critical** | `packages/network/lib/src/onboarding_service.dart:24-33` | Uploads to the documented private bucket, then returns `getPublicUrl(path)`. Prior audit classifies this as a document-exposure defect (`PHASE1-READ-ONLY-BASELINE-AUDIT.md:725-729`). |

---

## 7. Dependency and configuration risks

Resolved key versions from `pubspec.lock`:

```text
flutter_riverpod 3.5.0       go_router 18.1.4          supabase_flutter 2.18.3
dio 5.11.1                   connectivity_plus 6.1.5   geolocator 14.1.2
permission_handler 13.0.2    flutter_local_notifications 23.0.3
workmanager 0.10.10          google_maps_flutter 2.19.0
flutter_secure_storage 11.2.0 local_auth 3.0.2
sqflite 2.4.6                in_app_update 5.0.0
build_runner 2.17.1          freezed 4.0.3             json_serializable 6.15.2
```

Risks:

1. **connectivity_plus constraint:** `6.1.5` is deliberate, not accidental; `7.x` conflicts through `dbus`/`geolocator_linux`. Upgrading requires a dependency-graph decision.
2. **Declared-but-unused platform dependencies:** Driver declares GPS/notification/WorkManager packages with no Dart usage. Transporter declares `google_maps_flutter` and depends on `packages/maps`, but has no location permission and no location flow.
3. **Generated code hygiene:** `.gitignore:7-8` excludes generated Freezed/JSON files; `scripts/codegen.sh` is required in a clean checkout.
4. **Static-analysis scope:** generated code is excluded and deprecations are ignored, so “No issues found” is not a full-quality signal.
5. **Config fail-open:** production URL default, empty key acceptance, and invalid-flavour fallback to prod.
6. **Release readiness:** debug signing in both Android release configs; no maps API key configured; iOS bundle IDs and usage descriptions unresolved.
7. **Architecture:** no package cycles were found, and package direction remains broadly correct. `packages/domain/pubspec.yaml:10-11` still depends on Flutter despite being described as a pure domain package.
8. **Auth storage:** Supabase is initialized without custom secure local storage; no signup/recovery/company-selection flow exists.

---

## 8. Native contract comparison — verified behavior vs assumptions

Evidence labels follow the existing documents: **Observed** = native client literal/call-site evidence; **Live-confirmed** = prior read-only data-plane probe; **Inferred/Unknown** = requires owner decision or privileged read-only catalog evidence.

| Area | Current Flutter — verified in this assessment | Documented native/live contract | Verified vs assumed |
|---|---|---|---|
| Auth | Password sign-in only (`login_screen.dart:30-46`); Supabase session only (`auth_state.dart:3-19`) | **Observed:** native auth token/refresh/signup/recover; driver `create_driver_account`, `get_my_driver_account`; transporter `register_company`, `get_my_companies` (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:74-111`) | Flutter password sign-in verified; native RPC semantics and server behavior unverified. Flutter lacks signup/recovery/company selection. |
| Driver identity | DL controller/service exist but no UI; public document URL used | **Observed:** DL front/back uploads to private bucket under company/driver paths; manual verification states (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:205-232`) | Flutter controller verified; backend verification ownership and storage policies unknown. |
| Transporter identity | GST controller/service exist but no UI; no company membership state | **Observed:** GSTIN/legal name/certificate; `companies`/`company_memberships` are live-confirmed (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:100-110,500-505`) | Company tables live-confirmed by prior audit; Flutter GST path and RPC semantics unknown. |
| Trips | `trips.stage` model and client-side state machine (`trip_lifecycle_service.dart:18-59`) | **Live-confirmed:** `fleet_trips` has `status`, not `stage` (`PHASE1-READ-ONLY-BASELINE-AUDIT.md:191-226`) | Flutter trip root is an unsupported assumption; native-observed events exist but catalog status unresolved. |
| Jobs / appointments | Service contracts exist; no UI; non-atomic two-write appointment (`marketplace_service.dart:93-120`) | **Observed:** native vacancy creation; driver Apply UI uses local callback only; no remote application write observed (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:465-476,479-493`) | Flutter `job_postings`/`assignments` are Flutter-only assumptions; no verified native remote appointment contract. |
| Telemetry / GPS | Dependencies only; no foreground service or breadcrumb writer; maps widgets unwired | **Observed:** native foreground `LiveTrackingService`, ~15 s interval / 10 s minimum, local breadcrumb queue, idempotency-keyed POST (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:195-203`); `trip_location_breadcrumbs` live-confirmed with limited columns | Native client behavior observed; server columns and idempotency enforcement unknown. Flutter has no parity. |
| Offline sync | Generic broken outbox; never invoked | **Observed:** both native apps use local outboxes, bounded retries, conflict verification, dead-letter/COA states (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:61-70,166-193,297-315`) | Native behavior observed; Flutter implementation does not round-trip or propagate idempotency. |
| Documents | `getPublicUrl` against a private bucket | **Observed:** direct private-bucket POST with bearer auth and `x-upsert: true`; driver paths explicit, transporter GST path unknown (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:205-232,434-438`) | Flutter public-URL pattern contradicts documented private contract. |
| Accounting | No Flutter domain/service/UI | **Observed:** COA read, `post_journal_entry`, two-stage document/journal flow, `BLOCKED_COA` (`NATIVE-BACKEND-CONTRACT-DISCOVERY.md:317-415`) | Native client behavior observed; RPC signature, security, atomicity, and partial-failure semantics unknown. |
| Realtime | Four `.stream(...)` calls in services | Publication membership unverified; three target tables reported absent (`PHASE1-READ-ONLY-BASELINE-AUDIT.md:348,1118`) | Flutter Realtime is assumed, not verified. |

**No new backend tables, columns, RPCs, or API contracts are introduced by this report.** Items described as native-observed are inherited from the existing evidence documents and are not treated as verified backend truth.

---

## 9. Prioritized implementation plan

All work below is planning only. The implementation gate remains closed until the owner approves the canonical schema/contract and privileged read-only catalog evidence closes the open `Unknown` items.

### P0 — Build stabilization and evidence closure (highest priority)

1. Install/configure an Android SDK and verify `flutter doctor` shows a healthy Android toolchain; then rerun both `flutter build apk --debug` commands.
2. Keep `pubspec.lock` unchanged during stabilization; treat the `connectivity_plus` pin as an intentional constraint until the `dbus`/`geolocator_linux` conflict is reviewed.
3. Re-run `scripts/codegen.sh` in a clean-checkout simulation to confirm generated Freezed/l10n artifacts are reproducible.
4. Obtain owner approval for the canonical schema strategy and the native-compatible table/RPC model; do not create SQL or migrations in this phase.
5. Close the `trip_events` and breadcrumb schema contradictions with privileged read-only catalog evidence.
6. Decide whether `fleet_trips.status` is canonical and explicitly reject or replace `trips.stage`.

**Acceptance:** both debug APKs build; toolchain is green; contract decisions are recorded; no backend changes have been made.

### P1 — Foundation: configuration, serialization, and auth state

1. Replace fail-open environment handling with explicit validation; stop defaulting to production or accepting empty keys.
2. Migrate to the current Supabase key API and configure secure local storage for session tokens.
3. Add snake_case ↔ domain mapping and tests for every persisted entity before wiring UI.
4. Add role, company, and verification state from trusted DB/JWT sources; keep RLS authoritative.
5. Fix router disposal/lifecycle and add role/verification guards.

**Acceptance:** mapping tests pass for jobs, applications, assignments, profiles, company, trips, events, devices, and breadcrumbs; unauthorized roles cannot reach privileged routes.

### P2 — Authentication and onboarding

1. Implement signup, recovery, and company registration/selection flows using only owner-approved RPC semantics.
2. Build DL onboarding: licence class, experience by vehicle category, document picker/camera, upload, pending/approved/rejected states.
3. Build GST onboarding: GSTIN, legal name, certificate upload, verification states.
4. Replace public document URLs with owner-approved signed/authorized access; define owner-only storage paths and cleanup.

**Acceptance:** both roles can onboard end-to-end; document access tests prove no public or cross-tenant reads.

### P3 — Offline synchronization

1. Fix outbox JSON round-trip and idempotency-key injection.
2. Remove generic client-supplied `delete_row`; use only approved RPCs.
3. Implement bounded retries, claim/lease state, dead-letter handling, recovery of stale `UPLOADING` rows, and connectivity-driven scheduling.
4. Wire `flush()` into authenticated app lifecycle and app resume.
5. Replay native-observed `409`, `401`, retry-exhaustion, and two-stage partial-failure fixtures.

**Acceptance:** duplicate delivery is idempotent; terminal failures are observable; no cross-tenant writes are possible.

### P4 — GPS and background execution

1. Select and approve the phone-location plugin/foreground-service approach; implement permission/accuracy flow and an ongoing tracking notification equivalent to `EASYFLEET_TRACKING`.
2. Preserve native cadence semantics (~15 s updates, ~10 s minimum) only after owner confirmation.
3. Implement local-first breadcrumb queue with idempotency and retention controls.
4. Stop tracking on complete/cancel/logout/consent withdrawal/reassignment.
5. Resolve truck-device feed ownership and vendor-secret handling; do not put vendor credentials in the app.
6. Wire maps to approved position streams and cancel subscriptions in `dispose()`.

**Acceptance:** background tracking survives process/connectivity interruption; positions are deduplicated; consent and retention controls are tested.

### P5 — Driver core workflows

1. Job search/filter/detail/apply UI backed by approved contracts and server-side eligibility checks.
2. Appointment card and trip-stage controls using a server-authoritative transition boundary, not the Dart-only state machine.
3. POD upload, logbook/fuel/expense/breakdown entries, and immutable event timeline consistent with the approved native contract.
4. Wallet/earnings UI only after the native payout/ledger contract is verified.

**Acceptance:** Driver Flutter flow produces the same server-visible records and states as the native app for approved fixtures.

### P6 — Transporter core workflows

1. GST/company profile and membership/company switcher.
2. Job vacancy posting, applicant review, shortlist/appoint flow with atomic appointment semantics.
3. Fleet/vehicle/driver management and trip dispatch using approved `fleet_*` semantics.
4. Review/POD approval and biometric-gated settlement only after transaction and role boundaries are verified.

**Acceptance:** Transporter Flutter flow matches native-visible records, company scoping, and approval states.

### P7 — Accounting and document workflows

1. Verify COA, journal, invoice, bill, closure, and document contracts before implementation.
2. Port accounting flows with server-side validation, idempotency, `BLOCKED_COA` recovery semantics, and two-stage partial-failure handling.
3. Replace hardcoded native placeholder values (for example hardcoded dates/state/vehicle registration) with approved behavior or explicitly accepted defaults.
4. Add document queues for both apps using owner-approved path conventions; do not copy the transporter GST path from driver evidence.

**Acceptance:** journal posting is atomic and idempotent; document access is tenant-scoped; no hardcoded placeholder values remain unless approved.

### P8 — Testing and native parity

1. Unit tests for serialization, transitions, appointment logic, sync state machine, and config validation.
2. Widget tests for onboarding, jobs, appointment, trip, and accounting screens.
3. Integration tests against an approved staging backend with RLS negative tests for Driver A, Transporter B, and unauthenticated users.
4. Android debug builds for both apps on every stabilization commit; release builds after signing and key configuration.
5. Parity fixtures comparing native and Flutter server-visible outputs before any cutover.

**Acceptance:** parity evidence is approved; native apps remain installed and operational through the rollback window.

---

## 10. Compliance confirmation

I explicitly confirm that during this baseline assessment:

- **No source file was edited or deleted.**
- **No configuration file was edited.** `pubspec.lock` hash remained unchanged.
- **No SQL migration was created and no database object was modified.**
- **No Supabase setting, credential, production data, or storage object was modified.** No Supabase probe was run in this assessment; no secret or key value was printed.
- **No native Android application, APK, manifest, Gradle file, or Kotlin source was modified or rebuilt into a distributed artifact.**
- **No existing architecture or package was replaced.**
- **No backend table, column, RPC, or API contract was invented.**
- **No commit or push was performed**; no Git repository exists.
- The only new file created is this report: `/home/ubuntu/easyfleet-flutter/FLUTTER-BUILD-READINESS-REPORT.md`.
- Flutter commands created only ordinary generated build artifacts under `build/`, `.dart_tool/`, and plugin metadata. A SHA-256 check of 266 source/config files passed with zero mismatches.

---

## 11. Bottom line

The Flutter workspace is a well-structured foundation with clean static analysis and passing smoke tests, but it is **not build-ready as a pair of Android applications in this environment** because the Android SDK is absent. Even after installing the SDK, the apps are not functionally ready: core screens are placeholders, services are unwired, serialization is broken, the assumed backend schema conflicts with the prior live audit, offline/GPS/accounting parity is missing, and the documented implementation gate remains closed.

The immediate work is build stabilization and contract/decision closure — not feature implementation.
