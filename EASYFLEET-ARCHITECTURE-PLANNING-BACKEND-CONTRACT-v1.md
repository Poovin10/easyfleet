# EasyFleet Architecture Planning — Native Backend Contract v1

**Status:** Architecture-planning input only. The backend contract is **not verified**.  
**Date:** 2026-11-22  
**Scope:** Read-only synthesis of the shipped native Android APK evidence, `NATIVE-BACKEND-CONTRACT-DISCOVERY.md`, `PHASE1-READ-ONLY-BASELINE-AUDIT.md`, `PROGRESS-REPORT.md`, and current Flutter source/config.  
**Implementation gate:** Closed. This document does not authorize Flutter feature work, SQL migrations, database changes, Supabase changes, APK rebuilds, or native source edits. Native Driver and Transporter apps remain the operational baseline until Flutter parity and production acceptance are demonstrated.

---

## 1. Executive summary and scope

**Observed:** The shipped native apps are local-first SQLite clients that call Supabase Auth, PostgREST tables/RPCs, and a private Storage bucket through hand-built HTTP. They use outbox tables, injected `idempotency_key` values, conflict verification, bounded retries, and dead-letter states.

**Live-confirmed:** Read-only anon/publishable probes confirmed a small live surface: `companies`, `company_memberships`, `fleet_trips`, `fleet_vehicles`, and `trip_location_breadcrumbs`. Several Flutter-assumed tables and names were absent from the anon PostgREST schema cache.

**Unknown:** The live catalog, RLS policies, grants, triggers, RPC bodies, Storage policies, publication membership, and exact columns of most native-target tables were not available. `trip_events` is a direct contradiction between native client intent and the live probe. No backend contract may be declared verified without privileged read-only catalog evidence.

**Inferred:** The native-observed behavior should be treated as the provisional behavioral baseline for planning, not as an implementation specification. Any future Flutter work must first resolve schema, security, and ownership decisions in a separate approved implementation plan.

Sources:

- `/home/ubuntu/easyfleet-flutter/NATIVE-BACKEND-CONTRACT-DISCOVERY.md` — detailed REA evidence inventory.
- `/home/ubuntu/easyfleet-flutter/PHASE1-READ-ONLY-BASELINE-AUDIT.md` — live read-only probes and defect register.
- `/home/ubuntu/easyfleet-flutter/PROGRESS-REPORT.md` — product assumptions and owner questions.
- `/home/ubuntu/REA-APK-Analysis/rea-evidence-bundle.json` — retained prior REA evidence.
- `/home/ubuntu/REA-APK-Analysis/WonderMove-Adoption-Matrix.md` — GPS/vendor-device context.
- `EasyFleet-Driver.apk` — SHA-256 `64bbae0c64822caf979d65e8770911ad25e0c31aeb180fb05c231c9d07d2630a`.
- `EasyFleet-Transporter.apk` — SHA-256 `ac67c57ae78bdf224d24640867e3cdca8b58c5d24098e8a062e79210ab85fbf3`.

---

## 2. Evidence classification and method

| Label | Meaning | Use in this document |
|---|---|---|
| **Observed** | Literal endpoint, parameter, payload key, storage path, SQL statement, call site, or source line recovered from shipped APKs or current source files. | Establishes client behavior only. |
| **Live-confirmed** | Result of the prior read-only Supabase data-plane probes using the publishable/anon key. | Presence evidence is useful; absence evidence is limited by grants/schema-cache exposure. |
| **Inferred** | Planning inference or proposed decision derived from observed evidence. | Must be verified and approved before adoption. |
| **Unknown** | Not established by APK evidence, live probes, or available source. | Requires owner decision or privileged read-only catalog access. |

**Observed method:** REA/JADX static inspection was used against the two APKs. Large sync-worker bodies fell back to smali with `Method not decompiled` markers; conclusions therefore rely on literal strings, switch targets, SQL statements, and invocation sites rather than reconstructed high-level source.

**Observed method limitation:** REA evidence IDs are call-scoped and regenerate between inspections. Class and method names are the stable references. No APK was executed.

**Unknown control plane:** No service-role key, read-only DB key, SQL migration, Supabase config, policy dump, catalog export, native source tree, or R8 mapping file was available.

---

## 3. Native endpoint, RPC, storage, and payload matrix

### 3.1 Authentication and identity RPCs

