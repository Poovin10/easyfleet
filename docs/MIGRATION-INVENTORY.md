# EasyFleet Phase 2 — Database Migration Inventory

Project: EasyFleet (`iktekjnisqmbjtoictnc`), PostgreSQL 17.
All migrations are **additive** and were applied via Supabase CLI with the
authenticated management token. No existing table was dropped, no row was
deleted or truncated, and no pre-existing RPC was removed.

On 2026-11-23 the remote migration-history rows for all eleven Phase-2 versions
were missing even though the schema objects were present. `supabase migration
repair --status applied` was used to record the already-applied versions; no
migration SQL was replayed against production data. Replacement function
bodies in migrations 8–9 were executed once via `supabase db query` and their
versions were then marked applied.

Backups taken before migration (read-only):

- Full catalog snapshot: `/tmp/opencode/phase1b/backend/*.json` (tables,
  columns, constraints, FKs, indexes, functions + bodies, grants, triggers,
  policies, storage, publications).
- Full row dumps of all 23 pre-existing public tables:
  `/tmp/opencode/impl/backup/*.json` (all were empty at migration time).
- Pre-Phase-2 bodies of the two Phase-1B submission RPCs:
  `/tmp/opencode/impl/backup/phase1b_rpcs.json`.
- Pre-Phase-2 body of `easyfleet_create_trip` and all core RPCs:
  `/tmp/opencode/impl/function_defs.txt`.

Rollback: `supabase/rollback/20261123_phase2_rollback.sql` (guards abort if
any new table/column contains data).

## Migrations applied (in order)

