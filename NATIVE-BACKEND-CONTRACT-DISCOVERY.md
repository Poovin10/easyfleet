# Native Backend Contract Discovery

**Status:** Architecture-planning evidence only.  
**Date:** 2026-11-22  
**Scope:** Read-only static analysis of the shipped native Android APKs, cross-checked against `PHASE1-READ-ONLY-BASELINE-AUDIT.md`. Includes a second REA pass over payload builders, sync workers, UI call sites, idempotency, accounting, transporter uploads, trip/job relationships, and branch-level sync sequencing.  
**Implementation gate:** Still closed. No Flutter feature, migration, database, backend, or APK changes are authorized by this document. Native Driver and Transporter apps remain the operational baseline until Flutter parity and production acceptance are demonstrated.

---

## 1. Purpose and evidence standard

The largest unresolved audit item is the actual Supabase contract used by the native apps. This document inventories that contract at the level needed for architecture planning. It does **not** declare the live database schema to be fully known.

Evidence labels used below:

| Label | Meaning |
|---|---|
| **Observed** | Literal endpoint, parameter, payload key, storage path, or SQL statement recovered from the shipped APK by JADX/REA static analysis. High confidence as “the app contains this behavior”; does not prove backend acceptance at runtime. |
| **Live-confirmed** | Confirmed by the prior read-only Supabase probes with the publishable/anon key. Presence evidence is useful; absence evidence is weaker because privileged catalog access was unavailable. |
| **Inferred** | Reasonable architecture inference from observed client behavior. Must be verified before implementation. |
| **Unknown** | Not established by APK strings, live probes, or available evidence. Requires owner decision or read-only catalog access. |

Artifacts inspected:

- `EasyFleet-Driver.apk` — `com.easyfleet.driver`, SHA-256 `64bbae0c64822caf979d65e8770911ad25e0c31aeb180fb05c231c9d07d2630a`
- `EasyFleet-Transporter.apk` — `com.easyfleet.transporter`, SHA-256 `ac67c57ae78bdf224d24640867e3cdca8b58c5d24098e8a062e79210ab85fbf3`
- Baseline audit: `PHASE1-READ-ONLY-BASELINE-AUDIT.md`
- Prior Flutter assumptions: `packages/network/lib/src/supabase_tables.dart`, service files under `packages/network/lib/src/`, `packages/sync/lib/src/sync_service.dart`

No native source tree, ProGuard/R8 mapping file, service-role key, SQL migration, or catalog dump was available.

Method names and `ev_...` identifiers in this document are REA static-analysis evidence references. They identify the shipped DEX body that was inspected; they are **not** proof that a remote table, column, RPC, trigger, or policy exists or accepts the write.

Second-pass branch evidence is identified by class/method plus a call-scoped `ev_...` identifier. Because REA evidence IDs are regenerated per inspection, the class and method names are the stable references; the IDs identify the exact body returned by that inspection call. Large sync-worker bodies decompiled to smali fallback with `Method not decompiled` markers, so branch conclusions below are based on literal strings, switch targets, SQL statements, and invocation sites rather than reconstructed high-level source.

---

## 2. Shared Supabase transport contract

### 2.1 Project and storage configuration

| Item | Finding | Evidence |
|---|---|---|
| Supabase project URL | `https://iktekjnisqmbjtoictnc.supabase.co` | **Observed** in both APKs; also **Live-confirmed** in audit |
| Publishable/anon key | Embedded in both APKs; value intentionally not reproduced here | **Observed**; redacted in audit |
| Private storage bucket | `easyfleet-private-documents` | **Observed** in both network clients; audit describes bucket as private |
| Storage access mode | Direct `POST /storage/v1/object/easyfleet-private-documents/<path>` with `Authorization: Bearer <access_token>`, `apikey`, content type, and `x-upsert: true` | **Observed** |
| HTTP implementation | `HttpsURLConnection`, 15 s connect/read timeouts, hand-built JSON | **Observed** in both network clients |

The native apps do **not** use Supabase Flutter/Dart client semantics. They implement PostgREST and Supabase Auth HTTP calls directly.

### 2.2 Request headers

**Observed:**

- Auth endpoints (`/auth/v1/*`): `Content-Type: application/json`, `apikey: <publishable key>`
- Authenticated REST/RPC/storage endpoints: `Authorization: Bearer <access_token>`, `apikey: <publishable key>`
- Table POST/PATCH: `Prefer: return=representation`
- Storage upload: `x-upsert: true`

### 2.3 Offline-first architecture

Both native apps are local-first SQLite applications with a 15-minute WorkManager synchronization cycle:

- UI writes to local tables.
- A local outbox row records an event with `idempotency_key`, event type, JSON payload, attempt count, and sync state.
- Background workers claim pending rows, call Supabase, verify idempotency, and update local state.
- Recovery SQL resets stale `UPLOADING` rows to `PENDING`.

This differs materially from the current Flutter scaffold, where `SyncService` performs a simple direct flush and does not send or verify native-style idempotency keys.

---

## 3. Authentication and identity contract

### 3.1 Shared auth endpoints

**Observed in both apps:**

| Method | Endpoint | Observed request/response essentials |
|---|---|---|
| POST | `/auth/v1/token?grant_type=password` | Body `email`, `password`; response `access_token`, `refresh_token`, `expires_in`, `user.id` |
| POST | `/auth/v1/token?grant_type=refresh_token` | Uses stored refresh token; handles `invalid_grant`, `refresh token not found`, `refresh token already used` |
| POST | `/auth/v1/signup` | Body `email`, `password`; signup may return no session until email confirmation |
| POST | `/auth/v1/recover` | Body `email` |

Both session managers persist `access_token`, `refresh_token`, `expires_at`, `user_id`, and `company_id`; the transporter also persists `role`. Tokens are placed into the in-memory network client via `setAuthToken`.

### 3.2 Driver identity RPCs

**Observed:**

| RPC | Request | Response consumed by app |
|---|---|---|
| `create_driver_account` | `POST /rest/v1/rpc/create_driver_account` with `{}` | Scalar string or JSON field `create_driver_account`; app stores it as `driver_account_id` |
| `get_my_driver_account` | `POST /rest/v1/rpc/get_my_driver_account` with `{}` | JSON array; first row fields: `driver_account_id`, `identity_status`, `display_name`, `phone_e164` |

Driver local profile cache (`driver_profile`) stores `auth_user_id`, `driver_account_id`, `company_id`, `transporter_driver_id`, DL data, OCR fields, and `verification_status`. These are **local cache fields**, not proof of a `driver_profiles` server table.

### 3.3 Transporter identity/company RPCs

**Observed:**

| RPC | Request | Response/effect |
|---|---|---|
| `register_company` | `p_name`, `p_legal_name`, `p_gstin` | Success treated as company registration; returned company id is not consumed in the observed method |
| `get_my_companies` | `{}` | JSON array with `company_id`, `company_name`, `role`, `membership_status` |

The transporter blocks financial operations when no active company identity is selected.

---

## 4. Driver Supabase contract

### 4.1 Remote tables written by the app

All paths below are **Observed** from `DriverSyncWorker`.