| Area | Native call | Observed request or response essentials | Classification |
|---|---|---|---|
| Password login | `POST /auth/v1/token?grant_type=password` | Body `email`, `password`; consumes `access_token`, `refresh_token`, `expires_in`, `user.id` | **Observed** |
| Refresh | `POST /auth/v1/token?grant_type=refresh_token` | Uses stored refresh token; handles `invalid_grant`, `refresh token not found`, `refresh token already used` | **Observed** |
| Signup | `POST /auth/v1/signup` | Body `email`, `password`; may return no session until confirmation | **Observed** |
| Recovery | `POST /auth/v1/recover` | Body `email` | **Observed** |
| Driver identity | `POST /rest/v1/rpc/create_driver_account` | Sends `{}`; consumes scalar or JSON field `create_driver_account` as `driver_account_id` | **Observed** client behavior; server semantics **Unknown** |
| Driver lookup | `POST /rest/v1/rpc/get_my_driver_account` | Consumes `driver_account_id`, `identity_status`, `display_name`, `phone_e164` | **Observed** client behavior; server semantics **Unknown** |
| Transporter registration | `POST /rest/v1/rpc/register_company` | Sends `p_name`, `p_legal_name`, `p_gstin`; returned company id is not consumed in the observed method | **Observed** client behavior; server semantics **Unknown** |
| Company lookup | `POST /rest/v1/rpc/get_my_companies` | Consumes `company_id`, `company_name`, `role`, `membership_status` | **Observed** client behavior; role domain **Unknown** |

### 3.2 Driver remote write endpoints

| Event | Endpoint | Observed payload keys | Classification |
|---|---|---|---|
| `TRIP_EVENT` | `POST /rest/v1/trip_events` | `id`, `trip_id`, `driver_account_id`, `event_type`, `notes`, `occurred_at`, plus injected `idempotency_key` | **Observed** client intent; server table **Unknown** |
| `FUEL_ENTRY` | `POST /rest/v1/trip_fuel_entries` | `id`, `trip_id`, `driver_account_id`, `fuel_type`, `litres`, `rate_per_litre`, `amount`, `pump_name`, `location`, `entry_time`, plus injected key | **Observed**; AdBlue uses same table with `fuel_type = ADBLUE` |
| `EXPENSE_ENTRY` | `POST /rest/v1/trip_expenses` | `id`, `trip_id`, `driver_account_id`, `category`, `description`, `amount`, `created_at`, plus injected key | **Observed** client intent; server table **Unknown** |
| `BREAKDOWN_REPORT` | `POST /rest/v1/trip_breakdowns` | `id`, `trip_id`, `driver_account_id`, `vehicle_registration`, `breakdown_km`, `category`, `description`, `location`, `status`, `reported_at`, plus injected key | **Observed** client intent; server table **Unknown** |
| `POD_SUBMISSION` | `POST /rest/v1/trip_closures` | `id` (document UUID), `trip_id`, `driver_account_id`, `document_type`, `created_at`, plus injected key | **Observed** client intent; closure schema **Unknown** |
| Location breadcrumb | `POST /rest/v1/trip_location_breadcrumbs` | `id`, `trip_id`, `latitude`, `longitude`, `accuracy_meters`, `recorded_at`, `idempotency_key` | **Observed**; live column parity **Unknown** |

### 3.3 Transporter remote write endpoints