| # | File | Contents |
|---|---|---|
| 1 | `20261123000100_verification_notifications.sql` | Vault encryption keys (`easyfleet_dl_encryption_key`, `easyfleet_gps_credentials_key`); additive columns `driver_licences.licence_document_path/rejection_reason`, `companies.gst_verification_status/gst_rejection_reason` (+CHECK); `platform_staff` + `is_platform_staff()`; `notifications` (+RLS, grants); `easyfleet_notify()` internal helper; `document_review_history` (append-only trigger); **B-01 repair** of `set_driver_official_verification_status` (now targets `driver_licences`, keeps office/compliance authorization, writes legacy audit log + review history + notification); `easyfleet_review_driver_licence`, `easyfleet_review_company_gst`; corrected `easyfleet_submit_driver_licence` (encrypts DL via pgcrypto+vault, fixes NOT NULL `encrypted_dl` and audit company scope) and `easyfleet_submit_company_gst`; realtime: notifications, driver_licences, companies. |
| 2 | `20261123000200_gps_registry.sql` | `gps_providers` catalog (seeded `generic_http_json`); `gps_provider_credentials` (pgp_sym_encrypt with vault key, **no SELECT policy** — RPC-only access); `gps_devices` (unique per company/provider/external id, vehicle FK); `gps_device_positions` (unique device+recorded_at); additive breadcrumb columns `source`, `device_id`, `idempotency_key` (unique), `speed_kmh`, `heading`; `trip_unified_locations` security-invoker view; RPCs `easyfleet_set_gps_credentials`, `easyfleet_get_gps_credentials` (audited access), `easyfleet_list_gps_credentials` (masked), `easyfleet_register_gps_device`, `easyfleet_assign_gps_device` (one device per vehicle), `easyfleet_set_gps_device_status`, `easyfleet_ingest_device_positions` (idempotent batches ≤500, resolves active trip, writes unified breadcrumbs with `GPS_DEVICE` source); realtime: gps_devices, gps_device_positions. |
| 3 | `20261123000300_subscriptions.sql` | `subscription_plans` (seeded `TRANSPORTER_MONTHLY` ₹1,500 / 30 days); `company_subscriptions` (one per company); `payment_transactions` (unique idempotency key); trial-seed trigger on company insert + backfill (preserves existing functionality); `has_active_subscription()`; `easyfleet_pay_subscription` (server-authoritative price, MANUAL/UPI/RAZORPAY/OTHER, renewal extends validity); **subscription guard added to `easyfleet_create_trip`** (body otherwise byte-identical to backup); realtime: company_subscriptions. |
| 4 | `20261123000400_marketplace.sql` | `job_postings`, `job_applications` (unique job+driver), `job_assignments`; RLS: open jobs discoverable by any authenticated user, everything else company/driver scoped; RPCs `easyfleet_post_job` (operator + subscription), `easyfleet_apply_to_job`, `easyfleet_review_application`, `easyfleet_withdraw_application`, `easyfleet_appoint_driver` (atomic: company_drivers + APPROVED membership + assignment + job FILLED + notifications), `easyfleet_end_assignment`, `easyfleet_close_job`, `easyfleet_search_drivers` (VERIFIED licences only, no phone PII); realtime: job_postings, job_applications, job_assignments. |
| 5 | `20261123000500_driver_writes_history.sql` | **Fixed inert RLS**: `driver_licences` had RLS enabled with zero policies — added owner/staff/company-reviewer read policy; `driver_verification_audit_logs` read policy; driver-scoped reads for `fleet_audit_events`, `trip_fuel_entries`, `trip_expenses`; append-only trigger on `fleet_audit_events`; RPCs `easyfleet_add_fuel_entry` (DIESEL/ADBLUE), `easyfleet_add_expense_entry` (receipt path validated against storage), `easyfleet_review_expense`, `easyfleet_report_breakdown`, `easyfleet_update_maintenance_job`, `easyfleet_add_ledger_entry`, `easyfleet_cancel_trip`, `easyfleet_capture_breadcrumb` (idempotent), `easyfleet_add_company_driver`; realtime: fleet_audit_events. |
| 6 | `20261123000600_breadcrumb_grants.sql` | **Grant repair**: `trip_location_breadcrumbs` had policies but no table grants for `authenticated` (all reads/writes failed 42501). Granted SELECT, INSERT; row scope still enforced by existing policies. |
| 7 | `20261123000700_read_paths_payment_fix.sql` | Test-discovered read paths: office staff read `companies`/`driver_accounts`; drivers read their companies (`companies_driver_read`), assigned vehicles (`fleet_vehicles_driver_read`) and maintenance jobs; first-payment purpose fix in `easyfleet_pay_subscription` (SUBSCRIPTION until first captured payment, then RENEWAL). |
| 8 | `20261123000800_contact_lookup_billing.sql` | Business rule **₹100 per driver contact unlock**: `driver_contact_lookups` (RLS company-scoped, unique idempotency key); `payment_transactions.purpose` extended with `CONTACT_LOOKUP`; `easyfleet_lookup_driver_contact()` — server-authoritative amount, active subscription + office-verified licence required, replay returns the same contact without a second charge, audit event written. |
| 9 | `20261123000900_subscription_payment_scope_fix.sql` | Replaced `easyfleet_pay_subscription()` so the SUBSCRIPTION→RENEWAL decision only considers subscription payments; contact-lookup charges no longer misclassify the first subscription payment. No tables, columns, data or grants change. |
| 10 | `20261123001000_vehicle_documents_rpc.sql` | `easyfleet_add_vehicle_document()` registers compliance metadata after a private Storage upload. Company membership, vehicle ownership, document type and the `<company>/vehicles/<vehicle>/<type>/<file>` path are validated server-side; an audit event is written. Needed because the pre-existing `fleet_vehicle_documents` table has SELECT but no INSERT grant. |
| 11 | `20261123001100_trip_ledger_driver_relationships.sql` | Added direct FKs `fleet_trips.driver_account_id → driver_accounts(id)` and `driver_ledger_entries.driver_account_id → driver_accounts(id)` (plus `notify pgrst, 'reload schema'`). The previous composite FKs to `company_drivers(id, company_id, driver_account_id)` prevented PostgREST from resolving the apps' embedded `driver_accounts(display_name)` selects ("could not find a relationship ... in the schema cache"). No data, columns, grants or functions change. |

## Final catalog state (verified read-only after migration)

| Metric | Before Phase 2 | After Phase 2 |
|---|---:|---:|
| Public tables | 23 | 37 |
| Public functions | 24 | 59 |
| RLS policies (public) | 30 | 45 |
| User triggers | 7 | 15 |
| Realtime published tables | 3 | 13 |

Realtime publication `supabase_realtime` now contains: `companies`,
`company_subscriptions`, `driver_licences`, `driver_memberships`,
`fleet_audit_events`, `fleet_trips`, `gps_device_positions`, `gps_devices`,
`job_applications`, `job_assignments`, `job_postings`, `notifications`,
`trip_location_breadcrumbs`. RLS applies to every realtime subscriber.

## Verification (2026-11-23)

`supabase db query --remote=... --file supabase/tests/phase2_backend_tests.sql`
ran inside a rolled-back transaction: **88/88 assertions passed**, including
contact-lookup billing/idempotency, vehicle-document path validation and the
two restored PostgREST relationships.
Live catalog recheck: 37 tables / 59 functions / 45 policies /
11 Phase-2 migration-history rows.

## Data preservation statement

- All 23 pre-existing tables were empty at migration time (verified by full
  row dumps); nothing was deleted regardless.
- Existing auth users (2) untouched; test fixtures ran inside a rolled-back
  transaction and never persisted.
- Existing RPCs preserved; only `set_driver_official_verification_status`
  (broken, B-01) and `easyfleet_create_trip` (guard added, body otherwise
  identical) were replaced, both with backups retained.