| Event type | Remote endpoint | Payload keys observed/consumed |
|---|---|---|
| `TRIP_EVENT` | `POST /rest/v1/trip_events` | `id`, `trip_id`, `driver_account_id`, `event_type`, `notes`, `occurred_at` |
| `FUEL_ENTRY` | `POST /rest/v1/trip_fuel_entries` | `id`, `trip_id`, `driver_account_id`, `fuel_type` (`DIESEL` or `ADBLUE`), `litres`, `rate_per_litre`, `amount`, `pump_name`, `location`, `entry_time` |
| `EXPENSE_ENTRY` | `POST /rest/v1/trip_expenses` | `id`, `trip_id`, `driver_account_id`, `category`, `description`, `amount`, `created_at` |
| `BREAKDOWN_REPORT` | `POST /rest/v1/trip_breakdowns` | `id`, `trip_id`, `driver_account_id`, `vehicle_registration`, `breakdown_km`, `category`, `description`, `location`, `status`, `reported_at` |
| `POD_SUBMISSION` | `POST /rest/v1/trip_closures` | `id` (same UUID as document), `trip_id`, `driver_account_id`, `document_type`, `created_at`; only `docType == "POD"` creates this outbox event |
| Location breadcrumb | `POST /rest/v1/trip_location_breadcrumbs` | `id`, `trip_id`, `latitude`, `longitude`, `accuracy_meters`, `recorded_at`, `idempotency_key` |

Driver AdBlue is mapped into the same remote `trip_fuel_entries` table with `fuel_type = ADBLUE`; it does not post to a separate remote AdBlue table.

**Evidence references — Observed:**

| Contract element | Class/method | REA evidence |
|---|---|---|
| Event-to-endpoint switch, payload mutation, retry state | `DriverSyncWorker.processOutboxQueue` | `ev_7bc167e41666d6e4dacdbebac1b580f50b3dff628daeff24721a0d2ed59695fe` |
| `TRIP_EVENT` builder | `DriverLocalDatabase.insertTripEventAndOutbox` | `ev_dafcc66414b9b547dbe9e2c286196dbc71b552c497a0b8f69d78f8f4e490b216` |
| `FUEL_ENTRY` builder | `DriverLocalDatabase.insertFuelEntryAndOutbox` | `ev_4a3c9854bd9d8666d05704f3aea9b541a06c773ef40c3df7e469fd1d3bb12e7d` |
| `EXPENSE_ENTRY` builder | `DriverLocalDatabase.insertExpenseAndOutbox` | `ev_557abab3551356b65e664caf178f184d068248b2d9b96f98353003e7adeee87b` |
| `BREAKDOWN_REPORT` builder | `DriverLocalDatabase.insertBreakdownAndOutbox` | `ev_b5c1d3d534a59aa29b2685acb0e00a4f872a92b780392e7ff0424945678e1787` |
| AdBlue builder (`FUEL_ENTRY`/`ADBLUE`) | `DriverLocalDatabase.insertAdBlueEntryAndOutbox` | `ev_631d5b538275dac146998283b2d5623a9f71b7ea25dc14091f662c3a5820e9b3` |
| POD document + `POD_SUBMISSION` builder | `DriverLocalDatabase.insertDocumentQueueAndOutbox` | `ev_94b79198757e624c15f3364bacb98d2cab97c33994621aee1aa5c97acf5be4ae` |
| Breadcrumb POST/verify queue | `DriverSyncWorker.processLocationBreadcrumbsQueue` | `ev_f473edcaabc04bd7fc10be59d4900efec8b087dae9ca7696d59a392d3aa6c255` |
| Outbox row shape | `DriverLocalDatabase.insertOutboxEvent` | `ev_d9e6af4d76f6f880330945f8dd77325c954872ecbb7a5b8f50f88ec81eb7bf9d` |

**Second-pass branch evidence — Observed:**

| Contract element | Class/method | REA evidence |
|---|---|---|
| Event-to-endpoint switch, `post$default`, 409 verify URL, `get$default`, state SQL | `DriverSyncWorker.processOutboxQueue` | `ev_0177670b78239e88c419dfc9c6bd4a9ba4ff85030ca2dff9d20ac05c91fb277e` |
| Exact POD document queue and `POD_SUBMISSION` payload builder | `DriverLocalDatabase.insertDocumentQueueAndOutbox` | `ev_4fd1aba9eb7d6f145bcb2b7e07e012e8aff1257d615e9dfaa29abd45cc45dcb5` |
| Outbox row fields (`event_id`, `trip_id`, `event_type`, `payload_json`, `occurred_at`, `sync_state = PENDING`) | `DriverLocalDatabase.insertOutboxEvent` | `ev_9402a7cf930848a6fe626a3bfdef0152def8cf4236c3abc2c7d7bd62b474152f` |
| Document queue selection, states, path construction, upload | `DriverSyncWorker.processDocumentQueue` | `ev_46d586ff474ecff640fe1b896d1b0284a44de36600a8f1ac05aed1545bf1e1c3` |
| Breadcrumb payload key, 409 branch, company-scoped verify URL | `DriverSyncWorker.processLocationBreadcrumbsQueue` | `ev_08cc1199393b04c123731d92223bab96136882e4b82f6fc2aaac3c7efe8760a1` |

**Observed UI call-site caveats.** The shipped trip UI writes `ACCEPTED`, `IN_TRANSIT`, `DELIVERED`, and `POD_SUBMITTED` trip events and starts a sync immediately (`MainActivityKt.DriverTripsScreen...`, e.g. `ev_ca2fa1edee4c57decb122fc41ab1793b1e75a5683cd2bdf9db6cda6ad98001d4`, `ev_4eeefd4d3c7e2d23932a2afa8037c97e8998d587274848e5454a178b3d44e774`, `ev_951b0f5965cc3656ff67a400ce30da3f1d3fc1c7bff33837793f70e667fe9fce`, `ev_2e3dd292280833bbf92be8e3adeb66521adf9e5770a117dac6053010dafaf057`). The POD click both queues a document and enqueues `POD_SUBMISSION`.

The shipped logbook UI passes an empty `trip_id` to fuel, expense, breakdown, and AdBlue builders (`ev_1b2f1beac3112cf828448e93b4df18583740104c29d6e90a5d5cc21210a54253`, `ev_bfb56cb12951895082b7f5fbefa42a9c97c6296a312378bf92d87296bd62c4c0`, `ev_b16a71d7adcbc651a0d57a0a32af5a6ff7ebf0e6d4ce0d7846100d70f59bd38f`, `ev_50b0caf2dabb5296aa1288d8c012bf1b1b66c144c8f55c2453ac5b86f5b51f9c`). Breakdown payloads hardcode `vehicle_registration = "KL 07 AB 1234"` and `status = "REPORTED"`; AdBlue payloads hardcode `entry_time` from the current clock while the local row uses `filling_date = "2026-11-03"`, `odometer_km = 124200`, and `location = "Highway"`. These are **Observed** implementation artifacts, not a recommended contract.

### 4.2 Idempotency verification

**Observed** before write for event queues and breadcrumbs:

```text
GET /rest/v1/<table>?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id
```

Behavior observed on conflict/recovery:

- `409` with no matching id is treated as a conflict requiring retry/recovery, not as success.
- `401` triggers session refresh, then the row is reset to `PENDING` or left for retry.
- Permanent client errors (`400`, `403`, `404`, `422`) move the row to `FAILED_PERMANENT`.
- Exhausted attempts move rows to `FAILED_PERMANENT`.
- `idempotency_key` is part of the client payload but is not visible in the audit’s confirmed column list for `trip_location_breadcrumbs`.

**Per-queue idempotency matrix — Observed:**