| Event | Endpoint | Observed payload keys or action | Classification |
|---|---|---|---|
| `COMPANY_PROFILE_UPDATE` | `PATCH /rest/v1/companies?id=eq.<company_id>` | `company_id`, `company_name`, `gstin`, `address`, `phone` | **Observed**; live column parity partially **Unknown** |
| `VEHICLE_ADD` | `POST /rest/v1/fleet_vehicles` | `id`, `company_id`, `registration_number`, `vehicle_type`, `odometer_km`, `status` | **Observed** |
| `DRIVER_ADD` | `POST /rest/v1/company_drivers` | `id`, `company_id`, `name`, `phone`, `active` | **Observed** client intent; server table **Unknown** |
| `CUSTOMER_ADD` | `POST /rest/v1/customers` | `id`, `company_id`, `customer_code`, `legal_name`, `display_name`, `gstin`, `phone` | **Observed** client intent; server table **Unknown** |
| `VENDOR_ADD` | `POST /rest/v1/vendors` | `id`, `company_id`, `vendor_code`, `business_name`, `category`, `gstin`, `phone` | **Observed** client intent; server table **Unknown** |
| `TRIP_ADD` | `POST /rest/v1/fleet_trips` | `id`, `company_id`, `origin`, `destination`, `scheduled_date`, `status`, `gc_number`, `material`, `tonnes`, `freight_rate`, `business_model` | **Observed**; local vehicle/driver/commercial IDs are omitted |
| `TRIP_STATUS_UPDATE` | `POST /rest/v1/trip_events` | Mapping exists in worker; no direct UI/DB enqueuer was isolated | **Observed** mapping; working call path **Unknown** |
| `JOB_VACANCY_ADD` | `POST /rest/v1/job_vacancies` | `id`, `company_id`, `title`, `city`, `state`, `truck_type`, `offered_salary`, `status`; `state` hardcoded `Kerala` | **Observed** client intent; server table **Unknown** |
| `TRIP_CLOSURE` | `POST /rest/v1/trip_closures` | `id`, `company_id`, `trip_id`, `submission_number`, `status`, `gc_number`, `bata_earned`, `bata_advance`, `total_amount`; then two-stage journal flow | **Observed** client intent; server semantics **Unknown** |
| `CUSTOMER_INVOICE_ADD` | `POST /rest/v1/customer_invoices` | `id`, `company_id`, `invoice_number`, `customer_id`, `invoice_date`, `due_date`, `total_amount`; then two-stage journal flow | **Observed** client intent; server semantics **Unknown** |
| `VENDOR_BILL_ADD` | `POST /rest/v1/vendor_bills` | `id`, `company_id`, `bill_number`, `vendor_id`, `bill_date`, `due_date`, `total_amount`; then two-stage journal flow | **Observed** client intent; server semantics **Unknown** |
| Unmapped/fallback | `POST /rest/v1/transporter_events` | Worker fallback destination | **Observed**; server table and real usage **Unknown** |

### 3.4 Storage contract

| Area | Native behavior | Classification |
|---|---|---|
| Driver object paths | `{company_id}/trips/{trip_id}/pod/{document_id}.jpg`, `receipts`, `identity`, `profile`, `licence` under `easyfleet-private-documents` | **Observed** |
| Driver upload | `POST /storage/v1/object/easyfleet-private-documents/<path>` with bearer auth, `apikey`, `Content-Type: image/jpeg`, `x-upsert: true`; 20 MB guard | **Observed** |
| Transporter upload helper | `uploadDocument(path, bytes, mimeType, Continuation)` targets the same bucket with caller-supplied MIME, bearer auth, `apikey`, `x-upsert: true`; HTTP 200–299 treated as success | **Observed** |
| Transporter GST path | Helper and `transporter_document_queue` exist, but no direct DEX callers, object-path builder, or GST URI writer were isolated | **Unknown** |
| Bucket existence/policies | Native apps target a private bucket; anon probe returned `400 NoSuchBucket` for the bucket name | **Observed** native intent; **Live-confirmed** anon response; actual policies **Unknown** |

### 3.5 Local-only queues and payload state

These are SQLite-local in the shipped apps and must not be promoted to server tables without an owner decision.

| Local structure | Observed role | Classification |
|---|---|---|
| `driver_outbox` | Event queue with `event_id`, `trip_id`, `event_type`, `payload_json`, `occurred_at`, `sync_state` | **Observed** local only |
| `driver_document_queue` | Upload queue with document id, type, local URI, category, state | **Observed** local only |
| `driver_location_breadcrumbs` | Offline breadcrumb queue with local sync state | **Observed** local only |
| `transporter_outbox` | Event queue with `event_id`, `company_id`, `event_type`, `payload_json`, `occurred_at`, `sync_state`, `attempt_count`, `last_error` | **Observed** local only |
| `transporter_document_queue` | GST/document queue fields including `gst_certificate_uri`-adjacent local metadata | **Observed** local only |
| `server_document_id`, `document_created` | Injected into transporter two-stage outbox payload after document creation | **Observed** local payload state; remote column existence **Unknown** |

---

## 4. Live schema reconciliation

### 4.1 Reconciliation matrix

