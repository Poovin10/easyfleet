# Backend–Flutter Mapping

Phase 1B mapping of Flutter functionality to the live Supabase schema at commit `1d29a44`.

## Mapping summary

| Flutter feature / component | Legacy assumption | Actual backend object(s) | Alignment status |
|---|---|---|---|
| App bootstrap and auth session | Supabase Auth | `auth.users`, `auth.sessions` | Aligned |
| Driver signup | Auth user plus app role metadata | `auth.users`; user metadata `display_name`, `app_role` | Aligned |
| Driver-account bootstrap | `create_driver_account` RPC | `public.easyfleet_create_driver_account(p_display_name text)` | Aligned and preserved |
| Driver identity profile | `driver_profiles` | `driver_accounts` (`auth_user_id`, `display_name`, `identity_status`) | Needs client rename |
| Driver licence upload/status | `driver_profiles.dl_*` | `driver_licences` (`driver_account_id`, `dl_fingerprint`, `licence_class`, `verification_status`, `issuing_state`, `valid_from`, `valid_until`) | Aligned: scoped RPC + client mapping |
| Transporter/company onboarding | `transporter_companies` | `companies` (`gstin`, `legal_name`, `gst_certificate_path`) + `company_memberships` | Aligned: scoped RPC + client mapping |
| GST approval state | `gst_verification` | No backend column; infer from `gst_certificate_path` | Gap (documented) |
| Permissions | `user_permissions.permission` | `company_memberships.role/status` + `is_company_member`, `is_company_manager`, `is_company_operator`, `is_company_history_reviewer`, `is_approved_company_driver` | Aligned: derived in Dart |
| Fleet vehicles / tracker registry | `gps_devices` (`imei`, `sim_number`, `transporter_id`) | `fleet_vehicles` (`company_id`, `registration_number`, `vehicle_type`, `status`) | Partial: reads mapped; no IMEI registry |
| Device live positions | `gps_positions` | `trip_location_breadcrumbs` (`trip_id`, latitude/longitude, `accuracy_meters`, `recorded_at`) | Explicitly unsupported; use trip breadcrumbs |
| Phone breadcrumbs | `trip_location_breadcrumbs.transporter_id` | Same table, scoped by `trip_id` | Aligned |
| Job marketplace | `job_postings`, `job_applications`, `assignments` | No equivalent objects | Missing capability; mark unsupported |
| Trip lifecycle | `trips.stage`, `trip_events` | `fleet_trips.status` + RPCs `easyfleet_start_trip`, `easyfleet_submit_trip_closure`, `easyfleet_review_trip_closure`; audit in `fleet_audit_events` | Writes fail fast; RPC-based redesign deferred |
| Trip lifecycle stream | `trip_events` Realtime | `fleet_audit_events` exists but is not published | Aligned as one-shot select stream |
| Fuel entries | `driver_fuel_entries` (unused constant) | `trip_fuel_entries` | Constant only; map |
| Expenses | `driver_expenses` (unused constant) | `trip_expenses` | Constant only; map |
| POD entries | `driver_pod_entries` (unused constant) | `trip_closures` | Constant only; map |
| Breakdown reports | `driver_breakdown_reports` (unused constant) | `fleet_maintenance_jobs` | Constant only; map |
| Earnings ledger | `driver_earnings_ledger` (unused constant) | `driver_ledger_entries` | Constant only; map |
| AdBlue / bank details | `driver_adblue_entries`, `driver_bank_details` | No backend objects | Gap |
| Private documents | Public URL from private bucket | Private bucket with company/driver/trip/vehicle-scoped policies | Needs path correction |
| Offline writes | Direct REST insert/update; `delete_row` RPC | Most tables are SELECT-only for `authenticated`; writes are through `SECURITY DEFINER` RPCs; no generic delete RPC | Needs RPC-based redesign |

## Ownership and tenancy model

The backend is company-centric:

1. `auth.users` identifies the human account.
2. `driver_accounts.auth_user_id` links a driver identity to an auth user (unique).
3. `company_memberships.user_id` links any auth user to a company with a role and status.
4. `company_drivers` and `driver_memberships` link a driver account to a company.
5. `fleet_trips` is owned by a company and references vehicle plus driver-company pair.
6. `trip_location_breadcrumbs` references `fleet_trips.id` and inherits trip scope.
7. RLS helper functions enforce scope; most writes are intentionally routed through `SECURITY DEFINER` functions.

The Flutter job-market model (`transporter_id` as a user id, `driver_id` as a user id) does not match this identity model. User ids must not be used where the backend expects UUIDs from `driver_accounts`, `companies`, or `fleet_trips`.

## Storage path mapping

| Document | Legacy Flutter path | Backend policy-compliant path |
|---|---|---|
| Driver licence | `<auth_user_id>/dl-<ts>.jpg` | `personal/<driver_account_id>/licence/<ts>.jpg` |
| Driver identity/profile | `<auth_user_id>/<kind>-<ts>.jpg` | `personal/<driver_account_id>/identity/<ts>.jpg` or `.../profile/...` |
| Company GST certificate | `<auth_user_id>/gst-<ts>.jpg` | `<company_id>/company_documents/<ts>.jpg` |
| Trip POD | Not implemented | `<company_id>/trips/<trip_id>/pod/<filename>` |
| Vehicle documents | Not implemented | `<company_id>/vehicles/<vehicle_id>/<rc\|insurance\|...>/<filename>` |

The bucket `easyfleet-private-documents` is private. Client code should persist the storage object path, not `getPublicUrl()` output.

## RPC inventory relevant to Flutter

| RPC | Purpose | Flutter relevance |
|---|---|---|
| `easyfleet_create_driver_account(text)` | Bootstrap `driver_accounts` for current auth user | Already used; preserve |
| `easyfleet_create_company(uuid,text,text)` | Create company and OWNER membership | Available for transporter setup |
| `easyfleet_create_vehicle(...)` | Create company vehicle | Replacement for legacy GPS device binding |
| `easyfleet_create_trip(...)` | Create company trip | Replacement for marketplace assignment/trip creation |
| `easyfleet_start_trip(...)` | Start trip with odometer and idempotency key | Replacement for `trips.stage` update |
| `easyfleet_submit_trip_closure(...)` | Submit closure/POD | Replacement for POD writes |
| `easyfleet_review_trip_closure(...)` | Approve/reject closure | No Flutter flow yet |
| `easyfleet_write_audit_event(...)` | Append audit event | Replacement for `trip_events` writes |
| `is_company_member(uuid)` / manager / operator / reviewer | Authorization helpers | Basis for derived permissions |
| `set_driver_official_verification_status(...)` | Official licence verification | **Broken**: references missing `public.driver_profiles`; do not call until fixed separately |

## Realtime mapping

Published in `supabase_realtime` after the previously approved backend fix:

- `public.fleet_trips`
- `public.driver_memberships`
- `public.trip_location_breadcrumbs`

Not published but queryable under RLS:

- `public.companies`
- `public.company_memberships`
- `public.driver_accounts`
- `public.driver_licences`
- `public.fleet_audit_events`
- `public.trip_closures`
- all other public tables

Do not assume `.stream(...)` works on unpublished tables.