| Queue | Key source | Injected into payload | Verify endpoint | Evidence |
|---|---|---|---|---|
| `driver_outbox` event rows | `event_id` from `insertOutboxEvent` | `idempotency_key`, added only when absent | `GET /rest/v1/<table>?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id` | `ev_7bc167e41666d6e4dacdbebac1b580f50b3dff628daeff24721a0d2ed59695fe`, `ev_d9e6af4d76f6f880330945f8dd77325c954872ecbb7a5b8f50f88ec81eb7bf9d` |
| `driver_location_breadcrumbs` | breadcrumb `id` | `idempotency_key` in the POST body | `GET /rest/v1/trip_location_breadcrumbs?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id` | `ev_f473edcaabc04bd7fc10be59d4900efec8b087dae9ca7696d59a392d3aa6c255` |
| `driver_document_queue` | `document_id` | No separate idempotency verify observed for the storage upload; `POD_SUBMISSION` uses the outbox path above | Storage `POST` uses `x-upsert: true` | `ev_e858dfb18b7f8b304def9c75922c40a09c2056e2f8c9d18c30fbf520c4b6482e` |

The selection predicate is `sync_state IN ('PENDING', 'FAILED') AND attempt_count < 5`; claiming a row sets `UPLOADING`, success sets `SYNCED`, and a failed verify emits `409 Conflict - Not Found in Idempotency Verify`. The verify uses `company_id` as a query filter, while the observed driver business payloads do not include `company_id`.

**Observed branch-level sequence for `driver_outbox` (`ev_0177670b78239e88c419dfc9c6bd4a9ba4ff85030ca2dff9d20ac05c91fb277e`):**

1. Select `event_id`, `trip_id`, `event_type`, `payload_json`, and `occurred_at` from `driver_outbox` where `sync_state IN ('PENDING', 'FAILED') AND attempt_count < 5`, ordered by `occurred_at ASC`.
2. Claim the row by setting `sync_state = 'UPLOADING'`.
3. Choose the endpoint from the event type: `TRIP_EVENT → /rest/v1/trip_events`, `FUEL_ENTRY → /rest/v1/trip_fuel_entries`, `POD_SUBMISSION → /rest/v1/trip_closures`, `EXPENSE_ENTRY → /rest/v1/trip_expenses`, `BREAKDOWN_REPORT → /rest/v1/trip_breakdowns`; default `/rest/v1/trip_events`.
4. Parse `payload_json`, add `idempotency_key = event_id` only when the key is absent, then POST the serialized JSON with `SupabaseNetworkClient.post$default`.
5. On HTTP `409`, build `<endpoint>?idempotency_key=eq.<event_id>&company_id=eq.<company_id>&select=id` and call `get$default`.
6. `FAILED`/`FAILED_PERMANENT`/`SYNCED` updates are issued with `UPDATE driver_outbox ... WHERE event_id = ?`.

**Unknown:** catalog existence of `idempotency_key` on `/rest/v1/trip_events`, `/rest/v1/trip_fuel_entries`, `/rest/v1/trip_closures`, `/rest/v1/trip_expenses`, and `/rest/v1/trip_breakdowns`; backend uniqueness or idempotency enforcement; and whether an empty or invalid `company_id` is rejected server-side.

**Observed branch-level sequence for breadcrumbs** (`DriverSyncWorker.processLocationBreadcrumbsQueue`, `ev_08cc1199393b04c123731d92223bab96136882e4b82f6fc2aaac3c7efe8760a1`; stable class/method reference preferred because REA IDs are call-scoped):

1. Select from local `driver_location_breadcrumbs` where `sync_state IN ('PENDING', 'FAILED')`, ordered by `recorded_at ASC`; no `attempt_count` predicate was observed in this query.
2. Claim with `UPDATE driver_location_breadcrumbs SET sync_state = 'UPLOADING' WHERE id = ? AND sync_state IN ('PENDING', 'FAILED')`.
3. Build a POST body containing `id`, `trip_id`, `latitude`, `longitude`, `accuracy_meters`, `recorded_at`, and `idempotency_key`, then POST to `/rest/v1/trip_location_breadcrumbs`.
4. On `409`, build `/rest/v1/trip_location_breadcrumbs?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id` and GET it.
5. Observed state SQL includes `SYNCED`, `FAILED`, and `FAILED_PERMANENT` by breadcrumb `id`.

**Unknown:** whether the live `trip_location_breadcrumbs` table accepts `accuracy_meters`, `company_id`, or `idempotency_key`; the audit confirmed only `id`, `trip_id`, `latitude`, `longitude`, `recorded_at`, and `created_at`, and reported `idempotency_key` and `accuracy` absent among probed candidates.

### 4.3 Driver document storage paths

**Observed** in `DriverSyncWorker.processDocumentQueue`:

| Document type | Category prefix | Remote object path in `easyfleet-private-documents` |
|---|---|---|
| `POD` | `pod` | `{company_id}/trips/{trip_id}/pod/{document_id}.jpg` |
| Receipt/document default | `receipts` | `{company_id}/trips/{trip_id}/receipts/{document_id}.jpg` |
| `LICENCE_FRONT`, `LICENCE_BACK` | `licence` | `{company_id}/{driver_account_id}/licence/{document_id}.jpg` |
| `IDENTITY` | `identity` | `{company_id}/{driver_account_id}/identity/{document_id}.jpg` |
| `PROFILE` | `profile` | `{company_id}/{driver_account_id}/profile/{document_id}.jpg` |

Uploads are direct private-bucket object POSTs with `x-upsert: true`; signed public URLs and public object access are **not** part of the observed native contract.

Additional **Observed** document behavior from `DriverSyncWorker.processDocumentQueue` (`ev_e858dfb18b7f8b304def9c75922c40a09c2056e2f8c9d18c30fbf520c4b6482e`):

- Category mapping: `POD → pod`, `IDENTITY → identity`, `PROFILE → profile`, `LICENCE_FRONT`/`LICENCE_BACK → licence`, default → `receipts`.
- Queue states: `PENDING`, `UPLOADING`, `UPLOADED`, `FAILED`, `FAILED_PERMANENT`.
- Size guard: `MAX_FILE_SIZE_BYTES = 20971520` (20 MB).
- Trip-scoped receipts/POD paths use `{company_id}/trips/{trip_id}/<category>/{document_id}.jpg`; identity/profile/licence paths use `{company_id}/{driver_account_id}/<category>/{document_id}.jpg`.

Second-pass branch evidence (`ev_46d586ff474ecff640fe1b896d1b0284a44de36600a8f1ac05aed1545bf1e1c3`) adds these **Observed** details:

- Queue selection: `upload_state IN ('PENDING', 'FAILED')`, ordered by `created_at ASC`.
- Claim SQL: `UPDATE driver_document_queue SET upload_state = 'UPLOADING' WHERE document_id = ?`.
- Success SQL: `UPDATE driver_document_queue SET upload_state = 'UPLOADED' WHERE document_id = ?`.
- Failure SQL sets `FAILED` or `FAILED_PERMANENT` by `document_id`.
- Upload MIME type is hardcoded `image/jpeg`; object suffix is `.jpg`; path separators/prefixes include `/`, `/trips/`, and bucket `easyfleet-private-documents`.

### 4.4 Driver local-only schema

The following are **local SQLite tables** observed in `DriverLocalDatabase`; they must not be mistaken for server tables:

```text
driver_profile
driver_trip_cache
driver_outbox
driver_document_queue
driver_job_vacancies
driver_job_applications
driver_fuel_entries
driver_adblue_entries
driver_expenses
driver_breakdown_reports
driver_bank_details
driver_location_breadcrumbs
driver_pod_entries
driver_earnings_ledger
```