| Name | Native evidence | Live probe result | Classification and planning status |
|---|---|---|---|
| `companies` | Registration RPC, profile PATCH, COA company scope | Present with `id`, `gstin`, `legal_name`, `name`, `status`, timestamps | **Live-confirmed** table; native field parity partially **Unknown** |
| `company_memberships` | `get_my_companies` maps role/status | Present with `company_id`, `user_id`, `role`, `status`, timestamps | **Live-confirmed** table; RPC mapping **Unknown** |
| `fleet_trips` | `TRIP_ADD`, status mapping exists | Present with `status`, `origin`, `destination`, `material`, `scheduled_date`, timestamps | **Live-confirmed** canonical trip candidate |
| `fleet_vehicles` | `VEHICLE_ADD` | Present with `registration_number`, `company_id`, `status`, timestamps | **Live-confirmed** canonical vehicle candidate |
| `trip_location_breadcrumbs` | Native POST with extra fields and company-scoped verify | Present with `id`, `trip_id`, `latitude`, `longitude`, `recorded_at`, `created_at`; `idempotency_key` and `accuracy` reported absent | **Live-confirmed** table; native write parity **Unknown** |
| `trips` | Flutter scaffold assumes it | `404 PGRST205` / not in schema cache | **Live-confirmed** schema-cache absence; contradicts Flutter docs |
| `trip_events` | Driver and transporter sync workers target it | `404 PGRST205` / not in schema cache | **Live-confirmed** schema-cache absence; native/client contradiction unresolved |
| `trip_closures` | POD and closure writers target it | Not in explicit present or absent lists | **Unknown** |
| `trip_fuel_entries`, `trip_expenses`, `trip_breakdowns` | Driver writes target them | Not in explicit present or absent lists | **Unknown** |
| `chart_of_accounts`, `journal_entries`, `post_journal_entry` | COA read, idempotency GET, RPC call | Not resolved by available probes | **Unknown** |
| `company_drivers`, `job_vacancies`, `customers`, `vendors`, `transporter_events` | Transporter writes target them | Not live-confirmed present | **Unknown** |
| `idempotency_key` | Injected into multiple payloads and used in verify URLs | Column confirmed absent only for breadcrumbs among probed candidates | **Unknown** on other targets |
| Flutter `driver_profiles`, `transporter_companies`, `job_postings`, `assignments`, `gps_devices`, `gps_positions`, `user_permissions` | Not used by native apps | Reported absent from anon schema cache | **Live-confirmed** schema-cache absence; unsupported assumptions |

### 4.2 Contradictions that block verification

1. **Trip root:** Flutter documentation says `trips` exists; live probing found `fleet_trips` instead. **Inferred:** `fleet_trips.status` is the better planning candidate, but this requires owner approval.
2. **Event history:** Native apps write `trip_events`; the live probe reported it absent. **Unknown:** whether the table was removed, renamed, hidden by grants, or whether native sync fails in production.
3. **Breadcrumb schema:** Native sends `idempotency_key` and `accuracy_meters`; the live table lacks the probed candidates. **Unknown:** whether writes succeed, fail, or are transformed by a trigger.
4. **Absence strength:** A `404 PGRST205` or `400 42703` from anon PostgREST is data-plane evidence, not catalog proof. **Inferred:** privileged read-only inspection is mandatory before declaring absence.

---

## 5. Entity relationships

All relationships below are client-observed unless explicitly labelled otherwise. None prove server foreign keys, RLS behavior, or triggers.

| Relationship | Evidence | Classification and planning interpretation |
|---|---|---|
| Local trip to vehicle/driver | `trips.vehicle_id → vehicles(id)` and `trips.driver_id → drivers(id)` with `ON DELETE RESTRICT` | **Observed** local only. Remote `TRIP_ADD` omits both IDs; remote linkage **Unknown**. |
| Trip to closure | Closure builder inserts local `trip_closures`, sets local trip `COMPLETED`, enqueues `TRIP_CLOSURE` with `trip_id` | **Observed** client sequence. Server uniqueness and allowed closure count **Unknown**. |
| Driver POD to closure | POD queues a document and `POD_SUBMISSION` to `trip_closures` with a different payload shape than transporter closure | **Observed**. Whether POD and closure are one business record **Unknown**. |
| Invoice to customer | Local FK plus remote `customer_id` payload | **Observed** client link; remote FK **Unknown**. |
| Bill to vendor | Local FK plus remote `vendor_id` payload | **Observed** client link; remote FK **Unknown**. |
| Job vacancy to application | Local `job_applications.vacancy_id`; no observed writer, remote table, or outbox event | **Unknown**. |
| Driver job apply | Apply UI uses an empty sample list and only calls a local callback | **Observed**; no remote application write observed. |
| Driver trip events | `ACCEPTED`, `IN_TRANSIT`, `DELIVERED`, `POD_SUBMITTED` are enqueued as `TRIP_EVENT` rows | **Observed**. Server transition rules **Unknown**. |
| Transporter status update | Worker maps `TRIP_STATUS_UPDATE` to `trip_events`, but no enqueuer was isolated | **Observed** mapping; working call path **Unknown**. |

