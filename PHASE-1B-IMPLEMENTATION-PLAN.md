# Phase 1B Implementation Plan

Baseline commit: `1d29a44`. User approval to implement was received after the audit-only restriction was lifted.

## Guiding decisions

1. Treat the live Supabase schema as authoritative.
2. Do not create replacement tables.
3. Preserve all existing tables, rows, RLS policies, triggers, constraints, indexes, and RPCs.
4. Preserve the working auth and driver-account bootstrap flow.
5. Prefer explicit unsupported errors over silent queries against nonexistent tables.
6. Add only narrowly scoped RPCs where RLS intentionally blocks direct client writes.
7. Do not modify existing RPC `set_driver_official_verification_status`; it has a separate pre-existing defect (`B-01`).

## Planned changes

### Step 1 — Replace table constants

File: `packages/network/lib/src/supabase_tables.dart`

- Remove all eleven legacy constants.
- Add constants for live objects actually used by client code:
  - `companies`
  - `companyMemberships`
  - `driverAccounts`
  - `driverLicences`
  - `fleetTrips`
  - `fleetVehicles`
  - `fleetAuditEvents`
  - `tripLocationBreadcrumbs`
  - `tripClosures`
  - `tripFuelEntries`
  - `tripExpenses`
  - `driverLedgerEntries`
  - `fleetMaintenanceJobs`

### Step 2 — Correct permissions derivation

File: `packages/auth/lib/src/permissions_service.dart`

- Replace `user_permissions` query with an active `company_memberships` query.
- Derive stable permission strings from role/status.
- Keep `hasPermission` API unchanged.

### Step 3 — Correct onboarding

Files:
- `packages/network/lib/src/onboarding_service.dart`
- `packages/auth/lib/src/onboarding_controller.dart`

Changes:
- Resolve `driver_accounts.id` and `company_memberships.company_id` from `auth.uid()`.
- Build Storage paths that satisfy private-bucket RLS policies.
- Return object paths, not public URLs.
- Call new scoped RPCs for DL/GST writes.
- Map backend verification statuses to `VerificationStatus`.

### Step 4 — Align REST/RPC constants

File: `packages/network/lib/src/api_endpoints.dart`

- Point trip/breadcrumb/fuel/expense/POD/maintenance/ledger constants at real tables.
- Remove constants for nonexistent RPCs and marketplace/driver-specific endpoints.
- Update `RpcNames` to real public RPCs.

### Step 5 — Align or fail fast on unused legacy services

Files:
- `packages/network/lib/src/marketplace_service.dart`
- `packages/network/lib/src/gps_device_service.dart`
- `packages/network/lib/src/trip_lifecycle_service.dart`
- `packages/sync/lib/src/sync_service.dart`
- `packages/domain/lib/src/enums.dart`

Changes:
- Marketplace methods: explicit `UnsupportedError`.
- GPS reads: map `fleet_vehicles`; phone breadcrumbs by `trip_id`; device binding unsupported.
- Trip lifecycle: audit-backed one-shot event stream; stage writes unsupported pending RPC-based redesign.
- Sync delete: explicit unsupported error instead of calling nonexistent `delete_row`.
- Update stale comment in `enums.dart`.

### Step 6 — Additive backend RPCs (no schema/table/policy changes)

New functions only:

```sql
public.easyfleet_submit_driver_licence(
  p_driver_account_id uuid,
  p_licence_class text,
  p_licence_fingerprint text,
  p_storage_path text
) returns uuid
```

```sql
public.easyfleet_submit_company_gst(
  p_company_id uuid,
  p_gstin text,
  p_legal_name text,
  p_storage_path text
) returns uuid
```

Both are `SECURITY DEFINER`, check `auth.uid()`, fully qualify objects with an empty `search_path`, and are granted only to `authenticated` (plus existing `postgres` ownership). No existing function is replaced.

### Step 7 — Verification

- `flutter analyze`
- `dart format --output=none --set-exit-if-changed .`
- `flutter test` in both apps
- Read-only catalog verification of the two new RPCs and grants
- Commit/push and rerun the existing Linux debug APK workflow (debug only, no release APK)

## Expected impact

| Area | Impact |
|---|---|
| Auth/signup | No change; preserved |
| Driver DL onboarding | Now targets real `driver_licences` and private Storage paths |
| Transporter GST onboarding | Now targets real `companies` and private Storage paths |
| Permissions | Now derived from real company memberships |
| Marketplace | Fails fast with documented message instead of 404 |
| GPS/vehicle | Reads real `fleet_vehicles`; writes fail fast where backend has no capability |
| Trip lifecycle | Reads real audit table; unsupported transitions fail fast |
| Existing data | Unchanged |

## Deferred work

- Job marketplace backend decision.
- GPS device registry decision.
- GST verification column and approval workflow.
- Realtime publication for audit events.
- Fix for pre-existing `set_driver_official_verification_status` defect.
- Full RPC-based trip lifecycle UI.

## Implementation status

Completed in the working tree:

- All legacy table constants removed; live-schema constants added.
- Permissions derived from `company_memberships`.
- Onboarding uploads use policy-compliant private Storage paths and scoped RPCs.
- REST/RPC constants aligned to live objects.
- Marketplace, GPS binding/device positions, trip-stage writes, and generic deletes now fail fast with explicit `UnsupportedError`s.
- Vehicle reads and phone-breadcrumb streams use live tables.
- Two additive RPCs created and verified read-only.
- `flutter analyze`: **No issues found**.
- Formatting check: **0 changed**.
- Driver app tests: **1 passed**.
- Transporter app tests: **1 passed**.

No existing table, row, RLS policy, trigger, index, constraint, or RPC was modified. No release APK was built.