The audit’s anon probe found these names absent from the PostgREST schema cache. That is consistent with them being local-only.

---

## 5. Transporter Supabase contract

### 5.1 Event-to-table mapping

**Observed** in `TransporterSyncWorker.processOutboxQueue`:

| Event type | Remote table |
|---|---|
| `COMPANY_PROFILE_UPDATE` | `companies` (PATCH by `id=eq.<company_id>`) |
| `VEHICLE_ADD` | `fleet_vehicles` |
| `DRIVER_ADD` | `company_drivers` |
| `CUSTOMER_ADD` | `customers` |
| `VENDOR_ADD` | `vendors` |
| `TRIP_ADD` | `fleet_trips` |
| `TRIP_STATUS_UPDATE` | `trip_events` |
| `JOB_VACANCY_ADD` | `job_vacancies` |
| `TRIP_CLOSURE` | `trip_closures` |
| `CUSTOMER_INVOICE_ADD` | `customer_invoices` |
| `VENDOR_BILL_ADD` | `vendor_bills` |
| Unmapped/fallback | `transporter_events` |

**Evidence references — Observed:**

| Builder/event | Class/method | REA evidence |
|---|---|---|
| Outbox queue + event mapping | `TransporterSyncWorker.processOutboxQueue` | `ev_bbbfb1dab3b1c9c5f903ada8ee9c0a81a961c23ff361621e76a10e0a4c6fe558` |
| `COMPANY_PROFILE_UPDATE` | `FleetDatabase.updateCompanyProfile` | `ev_d9864a103aa10920f3a7fce9de5ffd25af9ad787c2fb322d65751ffcc73783c8` |
| `VEHICLE_ADD` | `FleetDatabase.addVehicle` | `ev_8e6ae1c48779e7f1fe4f111b74631e363f2f0e65bab0c16d1a61ac1d577cb1d7` |
| `DRIVER_ADD` | `FleetDatabase.addDriver` | `ev_c9d669ccedd98f3172e4cbba1f69bd2e39b90bf575708a61ccefa6d64e9f2c27` |
| `CUSTOMER_ADD` | `FleetDatabase.addCustomer` | `ev_46884e805a6b3871baf082acefbfff8d1a47ee59e43b76ff5105a610b7779aa3` |
| `VENDOR_ADD` | `FleetDatabase.addVendor` | `ev_7cdcbdd1cf5ce3ab445711b1e3ac4e230022d8212259a33588091c7f91056b81` |
| `TRIP_ADD` | `FleetDatabase.addTrip` | `ev_0e9b457ce1d363f7c682dc0fb9a38ab4a0a34627fee5f471a8ce155d3fe3b7f6` |
| `JOB_VACANCY_ADD` | `FleetDatabase.addJobVacancy` | `ev_d6c7a01d365c7f3b9270612fd89a9d7580048ad29a94523c073102efcd0fa7b4` |
| `TRIP_CLOSURE` | `FleetDatabase.insertTripClosureAndOutbox` | `ev_bb6b94a018c3d7323747e961098cd1ee29a48f676eea14a39ee170aa025a8b9d` |
| `CUSTOMER_INVOICE_ADD` | `FleetDatabase.insertCustomerInvoiceAndOutbox` | `ev_b994396757d5d822741f8a8ac1de84d1b1b9f0ebb48afef3f53f89cf42f30243` |
| `VENDOR_BILL_ADD` | `FleetDatabase.insertVendorBillAndOutbox` | `ev_b06c6e6a8f2969baf4f7379b84f246eebc6291a2192b6a932878062ce786812f` |
| Outbox row shape | `FleetDatabase.insertTransporterOutboxEvent` | `ev_332707138106f14b07fb17714ce36fa51fc1fd9560759d72293fb9689cadec4b` |

**Second-pass branch evidence — Observed** (`TransporterSyncWorker.processOutboxQueue`, `ev_abd6a1d7c46bc6a99a37f65e881afb7d86d6db953c449d51d6a92e96dfd547ea`):

- Two-stage endpoint switch: `VENDOR_BILL_ADD → vendor_bills`, `CUSTOMER_INVOICE_ADD → customer_invoices`, `TRIP_CLOSURE → trip_closures`.
- Single-stage endpoint switch: `TRIP_STATUS_UPDATE → trip_events`, `VENDOR_ADD → vendors`, `DRIVER_ADD → company_drivers`, `COMPANY_PROFILE_UPDATE → companies`, `JOB_VACANCY_ADD → job_vacancies`, `CUSTOMER_ADD → customers`, `VEHICLE_ADD → fleet_vehicles`, `TRIP_ADD → fleet_trips`; unmapped events fall back to `transporter_events`.
- `COMPANY_PROFILE_UPDATE` uses `patchTable("companies", "id=eq.<company_id>", ...)`; other single-stage events use `postTable(...)`.
- Queue selection is `sync_state IN ('PENDING', 'FAILED', 'BLOCKED_COA') AND attempt_count < 5`, ordered by `occurred_at ASC`.
- Outbox row columns read are `event_id`, `company_id`, `event_type`, `payload_json`, and `occurred_at`.

Most events are POSTed to `/rest/v1/<table>` with `idempotency_key` in the payload and verified with:

```text
GET /rest/v1/<table>?idempotency_key=eq.<key>&company_id=eq.<company_id>&select=id
```

`idempotency_key` is injected from the outbox `event_id` when the JSON does not already contain it. The outbox selection predicate includes `PENDING`, `FAILED`, and `BLOCKED_COA`, with `attempt_count < 5`. The corresponding state updates are `UPLOADING`, `SYNCED`, `FAILED`, `FAILED_PERMANENT`, and `BLOCKED_COA`.

Two-stage documents (`CUSTOMER_INVOICE_ADD`, `VENDOR_BILL_ADD`, `TRIP_CLOSURE`) first create the business document, then call `post_journal_entry`, then store `server_document_id` and `document_created` back into the outbox payload.

**Observed limitation:** the `TRIP_STATUS_UPDATE → trip_events` branch exists in the sync worker, but static reference tracing found no UI/DB method in this APK that enqueues that event. Only ten `insertTransporterOutboxEvent` callers were found, all in `FleetDatabase`. Do not infer a working status-sync call path from the mapping alone.

### 5.2 Chart of accounts and journal posting

**Observed:**

- COA read: `GET /rest/v1/chart_of_accounts?company_id=eq.<company_id>`; only rows whose `company_id` equals the session company are mapped locally.
- COA fields consumed: `id`, `company_id`, `account_code`, `account_name`, `account_type`, `sub_category`, `is_system_account`.
- Missing verified COA mappings put the outbox row into `BLOCKED_COA`; on a later successful COA sync, `BLOCKED_COA` rows are reset to `PENDING`.
- Journal idempotency lookup: `GET /rest/v1/journal_entries?idempotency_key=eq.<key>&reference_type=eq.<type>&reference_id=eq.<id>&status=eq.POSTED&select=id`.
- Journal RPC: `post_journal_entry`.
- Evidence: `TransporterSyncWorker.syncChartOfAccounts` `ev_5ee74944ac65cef0c38e8d30610dc0b961bd67f44f6c23db3d0626a9fe3fd233`; `TransporterSyncWorker.processOutboxQueue` `ev_bbbfb1dab3b1c9c5f903ada8ee9c0a81a961c23ff361621e76a10e0a4c6fe558`.