**Inferred planning rule:** do not adopt Flutter `jobs`, `assignments`, `driver_profiles`, `transporter_companies`, `job_postings`, `gps_devices`, `gps_positions`, or `user_permissions` as canonical until table existence and ownership are resolved.

---

## 6. Idempotency and offline matrix

| Queue | Key source | Selection and claim | Verify behavior | Observed states | Classification |
|---|---|---|---|---|---|
| Driver outbox | `driver_outbox.event_id` | Select `sync_state IN ('PENDING','FAILED') AND attempt_count < 5`, ordered by `occurred_at ASC`; claim sets `UPLOADING` only from `PENDING` or `FAILED` | On `409`, GET `<endpoint>?idempotency_key=eq.<event_id>&company_id=eq.<company_id>&select=id` | `UPLOADING`, `SYNCED`, `FAILED`, `FAILED_PERMANENT`, `PENDING` after auth retry | **Observed** client behavior; server uniqueness **Unknown** |
| Driver breadcrumbs | Breadcrumb `id` | Select `sync_state IN ('PENDING','FAILED')` ordered by `recorded_at ASC`; claim sets `UPLOADING` | On `409`, GET `/rest/v1/trip_location_breadcrumbs?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id` | `UPLOADING`, `SYNCED`, `FAILED`, `FAILED_PERMANENT` | **Observed**; live column support **Unknown** |
| Driver document queue | `document_id` | Select `upload_state IN ('PENDING','FAILED')` ordered by `created_at ASC`; claim sets `UPLOADING` | No separate idempotency verify; storage uses `x-upsert: true` | `PENDING`, `UPLOADING`, `UPLOADED`, `FAILED`, `FAILED_PERMANENT` | **Observed** |
| Transporter outbox | `transporter_outbox.event_id` | Select `sync_state IN ('PENDING','FAILED','BLOCKED_COA') AND attempt_count < 5`; claim sets `UPLOADING` | GET `/rest/v1/<table>?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id` | `UPLOADING`, `SYNCED`, `FAILED`, `FAILED_PERMANENT`, `BLOCKED_COA`, `PENDING` | **Observed**; server uniqueness **Unknown** |
| Journal posting | Outbox idempotency key | Part of two-stage transporter flow | GET `/rest/v1/journal_entries?idempotency_key=eq.<key>&reference_type=eq.<type>&reference_id=eq.<id>&status=eq.POSTED&select=id` | `409 Conflict - Journal not found` observed as an error string | **Observed** client behavior; RPC idempotency **Unknown** |
| COA recovery | Not a queue key | Successful COA sync resets blocked rows | No remote verify | `UPDATE transporter_outbox SET sync_state = 'PENDING' WHERE sync_state = 'BLOCKED_COA'` | **Observed** |

**Unknown:** exact partial-failure recovery when a business document is created but journal posting fails, whether `server_document_id` survives every retry path, and whether `BLOCKED_COA` rows remain safe after COA changes. Smali fallback prevents full control-flow reconstruction.

**Inferred:** any future sync design must define server-side uniqueness, atomicity, and terminal-state handling before client retry behavior is considered complete.

---

## 7. Auth, RLS, and Storage boundaries

### 7.1 Authentication and identity

**Observed:** sessions persist access token, refresh token, expiry, user id, and company id; transporter also persists role. `401` paths refresh the session and reset or retry affected rows.

**Unknown:** whether role, company id, and verification state are server-derived, client-supplied, or trusted by RLS/RPCs. Role value domains and approval states are not established.

**Inferred:** company scope must be a server-derived invariant in any approved design. Client-supplied company filters are not authority.

### 7.2 RLS and grants

**Live-confirmed:** anon `SELECT` is denied on discovered tables, consistent with authenticated-only RLS but not proof of policy correctness.

**Unknown:** policy bodies, commands, roles, grants, column privileges, triggers, and functions. The audit could not inspect `pg_policies`, `pg_proc`, `pg_trigger`, `role_table_grants`, or catalog metadata.

