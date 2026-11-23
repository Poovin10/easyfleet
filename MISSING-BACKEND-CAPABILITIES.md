# Missing Backend Capabilities

Phase 1B gap register. “Missing” means the Flutter code expects an object or behavior that the live Supabase backend does not provide. It does **not** automatically mean the backend should be changed; several items are likely intentionally out of scope.

## Critical / correctness gaps

| ID | Missing capability | Evidence | Recommendation | New tables justified? |
|---|---|---|---|---|
| M-01 | Job marketplace (`job_postings`, `job_applications`, `assignments`) | Flutter references listed in `FLUTTER-DATABASE-REFERENCE-AUDIT.md`; no such public tables in live catalog | Treat as unsupported until product decision. Do not create parallel marketplace tables in this phase. | No |
| M-02 | GPS device registry (`gps_devices`, `gps_positions`) | No such tables; `fleet_vehicles` is the vehicle registry | Use `fleet_vehicles` for read mapping; use `trip_location_breadcrumbs` for positions; do not invent IMEI fields. | No |
| M-03 | `user_permissions` table | No such table; `company_memberships` + role helper functions exist | Derive permissions from active memberships in Dart. | No |
| M-04 | Driver licence write path | `driver_licences` has no INSERT/UPDATE policy for `authenticated`; only SELECT policies exist | **Resolved:** added `public.easyfleet_submit_driver_licence`, scoped to `is_driver_account_owner(auth.uid())`. | No; function only |
| M-05 | Company GST write path | `companies` has no INSERT/UPDATE policy for `authenticated` | **Resolved:** added `public.easyfleet_submit_company_gst`, scoped to `is_company_manager(auth.uid())`. | No; function only |
| M-06 | GST verification status | `companies` has `gstin` and `gst_certificate_path`, no verification column | Infer “pending” from stored path. If formal approval is required, add a column in a separately approved migration. | No |
| M-07 | Trip lifecycle stage/event model | No `trips` or `trip_events`; `fleet_trips.status` and RPCs exist | Use `fleet_trips.status` and existing lifecycle RPCs; use `fleet_audit_events` for history. | No |
| M-08 | Realtime publication for audit events | `supabase_realtime` publishes only `fleet_trips`, `driver_memberships`, `trip_location_breadcrumbs` | Use one-shot reads for audit history or request a separate publication change. | No |
| M-09 | Generic delete RPC | `delete_row` does not exist; no generic delete function is present | Fail fast in offline sync; do not add a generic destructive RPC. | No |
| M-10 | Legacy RPC names | `create_driver_account`, `get_my_driver_account`, `capture_driver_location`, `get_driver_current_trip`, `get_driver_history` absent | Use `easyfleet_create_driver_account` and table reads. | No |
| M-11 | AdBlue entries and bank details | No corresponding public tables | Leave unsupported; document product decision required. | No |
| M-12 | CamelCase JSON serializers | Generated `fromJson` expects camelCase; PostgREST rows are snake_case | **Resolved for active code:** removed `fromJson` use on legacy snake_case rows; vehicle mapping is now explicit and marketplace methods fail fast. Regenerate serializers only if the models are reused. | No |

## Backend defect found during audit

| ID | Object | Finding | Impact | Recommendation |
|---|---|---|---|---|
| B-01 | `public.set_driver_official_verification_status(p_driver_account_id uuid, p_new_status text, p_verification_notes text)` | Function body reads and updates `public.driver_profiles`, which does not exist in the live catalog | Calling this RPC will fail with `relation "driver_profiles" does not exist` | Fix in a separate, explicitly approved change. Do not modify it in Phase 1B. |

## Data preservation assessment

- No existing table needs to be dropped, renamed, or replaced to align Flutter.
- No existing user data needs to be migrated.
- The proposed corrections are client-side plus two additive RPCs.
- Existing RPCs, RLS policies, triggers, indexes, and constraints remain unchanged.
- Adding RPCs is justified because RLS intentionally grants `authenticated` only SELECT on operational tables; without scoped `SECURITY DEFINER` functions, the Flutter app cannot safely write DL/GST submissions.

## Capability decision register

| Capability | Decision |
|---|---|
| Create marketplace tables | Deferred; product decision required |
| Create GPS device/position tables | Deferred; use vehicle + breadcrumb model |
| Add GST verification column | Deferred; inference used for now |
| Add new tables during Phase 1B | No |
| Modify existing RPCs | No |
| Modify RLS policies | No |
| Add narrowly scoped write RPCs for DL/GST | Yes; additive only |