`post_journal_entry` parameters **Observed**:

```text
p_company_id
p_entry_number          # "JRN-" + short UUID-like suffix
p_entry_date            # observed hardcoded "2026-11-03"
p_reference_type        # VENDOR_BILL | INVOICE | MANUAL
p_reference_id
p_description           # "Journal for <...>"
p_idempotency_key
p_lines_json
```

`p_lines_json` line objects contain:

```text
account_id
debit_amount
credit_amount
line_description
```

Observed line descriptions include `Journal Debit` and `Journal Credit`; observed journal narratives include `Freight Receivable`, `Freight Revenue`, `Bata Expense`, and `Bata Payment`.

COA mapping queries include company-scoped and fallback lookups. **Observed** query predicates:

| Purpose | Company-scoped query | Fallback query |
|---|---|---|
| Cash | `account_type = ASSET` and `sub_category = CASH` | None observed in the extracted strings |
| Accounts receivable | `ASSET` / `ACCOUNTS_RECEIVABLE` | `ASSET` / `ACCOUNTS_RECEIVABLE` without company filter |
| Accounts payable | Not observed company-scoped | `LIABILITY` / `ACCOUNTS_PAYABLE` |
| Operating expense | `EXPENSE` / `OPERATING_EXPENSE` | `EXPENSE` only |
| Freight revenue | `REVENUE` / `FREIGHT_REVENUE` | `REVENUE` / `FREIGHT_REVENUE` without company filter |

All are issued as `SELECT id FROM chart_of_accounts ... LIMIT 1`. Fallbacks are **Observed** client behavior, not safe server-side defaults.

Accounting validation/error strings **Observed** include:

```text
Missing verified COA mapping. Journal posting blocked.
Invalid Amount: Must be finite and strictly positive
Invalid lines array: Must have at least debit and credit lines.
409 Conflict - Journal not found
Failed to capture server document ID
Invalid Server Document UUID recovered
```

Two-stage state behavior **Observed** in `processOutboxQueue`:

1. Mark outbox row `UPLOADING`.
2. POST the business document to the mapped table and recover a server document ID into `server_document_id`.
3. Check for a posted journal by `(idempotency_key, reference_type, reference_id, status=POSTED)`.
4. If absent, call `post_journal_entry` with balanced debit/credit lines; if present, skip re-posting.
5. Write `document_created` and `server_document_id` back into `payload_json`.
6. Mark `SYNCED`, or `BLOCKED_COA` / `FAILED` / `FAILED_PERMANENT` on the observed failure paths.

**Observed journal line construction** from the same branch-level body (`ev_abd6a1d7c46bc6a99a37f65e881afb7d86d6db953c449d51d6a92e96dfd547ea`):

| Line | Debit | Credit | Description |
|---|---|---|---|
| Freight receivable | `freightRevenue` to the mapped debit account | `0` | `Freight Receivable` |
| Freight revenue | `0` | `freightRevenue` to the mapped credit account | `Freight Revenue` |
| Bata expense, only when `bataEarned > 0` | `bataEarned` to the mapped bata expense account | `0` | `Bata Expense` |
| Bata payment, only when `bataEarned > 0` | `0` | `bataEarned` to the mapped cash account | `Bata Payment` |
| Invoice/bill base line | `amountText` to the mapped debit account | `0` | `Journal Debit` |
| Invoice/bill balancing line | `0` | `amountText` to the mapped cash/credit account | `Journal Credit` |

The client rejects a `linesArray` shorter than two entries with `Invalid lines array: Must have at least debit and credit lines.` The exact event-to-`p_reference_type` assignment is only partially recoverable from the smali switch: constants `VENDOR_BILL`, `INVOICE`, and `MANUAL` are **Observed**, but the complete mapping for every event—including whether `TRIP_CLOSURE` is posted as `MANUAL`—is **Unknown**.

**Observed two-stage payload/state SQL** (`TransporterSyncWorker.processOutboxQueue`, `ev_abd6a1d7c46bc6a99a37f65e881afb7d86d6db953c449d51d6a92e96dfd547ea`):

| Stage | Observed SQL or payload action |
|---|---|
| Claim | `UPDATE transporter_outbox SET sync_state = 'UPLOADING' WHERE event_id = ?` |
| Read prior two-stage state | `document_created` is read with `optBoolean(..., false)`; `server_document_id` is read with `optString(..., "")` |
| Persist recovered document state | `UPDATE transporter_outbox SET payload_json = ? WHERE event_id = ?` after setting `document_created = true` and writing the recovered document id |
| Success | `UPDATE transporter_outbox SET sync_state = 'SYNCED' WHERE event_id = ?` |
| Retryable failure | `UPDATE transporter_outbox SET sync_state = 'FAILED', last_error = ?, attempt_count = attempt_count + 1 WHERE event_id = ?` |
| Permanent failure | `UPDATE transporter_outbox SET sync_state = 'FAILED_PERMANENT', last_error = ? WHERE event_id = ?` |
| Authorization failure | `UPDATE transporter_outbox SET sync_state = 'FAILED', last_error = ? WHERE event_id = ?` with observed error `401 Unauthorized` |
| COA block | `UPDATE transporter_outbox SET sync_state = 'BLOCKED_COA', last_error = ?, attempt_count = attempt_count + 1 WHERE event_id = ?` |
| COA recovery | `UPDATE transporter_outbox SET sync_state = 'PENDING' WHERE sync_state = 'BLOCKED_COA'` after successful COA sync |

The two-stage branch reads the created document id from a response JSON array’s first row `id`, then writes it back as `server_document_id` with `document_created = true`. Observed failure strings include `Failed to capture server document ID` and `Invalid Server Document UUID recovered`. The journal idempotency GET is `/rest/v1/journal_entries?idempotency_key=eq.<key>&reference_type=eq.<type>&reference_id=eq.<id>&status=eq.POSTED&select=id`; `409 Conflict - Journal not found` is an observed error string, and the RPC called is `post_journal_entry`.

**Unknown:** exact recovery after a partial failure where the business document was created but the journal was not, whether `server_document_id` and `document_created` survive every retry path, and whether `BLOCKED_COA` rows retain a safe payload/journal state across COA changes. The smali fallback does not support a complete control-flow reconstruction of those paths.

The RPC’s SECURITY DEFINER status, `search_path`, authorization checks, atomicity, and whether the observed client writes actually post in production are **Unknown**.

### 5.3 Transporter payload examples

**Observed** payload keys:

- Vendor bill: `id`, `company_id`, `bill_number`, `vendor_id`, `bill_date`, `due_date`, `total_amount`
- Customer invoice: `id`, `company_id`, `invoice_number`, `customer_id`, `invoice_date`, `due_date`, `total_amount`
- Trip closure: `id`, `company_id`, `trip_id`, `submission_number`, `status`, `gc_number`, `bata_earned`, `bata_advance`, `total_amount`
- Trip add: `id`, `company_id`, `origin`, `destination`, `scheduled_date`, `status`, `gc_number`, `material`, `tonnes`, `freight_rate`, `business_model`
- Vehicle add: `id`, `company_id`, `registration_number`, `vehicle_type`, `odometer_km`, `status`
- Driver add: `id`, `company_id`, `name`, `phone`, `active`
- Customer add: `id`, `company_id`, `customer_code`, `legal_name`, `display_name`, `gstin`, `phone`
- Vendor add: `id`, `company_id`, `vendor_code`, `business_name`, `category`, `gstin`, `phone`
- Job vacancy add: `id`, `company_id`, `title`, `city`, `state` (hardcoded `Kerala`), `truck_type`, `offered_salary`, `status`
- Company profile update: `company_id`, `company_name`, `gstin`, `address`, `phone`