**Inferred:** RLS and RPC authorization must be documented and tested before Flutter writes are enabled.

### 7.3 Storage

**Observed:** both apps post directly to `easyfleet-private-documents` using bearer auth and `x-upsert: true`. Driver path conventions are explicit; transporter GST paths are not.

**Live-confirmed:** anon `GET /storage/v1/bucket` returned an empty list; `GET /storage/v1/bucket/easyfleet-private-documents` returned `400 NoSuchBucket`.

**Unknown:** bucket existence under privileged access, object policies, owner-only path enforcement, and signed-URL policy.

**Inferred:** owner-only Storage paths and signed URLs are required before feature parity; the Flutter `getPublicUrl()` pattern is not an acceptable substitute for the observed private-bucket contract.

---

## 8. Accounting boundaries

### 8.1 Observed client responsibilities

| Boundary | Observed behavior | Classification |
|---|---|---|
| COA read | `GET /rest/v1/chart_of_accounts?company_id=eq.<company_id>` | **Observed** |
| COA fields | Consumes `id`, `company_id`, `account_code`, `account_name`, `account_type`, `sub_category`, `is_system_account` | **Observed** |
| Mapping failure | Missing verified mapping blocks the outbox row as `BLOCKED_COA` | **Observed** |
| Fallback lookups | Company-less fallback lookups exist for AR, AP, operating expense, and freight revenue | **Observed** client behavior; not approved server default |
| Journal lines | Builds `account_id`, `debit_amount`, `credit_amount`, `line_description` objects | **Observed** |
| Journal narratives | `Freight Receivable`, `Freight Revenue`, `Bata Expense`, `Bata Payment`, `Journal Debit`, `Journal Credit` | **Observed** |
| RPC call | `post_journal_entry` with `p_company_id`, `p_entry_number`, `p_entry_date`, `p_reference_type`, `p_reference_id`, `p_description`, `p_idempotency_key`, `p_lines_json` | **Observed** |
| Hardcoded value | `p_entry_date = "2026-11-03"` | **Observed** defect candidate |
| Validation | Rejects non-positive amounts and fewer than two journal lines | **Observed** |

### 8.2 Server responsibilities that remain unknown

**Unknown:** RPC signature and volatility, `SECURITY DEFINER` status, `search_path`, authorization, atomicity between business-document creation and journal posting, server-side balance validation, trigger behavior, and whether production writes succeed.

**Unknown:** exact event-to-`p_reference_type` mapping for every event. Constants `VENDOR_BILL`, `INVOICE`, and `MANUAL` are **Observed**, but complete dispatch is not recoverable from the smali fallback.

**Unknown:** partial-failure recovery when document creation succeeds and journal posting fails. Observed error strings include `Failed to capture server document ID`, `Invalid Server Document UUID recovered`, and `409 Conflict - Journal not found`.

**Inferred:** accounting authority should move to server-side transactional boundaries in any future design, but that is a decision, not an observed native behavior.

---

## 9. GPS architecture

**Observed — native Driver:** a foreground `LiveTrackingService` uses a fused location client, notification channel `EASYFLEET_TRACKING`, and a location request around a 15 s interval with a 10 s minimum. It writes local `driver_location_breadcrumbs`, then `DriverSyncWorker.processLocationBreadcrumbsQueue` posts to `/rest/v1/trip_location_breadcrumbs`.

**Observed — WonderMove reference:** declared fine/coarse location permissions and a geolocator foreground service with `START_STICKY`. First-party code supports one-shot capture, permission/accuracy handling, and geotagged photos. The reference contains no continuous tracking implementation and no map SDK.

**Live-confirmed:** `trip_location_breadcrumbs` exists, but the audit did not confirm `accuracy`, `idempotency_key`, `driver_id`, `transporter_id`, `device_id`, or `sync_state`.

**Observed — Flutter scaffold:** `gps_device_service.dart` assumes absent `gps_devices` and `gps_positions` tables, `imei` as a unique conflict target, and client-supplied `transporter_id`. Map widgets consume streams but are not wired to routes/services and do not dispose subscriptions.

**Unknown:** authoritative truck-GPS vendor/API format, SIM/IMEI gateway details, server-side position ingestion, realtime publication membership, consent lifecycle, retention TTL, precision controls, and access audit.

**Inferred:** phone breadcrumbs and vendor-device positions should be merged server-side only after an approved `position_events`/`vehicle_positions` model and ingest contract exist. This is a proposal, not observed native behavior.

