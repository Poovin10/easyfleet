# EasyFleet — RPC and RLS Inventory (post Phase 2)

Live project `iktekjnisqmbjtoictnc`. All write RPCs are `SECURITY DEFINER`
with `search_path = ''`, check `auth.uid()`, and are granted to
`authenticated` only (plus owner `postgres`). Internal helpers are revoked
from PUBLIC/anon/authenticated.

## Identity & onboarding

| RPC | Authorization | Notes |
|---|---|---|
| `easyfleet_create_driver_account(text)` | any authenticated user | idempotent bootstrap (preserved from Phase 1) |
| `easyfleet_create_company(uuid, text, text)` | authenticated | creates OWNER membership; trial subscription seeded by trigger |
| `easyfleet_submit_driver_licence(uuid, text, text, text)` | driver account owner | DL encrypted at rest (pgcrypto + vault); PENDING; review history; office notified |
| `easyfleet_submit_company_gst(uuid, text, text, text)` | company OWNER/ADMIN | sets PENDING; review history; office notified |
| `easyfleet_review_driver_licence(uuid, text, text, uuid)` | platform staff / service_role / company COMPLIANCE+ with APPROVED driver membership | APPROVED/REJECTED/REVIEW_REQUIRED; rejection requires reason; idempotent |
| `easyfleet_review_company_gst(uuid, text, text, uuid)` | platform staff / service_role only | office-controlled; companies cannot self-approve |
| `set_driver_official_verification_status(uuid, text, text)` | same as legacy (company compliance path) + platform staff + service_role | **B-01 repaired**: targets `driver_licences`; legacy audit log preserved |

Office roster: `public.platform_staff` is server-managed only (no
authenticated policies). Add officers with:
`insert into public.platform_staff(user_id, staff_role) values ('<auth uid>', 'VERIFICATION_OFFICER');`

## Fleet operations

| RPC | Authorization |
|---|---|
| `easyfleet_create_vehicle(...)` | company operator (OWNER/ADMIN/DISPATCHER) |
| `easyfleet_add_company_driver(uuid, uuid, text)` | company manager |
| `easyfleet_create_trip(...)` | company operator **+ active subscription** |
| `easyfleet_start_trip(...)` | assigned approved driver or operator |
| `easyfleet_cancel_trip(uuid, uuid, text, uuid)` | operator; reason required; PLANNED/ASSIGNED only |
| `easyfleet_submit_trip_closure(...)` | assigned approved driver or operator; POD path validated + object must exist |
| `easyfleet_review_trip_closure(...)` | manager; submitter cannot self-review |
| `easyfleet_add_fuel_entry(...)` | assigned approved driver |
| `easyfleet_add_expense_entry(...)` | assigned approved driver; receipt path validated |
| `easyfleet_review_expense(...)` | manager |
| `easyfleet_report_breakdown(...)` | assigned approved driver |
| `easyfleet_update_maintenance_job(...)` | operator |
| `easyfleet_add_ledger_entry(...)` | manager |
| `easyfleet_capture_breadcrumb(...)` | assigned driver; idempotent by key |
| `easyfleet_write_audit_event(...)` | internal (used by RPCs) |

## Marketplace (separate from fleet operations)

| RPC | Authorization |
|---|---|
| `easyfleet_post_job(...)` | operator + active subscription |
| `easyfleet_apply_to_job(...)` | authenticated driver account; OPEN jobs; duplicate-safe |
| `easyfleet_review_application(...)` | operator of posting company |
| `easyfleet_withdraw_application(uuid)` | applicant only |
| `easyfleet_appoint_driver(uuid, uuid, uuid)` | manager; atomic membership + assignment |
| `easyfleet_end_assignment(uuid)` | manager |
| `easyfleet_close_job(uuid, text)` | operator |
| `easyfleet_search_drivers(text, text, int)` | active company member; VERIFIED licences only; no phone PII |

## GPS

| RPC | Authorization |
|---|---|
| `easyfleet_set_gps_credentials(...)` | manager; encrypted with vault key |
| `easyfleet_get_gps_credentials(uuid)` | manager of owning company / service_role; **access audited** |
| `easyfleet_list_gps_credentials(uuid)` | manager; masked metadata only |
| `easyfleet_register_gps_device(...)` | operator |
| `easyfleet_assign_gps_device(...)` | operator; one active device per vehicle |
| `easyfleet_set_gps_device_status(...)` | operator |
| `easyfleet_ingest_device_positions(...)` | operator / service_role; idempotent batches ≤ 500 |

## Billing

| RPC | Authorization |
|---|---|
| `easyfleet_pay_subscription(uuid, text, text, uuid, text, text)` | manager; price from `subscription_plans` (₹1,500/30d); UPI/RAZORPAY require provider reference; idempotent |
| `has_active_subscription(uuid)` | helper used by trip/job guards |

## RLS summary (44 policies)

- Every public table has RLS enabled. No table is writable directly by
  `authenticated` except `trip_location_breadcrumbs` (INSERT/SELECT scoped by
  existing trip-driver/company policies) and `notifications.read_at`
  (own rows).
- Read scopes: company membership helpers (`is_company_member`,
  `is_company_manager`, `is_company_operator`, `is_company_history_reviewer`),
  driver ownership (`is_driver_account_owner`, `is_approved_company_driver`),
  platform staff (`is_platform_staff`).
- Phase-2 additions: driver reads for licences, audit history, fuel,
  expenses, vehicles, maintenance jobs, companies; office reads for
  companies/driver accounts; marketplace discovery of OPEN jobs.
- `gps_provider_credentials` and `platform_staff` have **no** authenticated
  policies (RPC-only / server-managed).
- Append-only integrity triggers: `fleet_audit_events`,
  `document_review_history`, `driver_verification_audit_logs` (pre-existing).

## Realtime (13 tables)

`companies`, `company_subscriptions`, `driver_licences`,
`driver_memberships`, `fleet_audit_events`, `fleet_trips`,
`gps_device_positions`, `gps_devices`, `job_applications`,
`job_assignments`, `job_postings`, `notifications`,
`trip_location_breadcrumbs`.

Realtime respects RLS per subscriber; confidential columns (e.g. encrypted
credentials) are never published.

## Storage

Private bucket `easyfleet-private-documents` (20 MB; pdf/jpeg/png/webp).
Policy-scoped paths:

- `<company_id>/company_documents/<file>` — OWNER/ADMIN upload, members read
- `personal/<driver_account_id>/licence|identity|profile/<file>` — owner or
  approved-company staff
- `<company_id>/trips/<trip_id>/pod|receipts/<file>` — members or assigned driver
- `<company_id>/vehicles/<vehicle_id>/rc|insurance|fitness|permit|puc|tax|other/<file>`

Clients use short-lived signed URLs (`createSignedUrl`), never public URLs.

## Test evidence

`supabase/tests/phase2_backend_tests.sql` — 81 assertions covering RPC happy
paths, authorization denials, RLS visibility, idempotent replays, conflict
detection, subscription enforcement, GPS credential encryption roundtrip,
marketplace appointment atomicity, closure lifecycle and append-only
integrity. Runs as simulated `authenticated` roles inside a rolled-back
transaction. Result: **81/81 pass** (run twice: after migration 7 and at
final verification).