Local-only values such as transporter `vehicle_id`, `driver_id`, `bata_advance`, `customer_id`, `supplier_id`, purchase/selling amounts, `gst_certificate_uri`, and `opened/closed odometer` are stored in SQLite but are not present in the corresponding observed remote payloads.

### 5.4 Transporter document storage

The client contains `uploadDocument(path, bytes, mimeType, Continuation)` targeting `POST /storage/v1/object/easyfleet-private-documents/<path>` with `Authorization`, `apikey`, caller-supplied `Content-Type`, and `x-upsert: true` (`SupabaseTransporterNetworkClient.uploadDocument` `ev_0fdad1050b00c4881c40881a07f05e6fdc19d7f7e048e3ad42343c285bf6c426`; continuation body `ev_976354fd7f6678381e9d802ea19342d8431134ad05174f23c2e1889340fb98e8`). The continuation constructs the URL as `PROJECT_URL + "/storage/v1/object/easyfleet-private-documents/" + path`, uses 15 s connect/read timeouts, treats HTTP 200–299 as success, and maps timeout exceptions to `408` and other exceptions to `500` (**Observed**). A local `transporter_document_queue` table carries `document_id`, `company_id`, `vehicle_id`, `document_type`, `document_number`, `expiry_date`, `local_uri`, `upload_state`, and `created_at` (`FleetDatabase.upgradeToVersion7`, `ev_0c051bce2250e0eb979a9b4aa4d5433f0804a16b35e1c1622972f1ce382b2542`).

However, static reference tracing found **no direct DEX callers** of `uploadDocument()` (`ev_6433db2187675144c6e86024f2e4f449f750d64e82e683dcc93bde51689596c9`, `total: 0`, complete coverage for that inventory). No producer/consumer for `transporter_document_queue`, no object-path builder, and no GST certificate URI writer were isolated. The GST certificate path/URL policy is therefore **Unknown** and must not be inferred from the driver app’s storage layout. `COMPANY_PROFILE_UPDATE` does not carry `gst_certificate_uri` in its observed payload.

### 5.5 Transporter local-only schema

The following are **local SQLite tables** observed in `FleetDatabase`:

```text
vehicles
drivers
trips
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
transporter_outbox
transporter_document_queue
```

`trips`, `journal_entries`, `customers`, etc. here are local names. They are not evidence that identically named public Supabase tables exist.

### 5.6 Trip, job, and party relationships

All rows below are **Observed** client-side facts. None establish server foreign keys or RLS behavior.

| Relationship | Observed client evidence | Planning interpretation |
|---|---|---|
| Trip → vehicle/driver | Local `trips.vehicle_id → vehicles(id)` and `trips.driver_id → drivers(id)` with `ON DELETE RESTRICT` (`FleetDatabase.onCreate`, `ev_243d8b41c1552c79add8e4eb18897ddcd0346b54e3d5cad9c3b5bf9fd4723bfe`). `addTrip` accepts and stores both IDs and also stores `customer_id`, `supplier_id`, bata, and purchase/selling values locally. | Local relationship only. The observed `TRIP_ADD` remote payload omits all of these IDs and commercial fields. Do not assume remote `fleet_trips` carries them. |
| Trip → closure | `insertTripClosureAndOutbox` inserts a local `trip_closures` row keyed by a new closure UUID and `trip_id`, sets local trip status to `COMPLETED`, then enqueues `TRIP_CLOSURE` (`ev_bb6b94a018c3d7323747e961098cd1ee29a48f676eea14a39ee170aa025a8b9d`). Remote closure payload uses `trip_id`, `submission_number = 1`, `status = SUBMITTED`, `gc_number`, `bata_earned`, `bata_advance`, `total_amount`. | One closure row per observed builder call; no observed server uniqueness rule. `submission_number` is hardcoded, not derived from prior closures. |
| Trip closure trigger | `SavedFleetScreensKt$ReviewScreen$3$1$5$1$biometricPrompt$1.onAuthenticationSucceeded` passes `trip.id`, `trip.gcNumber`, session `companyId`, computed `bataEarned`, `trip.bataAdvance`, and computed `freightRevenue` into the closure builder (`ev_bf634c4b90f6a21ea8521589b8fa49267b1578e51d48f833fafd222cd96a28f0`). | Closure is a biometric-gated UI action in this build. Remote authorization is **Unknown**. |
| Invoice → customer / bill → vendor | Local `customer_invoices.customer_id → customers(id)` and `vendor_bills.vendor_id → vendors(id)` with `ON DELETE RESTRICT`; remote payloads carry `customer_id` / `vendor_id` but not local `paid_amount`, `status`, or `trip_id`. | Party IDs are the only observed remote link. Do not infer remote FKs or payment state from the local schema. |
| Job vacancy → application | Local `job_applications` has `vacancy_id`, `driver_name`, `driver_phone`, `status`, `applied_at` (`ev_87fdac888bbc811e342ca679b1c7fc0b623a1b519d2a8d37ea3327d46521eb25`). No observed writer, remote table, or outbox event exists for applications. Transporter only creates vacancies (`ev_d6c7a01d365c7f3b9270612fd89a9d7580048ad29a94523c073102efcd0fa7b4`). | Application persistence and vacancy-to-driver linkage are **Unknown**. |
| Driver job apply UI | `FindJobsScreen` uses `CollectionsKt.emptyList()` for `sampleJobs`; the Apply button only writes a local message and calls `onApplySuccess` (`ev_3063ef24b3542656a8cd3bb2fdffff7f6bed288fd37b1120cbd1da254c577c66`, `ev_68effa694f80e51677f126e85ef51d0bbae493f6d7b1c07c371da61e14487ea2`). | No observed remote application write. Treat Flutter `jobs`/`assignments` tables as unsupported assumptions. |
| Driver trip events | `ACCEPTED`, `IN_TRANSIT`, `DELIVERED`, and `POD_SUBMITTED` are written as `TRIP_EVENT` rows from the trip UI; POD additionally queues `POD_SUBMISSION`. | Status events and closure/POD records are separate observed streams. Server-side status transitions are **Unknown**. |

### 5.7 Direct UI write call sites

**Observed** direct references from tracing:

| UI action | Method/call | Evidence |
|---|---|---|
| Add job vacancy | `RecruitmentScreen$lambda$237$...$226 → FleetDatabase.addJobVacancy` | `ev_801ee2e55def66b412fc95716f9d8322d6cf1b6630800c971ebf1dedec889b28` |
| Add vehicle | `SavedFleetScreen$lambda$85$...$55 → FleetDatabase.addVehicle` | `ev_b7d41d426d5cabcfc65cce97c7b43fe453a522b9b6178a407ed060a98a79aaed` |
| Add driver | `SavedFleetScreen$lambda$85$...$66 → FleetDatabase.addDriver` | `ev_5a580bcae4635354148362709296a2bed1d5535a2488706ac2cdfc2faae7569f` |
| Add customer + invoice | `AccountingScreen$lambda$319$...$299 → addCustomer → insertCustomerInvoiceAndOutbox` | `ev_92bbac27a2b6fe48a1cf5e261a6969c388f350649e230552ba0bf82e76354766` |
| Add vendor + bill | `AccountingScreen$lambda$319$...$312 → addVendor → insertVendorBillAndOutbox` | `ev_3d1703deb49155a6c0aa9605793c9f0b325e7b01f6918bf8b61286a6b235cffd` |
| Company profile update | `SavedFleetScreen$lambda$37$lambda$36 → updateCompanyProfile` | `ev_6e131fb8382adf2eabe4f84f02be0362a5cece7cb9eee88526eb64b4add54561` |
| Trip closure | biometric success callback → `insertTripClosureAndOutbox` → `TransporterSyncWorker.syncNow` | `ev_bf634c4b90f6a21ea8521589b8fa49267b1578e51d48f833fafd222cd96a28f0` |
| Driver POD/receipt | `DriverTripsScreen$lambda$140$lambda$139 → insertDocumentQueueAndOutbox → insertTripEventAndOutbox` | `ev_2e3dd292280833bbf92be8e3adeb66521adf9e5770a117dac6053010dafaf057` |