---

## 10. Flutter scaffold defects relevant to the contract

| Area | Source evidence | Classification and impact |
|---|---|---|
| Table constants | `packages/network/lib/src/supabase_tables.dart:3-13` defines `trips`, `trip_events`, `gps_devices`, `gps_positions`, `user_permissions`, and others | **Live-confirmed** schema-cache absence for most names; blocks scaffold parity |
| Trip stage | `packages/domain/lib/src/models/trip.dart:21`, `trip.g.dart:19,43`, `trip_lifecycle_service.dart:55-58` use `trips.stage` | **Observed** Flutter defect; live `fleet_trips.status` confirmed |
| `trip_events` insert/stream | `trip_lifecycle_service.dart:44-66` assumes the table and client-generated IDs | **Live-confirmed** schema-cache absence; append-only enforcement **Unknown** |
| Marketplace writes | `marketplace_service.dart:93-120` uses caller-generated IDs and separate assignment/application writes | **Observed** non-atomicity; no native remote application write observed |
| Serialization mismatch | Snake_case service writes vs camelCase generated parsers in `*.g.dart` | **Observed** deserialization failure risk |
| Outbox payload round-trip | `outbox_entry.dart:21-46` stores a `Map` in a SQLite `TEXT` column | **Observed** serialization defect |
| Idempotency not propagated | `sync_service.dart:38` sends only `entry.payload` | **Observed** divergence from native contract |
| Breadcrumb queue unused | `outbox_repository.dart:33-99` declares a breadcrumb queue but has no methods for it | **Observed** incomplete implementation |
| Generic `delete_row` RPC | `sync_service.dart:46-50` passes client-supplied `table_name` and `id` | **Observed** high-risk defect; no repository definition found |
| Sync flush not invoked | `sync_service.dart:13-18,28` defines provider/flush but no call sites found | **Observed** incomplete implementation |
| Document public URL | `onboarding_service.dart:24-33` uses `getPublicUrl(path)` for a documented private bucket | **Observed** security defect |
| UI placeholders | Driver/transporter routers render `PlaceholderScreen` for feature destinations | **Observed** feature gap |
| Auth role/verification | `auth_state.dart:3-19` has no role/company/verification; routers gate only on authentication | **Observed** authorization gap |
| Permissions | `permissions_service.dart:7-25` queries absent `user_permissions`; no enforcement found | **Observed** gap |
| Platform/config | Fail-open flavor default, debug signing, iOS bundle/usage-description gaps | **Observed** platform release gaps |
| Background location | No foreground service, breadcrumb writer, permission flow, or WorkManager task found in Flutter source | **Observed** GPS implementation gap |

---

## 11. Owner decisions and read-only DB inspection

### 11.1 Owner decisions required

| Decision | Classification | Required outcome |
|---|---|---|
| Canonical schema strategy | **Unknown** | Confirm which existing tables are authoritative and whether schema evolution is allowed |
| Trip model | **Unknown** | Approve `fleet_trips.status`, transitions, closure semantics, and rejection of `trips.stage` |
| Driver identity | **Unknown** | Confirm RPC semantics, DL/OCR approval owner, and verification states |
| Company/membership | **Unknown** | Confirm registration semantics, role values, and approval states |
| Breadcrumb contract | **Unknown** | Decide whether to add native fields, replace with an RPC, or redefine telemetry |
| Event/logbook tables | **Unknown** | Confirm which native-target tables exist and are writable |
| Accounting | **Unknown** | Approve `post_journal_entry` signature, security, atomicity, COA rules, and partial-failure behavior |
| Storage | **Unknown** | Confirm bucket policies, path ownership, signed URLs, and transporter GST behavior |
| Realtime | **Unknown** | Confirm publication membership and whether realtime is required for parity |
| Sync | **Unknown** | Approve idempotency, retries, dead-letter handling, and two-stage recovery |
| GPS | **Unknown** | Decide vendor feed, phone/device merge model, consent, retention, and privacy controls |
| Placeholder values | **Unknown** | Classify hardcoded values as defects or accepted behavior |
| Native cutover | **Unknown** | Define parity evidence, rollout, and rollback criteria |

### 11.2 Read-only DB inspection required

**Inferred:** request privileged read-only access, not service-role write access, sufficient to inspect:

```text
information_schema.tables
information_schema.columns
pg_proc
pg_get_functiondef
pg_policies
pg_trigger / pg_get_triggerdef
pg_class / pg_indexes / pg_constraint
information_schema.role_table_grants
information_schema.column_privileges
storage.buckets
storage.policies
pg_publication_tables
```

**Unknown evidence questions:**

1. Which native-target tables actually exist, with exact columns and types?
2. Do `idempotency_key`, `accuracy_meters`, `company_id`, `server_document_id`, and `document_created` exist where clients use them?
3. What are the exact signatures, bodies, and security attributes of all observed RPCs?
4. Which writes are permitted by RLS and grants for the relevant auth role?
5. Which triggers create or modify closures, journals, journal lines, or timestamps?
6. What Storage policies and path conventions apply?
7. Which tables are published for realtime?

---

## 12. Implementation phases and acceptance tests

All phases below are **Inferred** planning gates. No phase is authorized by this document.

### Phase 0 — Evidence closure

**Acceptance tests:**

- Catalog snapshot resolves every `Unknown` table/column/RPC in sections 4 and 11.
- `trip_events` and breadcrumb contradictions have written resolutions.
- Native-to-live endpoint matrix is signed off by the owner.

### Phase 1 — Contract freeze

**Acceptance tests:**

- Canonical table/RPC/relationship model is approved.
- Snake_case ↔ model serialization tests pass for every persisted entity.
- Observed placeholder values are explicitly accepted or rejected.

### Phase 2 — Foundation

**Acceptance tests:**

- Auth role, company, and verification state come from trusted sources.
- RLS/grants tests prove role-scoped reads and writes.
- Outbox round-trip, idempotency-key injection, and retry-state tests pass.

### Phase 3 — Sync parity

**Acceptance tests:**

- Replay fixtures for `409`, `401`, retry exhaustion, and terminal failure.
- COA-block and COA-recovery fixtures pass.
- Two-stage document/journal partial-failure behavior is deterministic and approved.
- Storage owner-path and signed-URL tests pass.

### Phase 4 — Feature parity

**Acceptance tests:**

- Trip status, closure/POD, job, accounting, document, and GPS flows match the approved contract.
- Realtime behavior is tested only for confirmed publications.
- Native and Flutter outputs are compared against production-parity fixtures.

### Phase 5 — Cutover

**Acceptance tests:**

- Parallel-run parity and production acceptance evidence are approved.
- Native apps remain installed and operational through rollback window.
- Owner signs the cutover and rollback plan.

---

## 13. Approval gates

| Gate | Requirement | Classification |
|---|---|---|
| Gate 1 — Evidence | Catalog evidence closes all blocking `Unknown` items | **Inferred** |
| Gate 2 — Decisions | Owner approves schema, identity, accounting, storage, GPS, and scope decisions | **Inferred** |
| Gate 3 — Security | RLS, RPC authorization, grants, Storage policies, and realtime publication are documented and tested | **Inferred** |
| Gate 4 — Implementation readiness | Separate Flutter implementation plan is reviewed and references the approved contract | **Inferred** |
| Gate 5 — Cutover | Production parity, rollback, and native-retirement evidence are approved | **Inferred** |

**Inferred:** failure of any gate keeps the implementation gate closed.

---

## 14. Evidence anchors and change control

Selected stable class/method references from the companion discovery document:

```text
Driver SupabaseNetworkClient, DriverSessionManager
DriverSyncWorker.doWork, processOutboxQueue, processDocumentQueue, processLocationBreadcrumbsQueue
DriverLocalDatabase.insertOutboxEvent, insertDocumentQueueAndOutbox
Transporter SupabaseTransporterNetworkClient.uploadDocument and uploadDocument$2.invokeSuspend
TransporterSessionManager
TransporterSyncWorker.doWork, syncChartOfAccounts, processOutboxQueue
FleetDatabase.onCreate, createExtendedSchema, upgradeToVersion7, and payload builders
MainActivityKt, SavedFleetScreensKt, TransporterAuthScreenKt UI call sites
```

**Observed:** the companion discovery document records call-scoped `ev_...` IDs for each inspected body. Class and method names are the stable references because REA IDs regenerate per inspection.

**Observed change control:** this architecture document and `NATIVE-BACKEND-CONTRACT-DISCOVERY.md` are the only files changed for this read-only pass. No implementation source, SQL object, database record, Supabase setting, APK, native source, or native configuration was modified.
