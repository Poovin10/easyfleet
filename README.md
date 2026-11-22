# EasyFleet Flutter monorepo

Two Flutter apps against the existing Supabase backend, sharing a set of Dart packages.

## Core product loop (Phase 1 priority)

1. Driver signs up with a **unique DL number**, licence class and experience by vehicle category
   (bulker, oil tanker, open truck, trailer, LMC cab, …); DL document is uploaded for manual approval.
2. Transporter signs up with a **unique GSTIN**; GST certificate is uploaded for manual approval.
3. Transporter posts jobs; drivers search/filter jobs by licence type, experience, location and pay, then apply.
4. Transporter shortlists and appoints a driver; Supabase Realtime mirrors the appointment into both apps.
5. Assignment activates GPS consent and the trip lifecycle: assign → report → load → transit → unload → POD → close.
6. Transporter binds truck GPS devices (IMEI); device positions and driver-phone breadcrumbs feed the same live map.

Fleet ERP features (inspections, fuel, payouts, accounting, alerts, etc.) are supporting functionality after this loop.

```
easyfleet-flutter/
├── apps/
│   ├── driver/        # com.easyfleet.driver
│   └── transporter/   # com.easyfleet.transporter
└── packages/
    ├── core/          # config, router, theme, l10n (7 locales), deep links
    ├── auth/          # Supabase Auth + biometric unlock + permissions
    ├── network/       # Dio client, interceptors, Supabase REST/RPC helpers
    ├── domain/        # Freezed models shared by both apps
    ├── ui/            # shared design system and widgets
    ├── sync/          # offline outbox / breadcrumb queue
    └── maps/          # live fleet map + trip route/ETA widgets
```

## Setup

```bash
# Flutter 3.50.1 / Dart 3.14.0 or newer
./scripts/codegen.sh          # pub get + l10n + Freezed/json_serializable
./scripts/verify.sh           # analyze + smoke tests for both apps
```

Run an app (requires an Android SDK or iOS toolchain):

```bash
cd apps/driver
flutter run \
  --dart-define=SUPABASE_URL=https://iktekjnisqmbjtoictnc.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

For Google Maps, add `mapsApiKey=<your-android-key>` to each app's
`android/gradle.properties` (it is injected into the manifest placeholder).

Android application IDs are preserved from the native apps: `com.easyfleet.driver` and
`com.easyfleet.transporter`. The driver app keeps the `https://app.easyfleet.in/trip/{id}`
app link; publishing `assetlinks.json` at that host is still required.

## Verification status

`flutter analyze` reports **no issues**, and both apps' smoke tests pass. Native builds were
not run because this environment has no Android SDK installed.

## Configuration

Supabase settings are injected at build time so no keys are committed:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://iktekjnisqmbjtoictnc.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

`EnvironmentConfig` reads these defines and exposes `dev`, `staging` and `prod` flavours.

## Package dependency direction

```
apps/*  ->  auth, network, domain, ui, sync, maps, core
auth    ->  core, domain, network
sync    ->  core, network, domain
maps    ->  core, domain, network
ui      ->  core
network ->  core, domain
domain  ->  (pure)
core    ->  (pure Flutter)
```

No package depends on an app.

## Status

Phase 0 scaffold is complete, including the core-loop domain models, service contracts
(DL/GST onboarding, job market, appointments, trip stages, GPS devices), routes and Realtime
subscriptions. Feature implementation follows the adoption matrix in
`../REA-APK-Analysis/WonderMove-Adoption-Matrix.md`.

Required Supabase tables for Phase 1: `driver_profiles`, `transporter_companies`,
`job_postings`, `job_applications`, `assignments`, `gps_devices`, `gps_positions`,
`trip_events` (in addition to the existing `trips` and `trip_location_breadcrumbs`).