Static tracing cannot rule out reflection, JNI, dynamic dispatch, or code paths in other builds. Absence of a caller is reported only for direct DEX references in the shipped APK.

---

## 6. Cross-check against live audit findings

### 6.1 Reconciliation matrix

| Name | Native app behavior | Audit live result | Planning status |
|---|---|---|---|
| `companies` | `register_company`; profile PATCH; COA/company scope | Exists; columns include `id`, `gstin`, `legal_name`, `name`, `status`, timestamps | **Use as canonical candidate.** Native expects company profile fields not all live-confirmed. |
| `company_memberships` | Membership/role via `get_my_companies` | Exists with `company_id`, `user_id`, `role`, `status` | **Use as canonical candidate.** RPC output mapping must be verified. |
| `fleet_trips` | `TRIP_ADD`; `TRIP_STATUS_UPDATE` mapping exists but no UI/DB enqueuer was isolated | Exists with `status`, `origin`, `destination`, `material`, `scheduled_date`, etc. | **Native-compatible trip root.** Flutter `trips.stage` assumption is wrong; status-write parity remains unverified. |
| `fleet_vehicles` | `VEHICLE_ADD` | Exists with `registration_number`, `company_id`, `status`, etc. | **Use as canonical vehicle root.** |
| `trip_location_breadcrumbs` | POST with `id`, `trip_id`, lat/lng, `accuracy_meters`, `recorded_at`, `idempotency_key`; company filter | Exists with `id`, `trip_id`, `latitude`, `longitude`, `recorded_at`, `created_at`. Audit reports `idempotency_key` and `accuracy` absent; `accuracy_meters` and `company_id` were not resolved. | **Major schema gap/unknown.** Native write may not match live table. Requires catalog verification. |
| `trip_events` | Driver `TRIP_EVENT`; transporter `TRIP_STATUS_UPDATE` | Audit classifies as absent (`PGRST205`) in schema cache | **Direct contradiction.** Does not prove true absence, but it blocks assuming parity. |
| `trip_fuel_entries`, `trip_expenses`, `trip_breakdowns`, `trip_closures` | Driver sync writes | Not live-confirmed present | **Unknown.** Must verify before Flutter uses them. |
| `chart_of_accounts` | GET by `company_id` | Not resolved by audit | **Unknown.** |
| `journal_entries` | Idempotency lookup + `post_journal_entry` RPC | Local table observed; live table/RPC unresolved | **Unknown.** |
| `company_drivers`, `job_vacancies`, `customers`, `vendors`, `transporter_events` | Transporter sync writes | Not live-confirmed present | **Unknown.** |
| `idempotency_key` on native write tables | Injected by both native workers and used in verify queries | Column mismatch observed only for breadcrumbs | **Unknown outside breadcrumbs.** No catalog evidence that any target table carries this column. |
| `uploadDocument()` / `transporter_document_queue` | Storage helper and local queue exist; no direct DEX callers found | Storage bucket private; GST certificate policy unresolved | **Unknown.** Do not invent a transporter GST path. |
| Job applications | Local `job_applications` table and driver Apply UI exist; no remote write observed | Not live-confirmed present | **Unknown.** No observed native `jobs → assignments` contract. |
| `driver_*` local tables | Native local cache only | Audit reports absent from schema cache | **Do not create server tables from these names by default.** |
| Flutter `driver_profiles`, `transporter_companies`, `job_postings`, `assignments`, `gps_devices`, `gps_positions`, `user_permissions` | Not used by native apps | Audit reports absent | **Flutter-only assumptions; unsupported by native contract.** |

### 6.2 Why the contradiction is unresolved

The audit used read-only publishable/anon probes. A `404 PGRST205` or `400 42703` from PostgREST can reflect grants/schema-cache exposure rather than true catalog absence. Conversely, a shipped APK can contain calls to tables that no longer exist or that fail silently into a dead-letter state.

Therefore:

- Native APK evidence establishes **client intent**, not backend truth.
- Live anon probes establish **observable data-plane behavior**, not complete catalog truth.
- No conclusion about RLS, triggers, RPC bodies, grants, storage policies, or realtime publication is possible without privileged read-only catalog access.

---

## 7. Architecture implications

### 7.1 Provisional source of truth

For planning only, the native-observed contract should be treated as the provisional behavioral baseline:

- identity: Supabase Auth + `create_driver_account` / `get_my_driver_account` / `register_company` / `get_my_companies`
- company scope: `companies` + `company_memberships`
- trips/vehicles: `fleet_trips` + `fleet_vehicles`
- telemetry: `trip_location_breadcrumbs`
- operational events: `trip_events` and the `trip_*` write tables
- accounting: `chart_of_accounts`, `journal_entries`, `post_journal_entry`
- documents: private `easyfleet-private-documents` bucket with explicit object paths
- sync: local outbox + idempotency verify before write + bounded retries/dead letter

This is a planning baseline, **not** authorization to generate migrations.

### 7.2 Decisions required from the owner

1. **Canonical schema strategy:** extend the existing native-compatible tables/RPCs, or introduce a new Flutter-owned schema with an explicit migration and cutover plan.
2. **Trip model:** confirm `fleet_trips.status` is canonical and define status transitions; discard `trips.stage` unless separately approved.
3. **Driver identity:** confirm `create_driver_account`/`get_my_driver_account` remain authoritative and define DL verification ownership and states.
4. **Company/membership:** confirm `register_company`/`get_my_companies` semantics, role values, and membership approval states.
5. **Breadcrumbs:** decide whether to add `idempotency_key`, `accuracy_meters`, and `company_id` to the live table, or replace the native write contract with an RPC.
6. **Event tables:** confirm whether `trip_events`, `trip_fuel_entries`, `trip_expenses`, `trip_breakdowns`, `trip_closures`, `job_vacancies`, `company_drivers`, `customers`, `vendors`, `chart_of_accounts`, and `journal_entries` exist and are writable.
7. **Journal posting:** confirm `post_journal_entry` signature, search path, permission model, idempotency behavior, and COA validation rules.
8. **Storage:** confirm private bucket policies, exact object path conventions, signed-URL policy, and transporter GST certificate behavior.
9. **Realtime:** confirm whether any publication exists; the current audit found no evidence.
10. **Sync semantics:** approve the native idempotency-verify protocol, two-stage document/journal flow, retry limits, and dead-letter handling.
11. **Trip linkage:** decide whether logbook rows must be related to a trip; the shipped driver UI passes an empty `trip_id` for fuel, expense, breakdown, and AdBlue writes, while the transporter omits local vehicle/driver IDs from `TRIP_ADD`.
12. **Placeholder values:** decide whether hardcoded breakdown/AdBlue values, hardcoded `state = Kerala` for job vacancies, and hardcoded `p_entry_date = 2026-11-03` are accepted behavior or defects; do not carry them forward by default.
13. **Trip closures:** confirm `submission_number = 1`, `status = SUBMITTED`, and local trip `COMPLETED` semantics, and decide whether POD submission and trip closure are distinct records or one business event.
14. **Job applications:** decide whether job applications are out of scope, local-only, or need a new remote contract; no native remote write was observed.
15. **Native cutover:** define how long native apps remain authoritative and what production acceptance evidence Flutter must meet.

### 7.3 Read-only backend access required

Before implementation, request catalog-level read access sufficient to inspect:

```text
information_schema.tables / columns
pg_proc                  -- RPC signatures
pg_policies              -- RLS on all touched tables
pg_trigger               -- write-side triggers
pg_extension             -- required extensions
storage.buckets / storage.policies
pg_publication_tables    -- realtime
role_table_grants / column privileges
```

This is the only way to convert the native-observed contract from client evidence into a verified backend contract.

---

## 8. Implementation entry criteria

Phase 1A implementation should remain blocked until all of the following are true:

1. Owner approves the canonical table/RPC/data-relationship model.
2. Native-observed endpoints are verified against the Supabase catalog, with contradictions explicitly resolved.
3. `trip_location_breadcrumbs` column mismatch and `trip_events` schema-cache contradiction are closed.
4. Every table that receives `idempotency_key` is confirmed to expose that column and an appropriate uniqueness/verify strategy.
5. RLS, RPC authorization, storage policies, and realtime publication are documented.
6. Sync idempotency, COA blocking, two-stage document/journal flow, and journal posting semantics are approved.
7. Trip/job/party relationships are approved explicitly, including what to do with observed blank or local-only IDs.
8. Transporter GST certificate upload behavior is resolved from evidence rather than copied from the driver path convention.
9. Flutter data models and services are rewritten to the approved contract in a separate implementation plan.
10. Native apps remain installed and operational until Flutter parity and production acceptance are demonstrated.

---

## 9. Evidence index

Key decompiled classes and representative evidence IDs:

**Driver**

- `com.easyfleet.driver.data.SupabaseNetworkClient` — auth/REST/storage transport.
- `com.easyfleet.driver.data.DriverSessionManager` — token/session persistence.
- `com.easyfleet.driver.data.DriverSyncWorker.doWork` — `ev_2ee79b6b7639997516bbc984ed4ad47a333f8529997f92d2cb93bc5daed2227a`.
- `com.easyfleet.driver.data.DriverSyncWorker.processOutboxQueue` — `ev_7bc167e41666d6e4dacdbebac1b580f50b3dff628daeff24721a0d2ed59695fe`; second-pass branch body `ev_0177670b78239e88c419dfc9c6bd4a9ba4ff85030ca2dff9d20ac05c91fb277e`.
- `com.easyfleet.driver.data.DriverSyncWorker.processLocationBreadcrumbsQueue` — `ev_f473edcaabc04bd7fc10be59d4900efec8b087dae9ca7696d59a392d3aa6c255`; second-pass branch body `ev_08cc1199393b04c123731d92223bab96136882e4b82f6fc2aaac3c7efe8760a1`.
- `com.easyfleet.driver.data.DriverSyncWorker.processDocumentQueue` — `ev_e858dfb18b7f8b304def9c75922c40a09c2056e2f8c9d18c30fbf520c4b6482e`; second-pass branch body `ev_46d586ff474ecff640fe1b896d1b0284a44de36600a8f1ac05aed1545bf1e1c3`.
- `com.easyfleet.driver.data.DriverLocalDatabase.createExtendedSchema` — `ev_bee0b7dfbc43b73cd04b18ff9deeb9ae2bf8cdf51b2fc4a989ab0fe455bee59d`.
- `com.easyfleet.driver.data.DriverLocalDatabase.insertOutboxEvent` — `ev_d9e6af4d76f6f880330945f8dd77325c954872ecbb7a5b8f50f88ec81eb7bf9d`.
- `com.easyfleet.driver.MainActivityKt` — trip/logbook/job UI call sites; selected IDs are listed in sections 4.1 and 5.7.

**Transporter**

- `com.easyfleet.transporter.data.SupabaseTransporterNetworkClient` — auth/REST/storage transport; `uploadDocument` `ev_1c67ce1ac136f7428b8125af0702a6267d272bbc46007a502cf0438a271e439e`; second-pass method `ev_0fdad1050b00c4881c40881a07f05e6fdc19d7f7e048e3ad42343c285bf6c426`; continuation `ev_976354fd7f6678381e9d802ea19342d8431134ad05174f23c2e1889340fb98e8`; reference trace `ev_6433db2187675144c6e86024f2e4f449f750d64e82e683dcc93bde51689596c9`.
- `com.easyfleet.transporter.data.TransporterSessionManager` — token/session/company/role persistence.
- `com.easyfleet.transporter.data.TransporterSyncWorker.doWork` — `ev_6604bd944069e12cc8f51afdd31f5a507fd643e1e7794e75945ec67b3475d595`.
- `com.easyfleet.transporter.data.TransporterSyncWorker.syncChartOfAccounts` — `ev_5ee74944ac65cef0c38e8d30610dc0b961bd67f44f6c23db3d0626a9fe3fd233`; second-pass branch body `ev_5a9fffa4b678b2c3af2984b751ecff4b859d5b926b2b3897d2f30b766df0c636`.
- `com.easyfleet.transporter.data.TransporterSyncWorker.processOutboxQueue` — `ev_bbbfb1dab3b1c9c5f903ada8ee9c0a81a961c23ff361621e76a10e0a4c6fe558`; second-pass branch body `ev_abd6a1d7c46bc6a99a37f65e881afb7d86d6db953c449d51d6a92e96dfd547ea`.
- `com.easyfleet.transporter.data.FleetDatabase.onCreate` — `ev_243d8b41c1552c79add8e4eb18897ddcd0346b54e3d5cad9c3b5bf9fd4723bfe`.
- `com.easyfleet.transporter.data.FleetDatabase.createExtendedSchema` — `ev_87fdac888bbc811e342ca679b1c7fc0b623a1b519d2a8d37ea3327d46521eb25`.
- `com.easyfleet.transporter.data.FleetDatabase.upgradeToVersion7` — `ev_0c051bce2250e0eb979a9b4aa4d5433f0804a16b35e1c1622972f1ce382b2542`.
- `com.easyfleet.transporter.data.FleetDatabase` builder evidence IDs are listed in section 5.1.
- `com.easyfleet.transporter.SavedFleetScreensKt` / `TransporterAuthScreenKt` / `MainActivity` — UI call sites; selected IDs are listed in sections 5.6 and 5.7.
- Configuration: `com.easyfleet.driver.SupabaseConfig`, `com.easyfleet.transporter.BuildConfig`.

All findings are static-analysis observations from the shipped artifacts. No APK was executed and no backend state was modified.

---

## 10. Markdown quality check

**Observed:** the document’s 16 fenced-code markers are balanced, and every pipe-delimited table block has a consistent number of unescaped `|` separators across its header, delimiter, and body rows. No malformed table rows were found in this pass.

This check is limited to structural Markdown quality. It does not change any evidence classification or backend conclusion.
