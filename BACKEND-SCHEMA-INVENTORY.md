# Backend Schema Inventory

Phase 1B audit artifact for EasyFleet. This report is a read-only snapshot of the live remote Supabase database.

## Audit metadata

| Item | Value |
|---|---|
| Project | EasyFleet (`iktekjnisqmbjtoictnc`) |
| Target | Target: project EasyFleet (iktekjnisqmbjtoictnc) · production |
| Database | `postgres` |
| PostgreSQL | `17.11` |
| Connected role | `supabase_read_only_user` |
| Search path | `"$user", public` |
| Audit date | 2026-11-23 |
| Access mode | `supabase db query --remote=... --read-only` |

> No migrations were executed and no database records were modified while preparing this report.

## Summary

| Catalog item | Count |
|---|---:|
| Public tables | 23 |
| Storage schema tables | 10 |
| Columns (public + storage) | 367 |
| Constraints (public) | 154 |
| Foreign key relationships (public) | 77 |
| Indexes (public) | 66 |
| Custom types/domains (public) | 23 |
| Enum labels (public) | 0 |
| Functions/RPCs (public) | 22 |
| Function grants (public) | 44 |
| User triggers (public) | 7 |
| RLS policies (public + storage) | 30 |
| Storage buckets | 1 |
| Realtime publications | 1 |
| Realtime published tables | 3 |

## 1. Tables

### 1.1 Public schema

| schema_name | table_name | owner | kind | row_security | force_row_security | comment |
|---|---|---|---|---|---|---|
| public | companies | postgres | r | true | false |  |
| public | company_drivers | postgres | r | true | false |  |
| public | company_memberships | postgres | r | true | false |  |
| public | driver_accounts | postgres | r | true | false |  |
| public | driver_employment_history | postgres | r | true | false |  |
| public | driver_history_access_logs | postgres | r | true | false |  |
| public | driver_history_evidence | postgres | r | true | false |  |
| public | driver_history_reviews | postgres | r | true | false |  |
| public | driver_incidents | postgres | r | true | false |  |
| public | driver_ledger_entries | postgres | r | true | false |  |
| public | driver_licences | postgres | r | true | false |  |
| public | driver_memberships | postgres | r | true | false |  |
| public | driver_verification_audit_logs | postgres | r | true | false |  |
| public | fleet_audit_events | postgres | r | true | false |  |
| public | fleet_challans | postgres | r | true | false |  |
| public | fleet_maintenance_jobs | postgres | r | true | false |  |
| public | fleet_trips | postgres | r | true | false |  |
| public | fleet_vehicle_documents | postgres | r | true | false |  |
| public | fleet_vehicles | postgres | r | true | false |  |
| public | trip_closures | postgres | r | true | false |  |
| public | trip_expenses | postgres | r | true | false |  |
| public | trip_fuel_entries | postgres | r | true | false |  |
| public | trip_location_breadcrumbs | postgres | r | true | false |  |

### 1.2 Storage schema

| schema_name | table_name | owner | kind | row_security | force_row_security | comment |
|---|---|---|---|---|---|---|
| storage | bucket_lifecycle_states | supabase_storage_admin | r | true | false |  |
| storage | buckets | supabase_storage_admin | r | true | false |  |
| storage | buckets_analytics | supabase_storage_admin | r | true | false |  |
| storage | buckets_vectors | supabase_storage_admin | r | true | false |  |
| storage | lifecycle_abandoned_artifacts | supabase_storage_admin | r | true | false |  |
| storage | migrations | supabase_storage_admin | r | true | false |  |
| storage | objects | supabase_storage_admin | r | true | false |  |
| storage | s3_multipart_uploads | supabase_storage_admin | r | true | false |  |
| storage | s3_multipart_uploads_parts | supabase_storage_admin | r | true | false |  |
| storage | vector_indexes | supabase_storage_admin | r | true | false |  |


## 2. Columns

`data_type` is rendered by `format_type(atttypid, atttypmod)`. `identity` and `generated` use PostgreSQL catalog codes (`a` = always, `n` = never, `d` = dropped; generated `s` = stored).

### 2.1 Public schema

#### `public.companies`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | companies | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | companies | 2 | name | text | text | true |  |  |  |  |
| public | companies | 3 | legal_name | text | text | false |  |  |  |  |
| public | companies | 4 | status | text | text | true | 'ACTIVE'::text |  |  |  |
| public | companies | 5 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | companies | 6 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | companies | 7 | gstin | text | text | false | ''::text |  |  |  |
| public | companies | 8 | gst_certificate_path | text | text | false | ''::text |  |  |  |

#### `public.company_drivers`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | company_drivers | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | company_drivers | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | company_drivers | 3 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | company_drivers | 4 | local_driver_code | text | text | false |  |  |  |  |
| public | company_drivers | 5 | employment_role | text | text | true | 'DRIVER'::text |  |  |  |
| public | company_drivers | 6 | created_by | uuid | uuid | false |  |  |  |  |
| public | company_drivers | 7 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.company_memberships`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | company_memberships | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | company_memberships | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | company_memberships | 3 | user_id | uuid | uuid | true |  |  |  |  |
| public | company_memberships | 4 | role | text | text | true |  |  |  |  |
| public | company_memberships | 5 | status | text | text | true | 'PENDING'::text |  |  |  |
| public | company_memberships | 6 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | company_memberships | 7 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_accounts`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_accounts | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_accounts | 2 | auth_user_id | uuid | uuid | false |  |  |  |  |
| public | driver_accounts | 3 | display_name | text | text | true | ''::text |  |  |  |
| public | driver_accounts | 4 | phone_e164 | text | text | false |  |  |  |  |
| public | driver_accounts | 5 | identity_status | text | text | true | 'PENDING'::text |  |  |  |
| public | driver_accounts | 6 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | driver_accounts | 7 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_employment_history`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_employment_history | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_employment_history | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | driver_employment_history | 3 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_employment_history | 4 | membership_id | uuid | uuid | false |  |  |  |  |
| public | driver_employment_history | 5 | employment_role | text | text | true | 'DRIVER'::text |  |  |  |
| public | driver_employment_history | 6 | started_on | date | date | false |  |  |  |  |
| public | driver_employment_history | 7 | ended_on | date | date | false |  |  |  |  |
| public | driver_employment_history | 8 | verification_status | text | text | true | 'PENDING'::text |  |  |  |
| public | driver_employment_history | 9 | verified_by | uuid | uuid | false |  |  |  |  |
| public | driver_employment_history | 10 | verified_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_employment_history | 11 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_history_access_logs`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_history_access_logs | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_history_access_logs | 2 | requesting_company_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_access_logs | 3 | requesting_user_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_access_logs | 4 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_access_logs | 5 | access_purpose | text | text | true |  |  |  |  |
| public | driver_history_access_logs | 6 | accessed_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_history_evidence`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_history_evidence | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_history_evidence | 2 | incident_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_evidence | 3 | company_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_evidence | 4 | storage_path | text | text | true |  |  |  |  |
| public | driver_history_evidence | 5 | document_type | text | text | true |  |  |  |  |
| public | driver_history_evidence | 6 | uploaded_by | uuid | uuid | true |  |  |  |  |
| public | driver_history_evidence | 7 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_history_reviews`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_history_reviews | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_history_reviews | 2 | incident_id | uuid | uuid | false |  |  |  |  |
| public | driver_history_reviews | 3 | employment_history_id | uuid | uuid | false |  |  |  |  |
| public | driver_history_reviews | 4 | reviewer_id | uuid | uuid | true |  |  |  |  |
| public | driver_history_reviews | 5 | decision | text | text | true |  |  |  |  |
| public | driver_history_reviews | 6 | reason | text | text | true |  |  |  |  |
| public | driver_history_reviews | 7 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_incidents`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_incidents | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_incidents | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | driver_incidents | 3 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_incidents | 4 | membership_id | uuid | uuid | false |  |  |  |  |
| public | driver_incidents | 5 | category | text | text | true |  |  |  |  |
| public | driver_incidents | 6 | factual_summary | text | text | true |  |  |  |  |
| public | driver_incidents | 7 | occurred_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_incidents | 8 | verification_status | text | text | true | 'PENDING'::text |  |  |  |
| public | driver_incidents | 9 | submitted_by | uuid | uuid | true |  |  |  |  |
| public | driver_incidents | 10 | verified_by | uuid | uuid | false |  |  |  |  |
| public | driver_incidents | 11 | verified_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_incidents | 12 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | driver_incidents | 13 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_ledger_entries`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_ledger_entries | 1 | id | uuid | uuid | true |  |  |  |  |
| public | driver_ledger_entries | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | driver_ledger_entries | 3 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_ledger_entries | 4 | company_driver_id | uuid | uuid | true |  |  |  |  |
| public | driver_ledger_entries | 5 | trip_id | uuid | uuid | false |  |  |  |  |
| public | driver_ledger_entries | 6 | entry_type | text | text | true |  |  |  |  |
| public | driver_ledger_entries | 7 | amount | numeric(14,2) | numeric | true |  |  |  |  |
| public | driver_ledger_entries | 8 | description | text | text | false |  |  |  |  |
| public | driver_ledger_entries | 9 | approval_status | text | text | true | 'PENDING'::text |  |  |  |
| public | driver_ledger_entries | 10 | created_by | uuid | uuid | false |  |  |  |  |
| public | driver_ledger_entries | 11 | reviewed_by | uuid | uuid | false |  |  |  |  |
| public | driver_ledger_entries | 12 | reviewed_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_ledger_entries | 13 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | driver_ledger_entries | 14 | idempotency_key | uuid | uuid | true |  |  |  |  |

#### `public.driver_licences`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_licences | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_licences | 2 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_licences | 3 | dl_fingerprint | text | text | true |  |  |  |  |
| public | driver_licences | 4 | encrypted_dl | bytea | bytea | true |  |  |  |  |
| public | driver_licences | 5 | issuing_state | text | text | false |  |  |  |  |
| public | driver_licences | 6 | licence_class | text | text | false |  |  |  |  |
| public | driver_licences | 7 | valid_from | date | date | false |  |  |  |  |
| public | driver_licences | 8 | valid_until | date | date | false |  |  |  |  |
| public | driver_licences | 9 | verification_status | text | text | true | 'PENDING'::text |  |  |  |
| public | driver_licences | 10 | verified_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_licences | 11 | verification_source | text | text | false |  |  |  |  |
| public | driver_licences | 12 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | driver_licences | 13 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_memberships`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_memberships | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_memberships | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | driver_memberships | 3 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_memberships | 4 | company_driver_id | uuid | uuid | true |  |  |  |  |
| public | driver_memberships | 5 | status | text | text | true | 'INVITED'::text |  |  |  |
| public | driver_memberships | 6 | invited_by | uuid | uuid | false |  |  |  |  |
| public | driver_memberships | 7 | approved_by | uuid | uuid | false |  |  |  |  |
| public | driver_memberships | 8 | approved_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_memberships | 9 | joined_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_memberships | 10 | left_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | driver_memberships | 11 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | driver_memberships | 12 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.driver_verification_audit_logs`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | driver_verification_audit_logs | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | driver_verification_audit_logs | 2 | driver_account_id | uuid | uuid | true |  |  |  |  |
| public | driver_verification_audit_logs | 3 | verified_by_user_id | uuid | uuid | false |  |  |  |  |
| public | driver_verification_audit_logs | 4 | company_id | uuid | uuid | false |  |  |  |  |
| public | driver_verification_audit_logs | 5 | old_status | text | text | true |  |  |  |  |
| public | driver_verification_audit_logs | 6 | new_status | text | text | true |  |  |  |  |
| public | driver_verification_audit_logs | 7 | verification_notes | text | text | false | ''::text |  |  |  |
| public | driver_verification_audit_logs | 8 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.fleet_audit_events`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_audit_events | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_audit_events | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_audit_events | 3 | entity_type | text | text | true |  |  |  |  |
| public | fleet_audit_events | 4 | entity_id | uuid | uuid | true |  |  |  |  |
| public | fleet_audit_events | 5 | event_type | text | text | true |  |  |  |  |
| public | fleet_audit_events | 6 | actor_user_id | uuid | uuid | false |  |  |  |  |
| public | fleet_audit_events | 7 | actor_driver_account_id | uuid | uuid | false |  |  |  |  |
| public | fleet_audit_events | 8 | event_time | timestamp with time zone | timestamptz | true |  |  |  |  |
| public | fleet_audit_events | 9 | received_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_audit_events | 10 | device_id | text | text | false |  |  |  |  |
| public | fleet_audit_events | 11 | idempotency_key | uuid | uuid | true |  |  |  |  |
| public | fleet_audit_events | 12 | details | jsonb | jsonb | true | '{}'::jsonb |  |  |  |

#### `public.fleet_challans`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_challans | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_challans | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_challans | 3 | vehicle_id | uuid | uuid | true |  |  |  |  |
| public | fleet_challans | 4 | challan_number | text | text | false |  |  |  |  |
| public | fleet_challans | 5 | challan_date | date | date | true |  |  |  |  |
| public | fleet_challans | 6 | reason | text | text | true |  |  |  |  |
| public | fleet_challans | 7 | amount | numeric(14,2) | numeric | true |  |  |  |  |
| public | fleet_challans | 8 | payment_status | text | text | true | 'UNPAID'::text |  |  |  |
| public | fleet_challans | 9 | paid_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_challans | 10 | storage_object_path | text | text | false |  |  |  |  |
| public | fleet_challans | 11 | notes | text | text | false |  |  |  |  |
| public | fleet_challans | 12 | created_by | uuid | uuid | false |  |  |  |  |
| public | fleet_challans | 13 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_challans | 14 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.fleet_maintenance_jobs`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_maintenance_jobs | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_maintenance_jobs | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_maintenance_jobs | 3 | vehicle_id | uuid | uuid | true |  |  |  |  |
| public | fleet_maintenance_jobs | 4 | odometer_km | bigint | int8 | false |  |  |  |  |
| public | fleet_maintenance_jobs | 5 | issue_description | text | text | true |  |  |  |  |
| public | fleet_maintenance_jobs | 6 | workshop_name | text | text | false |  |  |  |  |
| public | fleet_maintenance_jobs | 7 | workshop_location | text | text | false |  |  |  |  |
| public | fleet_maintenance_jobs | 8 | status | text | text | true | 'REPORTED'::text |  |  |  |
| public | fleet_maintenance_jobs | 9 | estimated_cost | numeric(14,2) | numeric | false |  |  |  |  |
| public | fleet_maintenance_jobs | 10 | service_bill_amount | numeric(14,2) | numeric | false |  |  |  |  |
| public | fleet_maintenance_jobs | 11 | release_odometer_km | bigint | int8 | false |  |  |  |  |
| public | fleet_maintenance_jobs | 12 | reported_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_maintenance_jobs | 13 | sent_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_maintenance_jobs | 14 | released_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_maintenance_jobs | 15 | notes | text | text | false |  |  |  |  |
| public | fleet_maintenance_jobs | 16 | created_by | uuid | uuid | false |  |  |  |  |
| public | fleet_maintenance_jobs | 17 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_maintenance_jobs | 18 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.fleet_trips`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_trips | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_trips | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_trips | 3 | gc_number | text | text | false |  |  |  |  |
| public | fleet_trips | 4 | origin | text | text | true |  |  |  |  |
| public | fleet_trips | 5 | destination | text | text | true |  |  |  |  |
| public | fleet_trips | 6 | scheduled_date | date | date | true |  |  |  |  |
| public | fleet_trips | 7 | vehicle_id | uuid | uuid | false |  |  |  |  |
| public | fleet_trips | 8 | company_driver_id | uuid | uuid | false |  |  |  |  |
| public | fleet_trips | 9 | driver_account_id | uuid | uuid | false |  |  |  |  |
| public | fleet_trips | 10 | material | text | text | false |  |  |  |  |
| public | fleet_trips | 11 | tonnes | numeric(12,3) | numeric | false |  |  |  |  |
| public | fleet_trips | 12 | freight_rate | numeric(14,2) | numeric | false |  |  |  |  |
| public | fleet_trips | 13 | bata_advance | numeric(14,2) | numeric | true | 0 |  |  |  |
| public | fleet_trips | 14 | planned_distance_km | numeric(12,2) | numeric | false |  |  |  |  |
| public | fleet_trips | 15 | starting_odometer_km | bigint | int8 | false |  |  |  |  |
| public | fleet_trips | 16 | status | text | text | true | 'PLANNED'::text |  |  |  |
| public | fleet_trips | 17 | assigned_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_trips | 18 | started_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_trips | 19 | completed_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_trips | 20 | cancelled_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | fleet_trips | 21 | cancellation_reason | text | text | false |  |  |  |  |
| public | fleet_trips | 22 | created_by | uuid | uuid | false |  |  |  |  |
| public | fleet_trips | 23 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_trips | 24 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_trips | 25 | idempotency_key | uuid | uuid | false |  |  |  |  |

#### `public.fleet_vehicle_documents`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_vehicle_documents | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_vehicle_documents | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_vehicle_documents | 3 | vehicle_id | uuid | uuid | true |  |  |  |  |
| public | fleet_vehicle_documents | 4 | document_type | text | text | true |  |  |  |  |
| public | fleet_vehicle_documents | 5 | document_number | text | text | false |  |  |  |  |
| public | fleet_vehicle_documents | 6 | issue_date | date | date | false |  |  |  |  |
| public | fleet_vehicle_documents | 7 | expiry_date | date | date | false |  |  |  |  |
| public | fleet_vehicle_documents | 8 | applicable | boolean | bool | true | true |  |  |  |
| public | fleet_vehicle_documents | 9 | storage_object_path | text | text | false |  |  |  |  |
| public | fleet_vehicle_documents | 10 | notes | text | text | false |  |  |  |  |
| public | fleet_vehicle_documents | 11 | created_by | uuid | uuid | false |  |  |  |  |
| public | fleet_vehicle_documents | 12 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_vehicle_documents | 13 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.fleet_vehicles`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | fleet_vehicles | 1 | id | uuid | uuid | true |  |  |  |  |
| public | fleet_vehicles | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | fleet_vehicles | 3 | registration_number | text | text | true |  |  |  |  |
| public | fleet_vehicles | 4 | vehicle_type | text | text | true | 'TRUCK'::text |  |  |  |
| public | fleet_vehicles | 5 | make | text | text | false |  |  |  |  |
| public | fleet_vehicles | 6 | model | text | text | false |  |  |  |  |
| public | fleet_vehicles | 7 | manufacturing_year | integer | int4 | false |  |  |  |  |
| public | fleet_vehicles | 8 | capacity_tonnes | numeric(10,2) | numeric | false |  |  |  |  |
| public | fleet_vehicles | 9 | odometer_km | bigint | int8 | false |  |  |  |  |
| public | fleet_vehicles | 10 | status | text | text | true | 'AVAILABLE'::text |  |  |  |
| public | fleet_vehicles | 11 | notes | text | text | false |  |  |  |  |
| public | fleet_vehicles | 12 | created_by | uuid | uuid | false |  |  |  |  |
| public | fleet_vehicles | 13 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | fleet_vehicles | 14 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.trip_closures`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | trip_closures | 1 | id | uuid | uuid | true |  |  |  |  |
| public | trip_closures | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | trip_closures | 3 | trip_id | uuid | uuid | true |  |  |  |  |
| public | trip_closures | 4 | submission_number | integer | int4 | true | 1 |  |  |  |
| public | trip_closures | 5 | status | text | text | true | 'SUBMITTED'::text |  |  |  |
| public | trip_closures | 6 | starting_odometer_km | bigint | int8 | false |  |  |  |  |
| public | trip_closures | 7 | closing_odometer_km | bigint | int8 | false |  |  |  |  |
| public | trip_closures | 8 | actual_distance_km | numeric(12,2) | numeric | false |  |  |  |  |
| public | trip_closures | 9 | planned_distance_km | numeric(12,2) | numeric | false |  |  |  |  |
| public | trip_closures | 10 | distance_deviation_km | numeric(12,2) | numeric | false |  |  |  |  |
| public | trip_closures | 11 | bata_earned | numeric(14,2) | numeric | true | 0 |  |  |  |
| public | trip_closures | 12 | bata_advance | numeric(14,2) | numeric | true | 0 |  |  |  |
| public | trip_closures | 13 | delivery_confirmed | boolean | bool | true | false |  |  |  |
| public | trip_closures | 14 | pod_object_path | text | text | false |  |  |  |  |
| public | trip_closures | 15 | closure_notes | text | text | false |  |  |  |  |
| public | trip_closures | 16 | submitted_by | uuid | uuid | false |  |  |  |  |
| public | trip_closures | 17 | submitted_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | trip_closures | 18 | reviewed_by | uuid | uuid | false |  |  |  |  |
| public | trip_closures | 19 | reviewed_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | trip_closures | 20 | reviewer_note | text | text | false |  |  |  |  |
| public | trip_closures | 21 | idempotency_key | uuid | uuid | true |  |  |  |  |
| public | trip_closures | 22 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.trip_expenses`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | trip_expenses | 1 | id | uuid | uuid | true |  |  |  |  |
| public | trip_expenses | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | trip_expenses | 3 | trip_id | uuid | uuid | true |  |  |  |  |
| public | trip_expenses | 4 | category | text | text | true |  |  |  |  |
| public | trip_expenses | 5 | description | text | text | false |  |  |  |  |
| public | trip_expenses | 6 | amount | numeric(14,2) | numeric | true |  |  |  |  |
| public | trip_expenses | 7 | odometer_km | bigint | int8 | false |  |  |  |  |
| public | trip_expenses | 8 | bill_reference | text | text | false |  |  |  |  |
| public | trip_expenses | 9 | receipt_object_path | text | text | false |  |  |  |  |
| public | trip_expenses | 10 | approval_status | text | text | true | 'PENDING'::text |  |  |  |
| public | trip_expenses | 11 | entered_by | uuid | uuid | false |  |  |  |  |
| public | trip_expenses | 12 | reviewed_by | uuid | uuid | false |  |  |  |  |
| public | trip_expenses | 13 | reviewed_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| public | trip_expenses | 14 | reviewer_note | text | text | false |  |  |  |  |
| public | trip_expenses | 15 | idempotency_key | uuid | uuid | true |  |  |  |  |
| public | trip_expenses | 16 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.trip_fuel_entries`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | trip_fuel_entries | 1 | id | uuid | uuid | true |  |  |  |  |
| public | trip_fuel_entries | 2 | company_id | uuid | uuid | true |  |  |  |  |
| public | trip_fuel_entries | 3 | trip_id | uuid | uuid | true |  |  |  |  |
| public | trip_fuel_entries | 4 | fuel_type | text | text | true |  |  |  |  |
| public | trip_fuel_entries | 5 | litres | numeric(12,3) | numeric | true |  |  |  |  |
| public | trip_fuel_entries | 6 | rate_per_litre | numeric(12,3) | numeric | false |  |  |  |  |
| public | trip_fuel_entries | 7 | amount | numeric(14,2) | numeric | false |  |  |  |  |
| public | trip_fuel_entries | 8 | pump_name | text | text | false |  |  |  |  |
| public | trip_fuel_entries | 9 | odometer_km | bigint | int8 | false |  |  |  |  |
| public | trip_fuel_entries | 10 | bill_reference | text | text | false |  |  |  |  |
| public | trip_fuel_entries | 11 | entry_time | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | trip_fuel_entries | 12 | entered_by | uuid | uuid | false |  |  |  |  |
| public | trip_fuel_entries | 13 | notes | text | text | false |  |  |  |  |
| public | trip_fuel_entries | 14 | idempotency_key | uuid | uuid | true |  |  |  |  |
| public | trip_fuel_entries | 15 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `public.trip_location_breadcrumbs`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| public | trip_location_breadcrumbs | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| public | trip_location_breadcrumbs | 2 | trip_id | uuid | uuid | true |  |  |  |  |
| public | trip_location_breadcrumbs | 3 | latitude | double precision | float8 | true |  |  |  |  |
| public | trip_location_breadcrumbs | 4 | longitude | double precision | float8 | true |  |  |  |  |
| public | trip_location_breadcrumbs | 5 | accuracy_meters | double precision | float8 | true | 0 |  |  |  |
| public | trip_location_breadcrumbs | 6 | recorded_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| public | trip_location_breadcrumbs | 7 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |


### 2.2 Storage schema

#### `storage.bucket_lifecycle_states`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | bucket_lifecycle_states | 1 | bucket_id | text | text | true |  |  |  |  |
| storage | bucket_lifecycle_states | 2 | generation | uuid | uuid | false |  |  |  |  |
| storage | bucket_lifecycle_states | 3 | next_run_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | bucket_lifecycle_states | 4 | claim_id | uuid | uuid | false |  |  |  |  |
| storage | bucket_lifecycle_states | 5 | claim_until | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | bucket_lifecycle_states | 6 | continuation | jsonb | jsonb | false |  |  |  |  |
| storage | bucket_lifecycle_states | 7 | last_started_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | bucket_lifecycle_states | 8 | last_completed_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | bucket_lifecycle_states | 9 | last_success_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | bucket_lifecycle_states | 10 | last_result | jsonb | jsonb | false |  |  |  |  |
| storage | bucket_lifecycle_states | 11 | failure_count | integer | int4 | true | 0 |  |  |  |
| storage | bucket_lifecycle_states | 12 | last_error | jsonb | jsonb | false |  |  |  |  |
| storage | bucket_lifecycle_states | 13 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `storage.buckets`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | buckets | 1 | id | text | text | true |  |  |  |  |
| storage | buckets | 2 | name | text | text | true |  |  |  |  |
| storage | buckets | 3 | owner | uuid | uuid | false |  |  |  | Field is deprecated, use owner_id instead |
| storage | buckets | 4 | created_at | timestamp with time zone | timestamptz | false | now() |  |  |  |
| storage | buckets | 5 | updated_at | timestamp with time zone | timestamptz | false | now() |  |  |  |
| storage | buckets | 6 | public | boolean | bool | false | false |  |  |  |
| storage | buckets | 7 | avif_autodetection | boolean | bool | false | false |  |  |  |
| storage | buckets | 8 | file_size_limit | bigint | int8 | false |  |  |  |  |
| storage | buckets | 9 | allowed_mime_types | text[] | _text | false |  |  |  |  |
| storage | buckets | 10 | owner_id | text | text | false |  |  |  |  |
| storage | buckets | 11 | type | storage.buckettype | buckettype | true | 'STANDARD'::storage.buckettype |  |  |  |
| storage | buckets | 12 | versioning_status | text | text | true | 'DISABLED'::text |  |  |  |
| storage | buckets | 13 | lifecycle_configuration | jsonb | jsonb | false |  |  |  |  |
| storage | buckets | 14 | lifecycle_configuration_generation | uuid | uuid | false |  |  |  |  |

#### `storage.buckets_analytics`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | buckets_analytics | 1 | name | text | text | true |  |  |  |  |
| storage | buckets_analytics | 2 | type | storage.buckettype | buckettype | true | 'ANALYTICS'::storage.buckettype |  |  |  |
| storage | buckets_analytics | 3 | format | text | text | true | 'ICEBERG'::text |  |  |  |
| storage | buckets_analytics | 4 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| storage | buckets_analytics | 5 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| storage | buckets_analytics | 6 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| storage | buckets_analytics | 7 | deleted_at | timestamp with time zone | timestamptz | false |  |  |  |  |

#### `storage.buckets_vectors`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | buckets_vectors | 1 | id | text | text | true |  |  |  |  |
| storage | buckets_vectors | 2 | type | storage.buckettype | buckettype | true | 'VECTOR'::storage.buckettype |  |  |  |
| storage | buckets_vectors | 3 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| storage | buckets_vectors | 4 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `storage.lifecycle_abandoned_artifacts`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | lifecycle_abandoned_artifacts | 1 | bucket_id | text | text | true |  |  |  |  |
| storage | lifecycle_abandoned_artifacts | 2 | key | text | text | true |  |  |  |  |
| storage | lifecycle_abandoned_artifacts | 3 | name | text | text | true |  |  |  |  |
| storage | lifecycle_abandoned_artifacts | 4 | version | text | text | false |  |  |  |  |
| storage | lifecycle_abandoned_artifacts | 5 | attempted_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `storage.migrations`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | migrations | 1 | id | integer | int4 | true |  |  |  |  |
| storage | migrations | 2 | name | character varying(100) | varchar | true |  |  |  |  |
| storage | migrations | 3 | hash | character varying(40) | varchar | true |  |  |  |  |
| storage | migrations | 4 | executed_at | timestamp without time zone | timestamp | false | CURRENT_TIMESTAMP |  |  |  |

#### `storage.objects`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | objects | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| storage | objects | 2 | bucket_id | text | text | false |  |  |  |  |
| storage | objects | 3 | name | text | text | false |  |  |  |  |
| storage | objects | 4 | owner | uuid | uuid | false |  |  |  | Field is deprecated, use owner_id instead |
| storage | objects | 5 | created_at | timestamp with time zone | timestamptz | false | now() |  |  |  |
| storage | objects | 6 | updated_at | timestamp with time zone | timestamptz | false | now() |  |  |  |
| storage | objects | 7 | last_accessed_at | timestamp with time zone | timestamptz | false | now() |  |  |  |
| storage | objects | 8 | metadata | jsonb | jsonb | false |  |  |  |  |
| storage | objects | 9 | path_tokens | text[] | _text | false | string_to_array(name, '/'::text) |  | s |  |
| storage | objects | 10 | version | text | text | false |  |  |  |  |
| storage | objects | 11 | owner_id | text | text | false |  |  |  |  |
| storage | objects | 12 | user_metadata | jsonb | jsonb | false |  |  |  |  |
| storage | objects | 13 | archived_at | timestamp with time zone | timestamptz | false |  |  |  |  |
| storage | objects | 14 | is_delete_marker | boolean | bool | true | false |  |  |  |
| storage | objects | 15 | is_versioned | boolean | bool | true | false |  |  |  |

#### `storage.s3_multipart_uploads`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | s3_multipart_uploads | 1 | id | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads | 2 | in_progress_size | bigint | int8 | true | 0 |  |  |  |
| storage | s3_multipart_uploads | 3 | upload_signature | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads | 4 | bucket_id | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads | 5 | key | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads | 6 | version | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads | 7 | owner_id | text | text | false |  |  |  |  |
| storage | s3_multipart_uploads | 8 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| storage | s3_multipart_uploads | 9 | user_metadata | jsonb | jsonb | false |  |  |  |  |
| storage | s3_multipart_uploads | 10 | metadata | jsonb | jsonb | false |  |  |  |  |

#### `storage.s3_multipart_uploads_parts`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | s3_multipart_uploads_parts | 1 | id | uuid | uuid | true | gen_random_uuid() |  |  |  |
| storage | s3_multipart_uploads_parts | 2 | upload_id | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 3 | size | bigint | int8 | true | 0 |  |  |  |
| storage | s3_multipart_uploads_parts | 4 | part_number | integer | int4 | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 5 | bucket_id | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 6 | key | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 7 | etag | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 8 | owner_id | text | text | false |  |  |  |  |
| storage | s3_multipart_uploads_parts | 9 | version | text | text | true |  |  |  |  |
| storage | s3_multipart_uploads_parts | 10 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |

#### `storage.vector_indexes`

| schema_name | table_name | ordinal_position | column_name | data_type | type_name | not_null | column_default | identity | generated | comment |
|---|---|---|---|---|---|---|---|---|---|---|
| storage | vector_indexes | 1 | id | text | text | true | gen_random_uuid() |  |  |  |
| storage | vector_indexes | 2 | name | text | text | true |  |  |  |  |
| storage | vector_indexes | 3 | bucket_id | text | text | true |  |  |  |  |
| storage | vector_indexes | 4 | data_type | text | text | true |  |  |  |  |
| storage | vector_indexes | 5 | dimension | integer | int4 | true |  |  |  |  |
| storage | vector_indexes | 6 | distance_metric | text | text | true |  |  |  |  |
| storage | vector_indexes | 7 | metadata_configuration | jsonb | jsonb | false |  |  |  |  |
| storage | vector_indexes | 8 | created_at | timestamp with time zone | timestamptz | true | now() |  |  |  |
| storage | vector_indexes | 9 | updated_at | timestamp with time zone | timestamptz | true | now() |  |  |  |


## 3. Constraints

Constraint type codes: `p` primary key, `u` unique, `f` foreign key, `c` check, `x` exclusion.

| schema_name | table_name | constraint_name | constraint_type | definition | deferrable | initially_deferred | validated |
|---|---|---|---|---|---|---|---|
| public | companies | companies_status_check | c | CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text]))) | false | false | true |
| public | companies | companies_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | company_drivers | company_drivers_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | company_drivers | company_drivers_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) | false | false | true |
| public | company_drivers | company_drivers_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | company_drivers | company_drivers_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | company_drivers | company_drivers_company_id_driver_account_id_key | u | UNIQUE (company_id, driver_account_id) | false | false | true |
| public | company_drivers | company_drivers_company_id_local_driver_code_key | u | UNIQUE (company_id, local_driver_code) | false | false | true |
| public | company_drivers | company_drivers_id_company_id_driver_account_id_key | u | UNIQUE (id, company_id, driver_account_id) | false | false | true |
| public | company_memberships | company_memberships_role_check | c | CHECK ((role = ANY (ARRAY['OWNER'::text, 'ADMIN'::text, 'COMPLIANCE'::text, 'DISPATCHER'::text, 'VIEWER'::text]))) | false | false | true |
| public | company_memberships | company_memberships_status_check | c | CHECK ((status = ANY (ARRAY['PENDING'::text, 'ACTIVE'::text, 'SUSPENDED'::text, 'REVOKED'::text]))) | false | false | true |
| public | company_memberships | company_memberships_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | company_memberships | company_memberships_user_id_fkey | f | FOREIGN KEY (user_id) REFERENCES auth.users(id) | false | false | true |
| public | company_memberships | company_memberships_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | company_memberships | company_memberships_company_id_user_id_key | u | UNIQUE (company_id, user_id) | false | false | true |
| public | driver_accounts | driver_accounts_identity_status_check | c | CHECK ((identity_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REVIEW_REQUIRED'::text, 'SUSPENDED'::text]))) | false | false | true |
| public | driver_accounts | driver_accounts_auth_user_id_fkey | f | FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) | false | false | true |
| public | driver_accounts | driver_accounts_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_accounts | driver_accounts_auth_user_id_key | u | UNIQUE (auth_user_id) | false | false | true |
| public | driver_employment_history | driver_employment_history_check | c | CHECK (((ended_on IS NULL) OR (started_on IS NULL) OR (ended_on >= started_on))) | false | false | true |
| public | driver_employment_history | driver_employment_history_verification_status_check | c | CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REJECTED'::text]))) | false | false | true |
| public | driver_employment_history | driver_employment_history_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | driver_employment_history | driver_employment_history_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | driver_employment_history | driver_employment_history_verified_by_fkey | f | FOREIGN KEY (verified_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_employment_history | driver_employment_membership_identity_fk | f | FOREIGN KEY (membership_id, company_id, driver_account_id) REFERENCES driver_memberships(id, company_id, driver_account_id) | false | false | true |
| public | driver_employment_history | driver_employment_history_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_requesting_company_id_fkey | f | FOREIGN KEY (requesting_company_id) REFERENCES companies(id) | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_requesting_user_id_fkey | f | FOREIGN KEY (requesting_user_id) REFERENCES auth.users(id) | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_history_evidence | driver_history_evidence_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | driver_history_evidence | driver_history_evidence_incident_company_fk | f | FOREIGN KEY (incident_id, company_id) REFERENCES driver_incidents(id, company_id) | false | false | true |
| public | driver_history_evidence | driver_history_evidence_uploaded_by_fkey | f | FOREIGN KEY (uploaded_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_history_evidence | driver_history_evidence_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_history_evidence | driver_history_evidence_company_id_storage_path_key | u | UNIQUE (company_id, storage_path) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_check | c | CHECK ((((incident_id IS NOT NULL) AND (employment_history_id IS NULL)) OR ((incident_id IS NULL) AND (employment_history_id IS NOT NULL)))) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_decision_check | c | CHECK ((decision = ANY (ARRAY['VERIFIED'::text, 'REJECTED'::text, 'REQUEST_MORE_EVIDENCE'::text, 'CORRECTED'::text, 'WITHDRAWN'::text]))) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_employment_history_id_fkey | f | FOREIGN KEY (employment_history_id) REFERENCES driver_employment_history(id) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_incident_id_fkey | f | FOREIGN KEY (incident_id) REFERENCES driver_incidents(id) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_reviewer_id_fkey | f | FOREIGN KEY (reviewer_id) REFERENCES auth.users(id) | false | false | true |
| public | driver_history_reviews | driver_history_reviews_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_incidents | driver_incidents_category_check | c | CHECK ((category = ANY (ARRAY['ACCIDENT'::text, 'VEHICLE_DAMAGE'::text, 'SAFETY'::text, 'COMPLIANCE'::text, 'DOCUMENTATION'::text, 'OTHER'::text]))) | false | false | true |
| public | driver_incidents | driver_incidents_check | c | CHECK (((verification_status <> 'VERIFIED'::text) OR ((verified_by IS NOT NULL) AND (verified_at IS NOT NULL) AND (verified_by <> submitted_by)))) | false | false | true |
| public | driver_incidents | driver_incidents_verification_status_check | c | CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'UNDER_REVIEW'::text, 'VERIFIED'::text, 'REJECTED'::text, 'WITHDRAWN'::text, 'CORRECTED'::text]))) | false | false | true |
| public | driver_incidents | driver_incidents_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | driver_incidents | driver_incidents_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | driver_incidents | driver_incidents_membership_identity_fk | f | FOREIGN KEY (membership_id, company_id, driver_account_id) REFERENCES driver_memberships(id, company_id, driver_account_id) | false | false | true |
| public | driver_incidents | driver_incidents_submitted_by_fkey | f | FOREIGN KEY (submitted_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_incidents | driver_incidents_verified_by_fkey | f | FOREIGN KEY (verified_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_incidents | driver_incidents_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_incidents | driver_incidents_id_company_id_key | u | UNIQUE (id, company_id) | false | false | true |
| public | driver_ledger_entries | driver_ledger_amount_nonnegative | c | CHECK ((amount >= (0)::numeric)) | false | false | true |
| public | driver_ledger_entries | driver_ledger_approval_check | c | CHECK ((approval_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text]))) | false | false | true |
| public | driver_ledger_entries | driver_ledger_entry_type_check | c | CHECK ((entry_type = ANY (ARRAY['BATA_EARNED'::text, 'ADVANCE'::text, 'APPROVED_DEDUCTION'::text, 'PAYMENT'::text, 'ADJUSTMENT'::text]))) | false | false | true |
| public | driver_ledger_entries | driver_ledger_company_driver_fk | f | FOREIGN KEY (company_driver_id, company_id, driver_account_id) REFERENCES company_drivers(id, company_id, driver_account_id) ON DELETE RESTRICT | false | false | true |
| public | driver_ledger_entries | driver_ledger_entries_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | driver_ledger_entries | driver_ledger_entries_reviewed_by_fkey | f | FOREIGN KEY (reviewed_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | driver_ledger_entries | driver_ledger_trip_company_fk | f | FOREIGN KEY (trip_id, company_id) REFERENCES fleet_trips(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | driver_ledger_entries | driver_ledger_entries_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_ledger_entries | driver_ledger_company_idempotency_key | u | UNIQUE (company_id, idempotency_key) | false | false | true |
| public | driver_licences | driver_licences_verification_status_check | c | CHECK ((verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'FAILED'::text, 'EXPIRED'::text, 'REVIEW_REQUIRED'::text]))) | false | false | true |
| public | driver_licences | driver_licences_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | driver_licences | driver_licences_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_licences | driver_licences_dl_fingerprint_key | u | UNIQUE (dl_fingerprint) | false | false | true |
| public | driver_licences | driver_licences_driver_account_id_key | u | UNIQUE (driver_account_id) | false | false | true |
| public | driver_memberships | driver_memberships_status_check | c | CHECK ((status = ANY (ARRAY['INVITED'::text, 'PENDING_APPROVAL'::text, 'APPROVED'::text, 'REJECTED'::text, 'SUSPENDED'::text, 'REVOKED'::text]))) | false | false | true |
| public | driver_memberships | driver_memberships_approved_by_fkey | f | FOREIGN KEY (approved_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_memberships | driver_memberships_company_driver_fk | f | FOREIGN KEY (company_driver_id, company_id, driver_account_id) REFERENCES company_drivers(id, company_id, driver_account_id) | false | false | true |
| public | driver_memberships | driver_memberships_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) | false | false | true |
| public | driver_memberships | driver_memberships_driver_account_id_fkey | f | FOREIGN KEY (driver_account_id) REFERENCES driver_accounts(id) | false | false | true |
| public | driver_memberships | driver_memberships_invited_by_fkey | f | FOREIGN KEY (invited_by) REFERENCES auth.users(id) | false | false | true |
| public | driver_memberships | driver_memberships_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | driver_memberships | driver_memberships_company_id_driver_account_id_key | u | UNIQUE (company_id, driver_account_id) | false | false | true |
| public | driver_memberships | driver_memberships_id_company_id_driver_account_id_key | u | UNIQUE (id, company_id, driver_account_id) | false | false | true |
| public | driver_verification_audit_logs | driver_verification_audit_logs_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_audit_events | fleet_audit_events_details_object | c | CHECK ((jsonb_typeof(details) = 'object'::text)) | false | false | true |
| public | fleet_audit_events | fleet_audit_events_actor_driver_account_id_fkey | f | FOREIGN KEY (actor_driver_account_id) REFERENCES driver_accounts(id) ON DELETE SET NULL | false | false | true |
| public | fleet_audit_events | fleet_audit_events_actor_user_id_fkey | f | FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_audit_events | fleet_audit_events_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT | false | false | true |
| public | fleet_audit_events | fleet_audit_events_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_audit_events | fleet_audit_events_company_idempotency_key | u | UNIQUE (company_id, idempotency_key) | false | false | true |
| public | fleet_challans | fleet_challans_amount_nonnegative | c | CHECK ((amount >= (0)::numeric)) | false | false | true |
| public | fleet_challans | fleet_challans_payment_status_check | c | CHECK ((payment_status = ANY (ARRAY['UNPAID'::text, 'PAID'::text, 'DISPUTED'::text, 'WAIVED'::text]))) | false | false | true |
| public | fleet_challans | fleet_challans_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_challans | fleet_challans_vehicle_company_fk | f | FOREIGN KEY (vehicle_id, company_id) REFERENCES fleet_vehicles(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | fleet_challans | fleet_challans_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_amounts_nonnegative | c | CHECK ((((estimated_cost IS NULL) OR (estimated_cost >= (0)::numeric)) AND ((service_bill_amount IS NULL) OR (service_bill_amount >= (0)::numeric)))) | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_odometers_nonnegative | c | CHECK ((((odometer_km IS NULL) OR (odometer_km >= 0)) AND ((release_odometer_km IS NULL) OR (release_odometer_km >= 0)))) | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_status_check | c | CHECK ((status = ANY (ARRAY['REPORTED'::text, 'SENT'::text, 'IN_PROGRESS'::text, 'READY'::text, 'RELEASED'::text, 'CANCELLED'::text]))) | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_vehicle_company_fk | f | FOREIGN KEY (vehicle_id, company_id) REFERENCES fleet_vehicles(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_trips | fleet_trips_bata_nonnegative | c | CHECK ((bata_advance >= (0)::numeric)) | false | false | true |
| public | fleet_trips | fleet_trips_destination_nonempty | c | CHECK ((length(TRIM(BOTH FROM destination)) > 0)) | false | false | true |
| public | fleet_trips | fleet_trips_distance_nonnegative | c | CHECK (((planned_distance_km IS NULL) OR (planned_distance_km >= (0)::numeric))) | false | false | true |
| public | fleet_trips | fleet_trips_driver_pair_check | c | CHECK ((((company_driver_id IS NULL) AND (driver_account_id IS NULL)) OR ((company_driver_id IS NOT NULL) AND (driver_account_id IS NOT NULL)))) | false | false | true |
| public | fleet_trips | fleet_trips_freight_nonnegative | c | CHECK (((freight_rate IS NULL) OR (freight_rate >= (0)::numeric))) | false | false | true |
| public | fleet_trips | fleet_trips_origin_nonempty | c | CHECK ((length(TRIM(BOTH FROM origin)) > 0)) | false | false | true |
| public | fleet_trips | fleet_trips_start_odometer_nonnegative | c | CHECK (((starting_odometer_km IS NULL) OR (starting_odometer_km >= 0))) | false | false | true |
| public | fleet_trips | fleet_trips_status_check | c | CHECK ((status = ANY (ARRAY['PLANNED'::text, 'ASSIGNED'::text, 'IN_TRANSIT'::text, 'CLOSURE_PENDING'::text, 'COMPLETED'::text, 'CANCELLED'::text]))) | false | false | true |
| public | fleet_trips | fleet_trips_tonnes_nonnegative | c | CHECK (((tonnes IS NULL) OR (tonnes >= (0)::numeric))) | false | false | true |
| public | fleet_trips | fleet_trips_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT | false | false | true |
| public | fleet_trips | fleet_trips_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_trips | fleet_trips_driver_company_fk | f | FOREIGN KEY (company_driver_id, company_id, driver_account_id) REFERENCES company_drivers(id, company_id, driver_account_id) ON DELETE RESTRICT | false | false | true |
| public | fleet_trips | fleet_trips_vehicle_company_fk | f | FOREIGN KEY (vehicle_id, company_id) REFERENCES fleet_vehicles(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | fleet_trips | fleet_trips_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_trips | fleet_trips_id_company_key | u | UNIQUE (id, company_id) | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_dates_check | c | CHECK (((issue_date IS NULL) OR (expiry_date IS NULL) OR (expiry_date >= issue_date))) | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_type_check | c | CHECK ((document_type = ANY (ARRAY['RC'::text, 'INSURANCE'::text, 'FITNESS'::text, 'PERMIT'::text, 'PUC'::text, 'TAX'::text, 'OTHER'::text]))) | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_vehicle_company_fk | f | FOREIGN KEY (vehicle_id, company_id) REFERENCES fleet_vehicles(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_capacity_positive | c | CHECK (((capacity_tonnes IS NULL) OR (capacity_tonnes > (0)::numeric))) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_odometer_nonnegative | c | CHECK ((odometer_km >= 0)) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_registration_nonempty | c | CHECK ((length(TRIM(BOTH FROM registration_number)) > 0)) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_status_check | c | CHECK ((status = ANY (ARRAY['AVAILABLE'::text, 'ASSIGNED'::text, 'ON_TRIP'::text, 'IN_MAINTENANCE'::text, 'INACTIVE'::text]))) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_type_check | c | CHECK ((vehicle_type = ANY (ARRAY['TRUCK'::text, 'TRAILER'::text, 'TANKER'::text, 'CONTAINER'::text, 'VAN'::text, 'OTHER'::text]))) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_year_valid | c | CHECK (((manufacturing_year IS NULL) OR ((manufacturing_year >= 1950) AND (manufacturing_year <= 2100)))) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_company_id_fkey | f | FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT | false | false | true |
| public | fleet_vehicles | fleet_vehicles_created_by_fkey | f | FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | fleet_vehicles | fleet_vehicles_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_company_registration_key | u | UNIQUE (company_id, registration_number) | false | false | true |
| public | fleet_vehicles | fleet_vehicles_id_company_key | u | UNIQUE (id, company_id) | false | false | true |
| public | trip_closures | trip_closures_amounts_nonnegative | c | CHECK (((bata_earned >= (0)::numeric) AND (bata_advance >= (0)::numeric))) | false | false | true |
| public | trip_closures | trip_closures_distance_nonnegative | c | CHECK ((((actual_distance_km IS NULL) OR (actual_distance_km >= (0)::numeric)) AND ((planned_distance_km IS NULL) OR (planned_distance_km >= (0)::numeric)))) | false | false | true |
| public | trip_closures | trip_closures_odometer_nonnegative | c | CHECK ((((starting_odometer_km IS NULL) OR (starting_odometer_km >= 0)) AND ((closing_odometer_km IS NULL) OR (closing_odometer_km >= 0)))) | false | false | true |
| public | trip_closures | trip_closures_odometer_order | c | CHECK (((starting_odometer_km IS NULL) OR (closing_odometer_km IS NULL) OR (closing_odometer_km >= starting_odometer_km))) | false | false | true |
| public | trip_closures | trip_closures_status_check | c | CHECK ((status = ANY (ARRAY['SUBMITTED'::text, 'APPROVED'::text, 'REJECTED'::text, 'VOID'::text]))) | false | false | true |
| public | trip_closures | trip_closures_submission_positive | c | CHECK ((submission_number > 0)) | false | false | true |
| public | trip_closures | trip_closures_reviewed_by_fkey | f | FOREIGN KEY (reviewed_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | trip_closures | trip_closures_submitted_by_fkey | f | FOREIGN KEY (submitted_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | trip_closures | trip_closures_trip_company_fk | f | FOREIGN KEY (trip_id, company_id) REFERENCES fleet_trips(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | trip_closures | trip_closures_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | trip_closures | trip_closures_company_idempotency_key | u | UNIQUE (company_id, idempotency_key) | false | false | true |
| public | trip_closures | trip_closures_trip_submission_key | u | UNIQUE (trip_id, submission_number) | false | false | true |
| public | trip_expenses | trip_expenses_amount_nonnegative | c | CHECK ((amount >= (0)::numeric)) | false | false | true |
| public | trip_expenses | trip_expenses_approval_check | c | CHECK ((approval_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text]))) | false | false | true |
| public | trip_expenses | trip_expenses_odometer_nonnegative | c | CHECK (((odometer_km IS NULL) OR (odometer_km >= 0))) | false | false | true |
| public | trip_expenses | trip_expenses_entered_by_fkey | f | FOREIGN KEY (entered_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | trip_expenses | trip_expenses_reviewed_by_fkey | f | FOREIGN KEY (reviewed_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | trip_expenses | trip_expenses_trip_company_fk | f | FOREIGN KEY (trip_id, company_id) REFERENCES fleet_trips(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | trip_expenses | trip_expenses_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | trip_expenses | trip_expenses_company_idempotency_key | u | UNIQUE (company_id, idempotency_key) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_amount_nonnegative | c | CHECK (((amount IS NULL) OR (amount >= (0)::numeric))) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_litres_positive | c | CHECK ((litres > (0)::numeric)) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_odometer_nonnegative | c | CHECK (((odometer_km IS NULL) OR (odometer_km >= 0))) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_rate_nonnegative | c | CHECK (((rate_per_litre IS NULL) OR (rate_per_litre >= (0)::numeric))) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_type_check | c | CHECK ((fuel_type = ANY (ARRAY['DIESEL'::text, 'ADBLUE'::text]))) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_entered_by_fkey | f | FOREIGN KEY (entered_by) REFERENCES auth.users(id) ON DELETE SET NULL | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_trip_company_fk | f | FOREIGN KEY (trip_id, company_id) REFERENCES fleet_trips(id, company_id) ON DELETE RESTRICT | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_pkey | p | PRIMARY KEY (id) | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_company_idempotency_key | u | UNIQUE (company_id, idempotency_key) | false | false | true |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_trip_id_fkey | f | FOREIGN KEY (trip_id) REFERENCES fleet_trips(id) ON DELETE CASCADE | false | false | true |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_pkey | p | PRIMARY KEY (id) | false | false | true |


## 4. Foreign key relationships

Update/delete action codes follow `pg_constraint.confupdtype` / `confdeltype` (`a` no action, `r` restrict, `c` cascade, `n` set null, `d` set default).

| schema_name | table_name | constraint_name | column_name | foreign_table_name | foreign_column_name | on_update_code | on_delete_code | deferrable | initially_deferred | validated |
|---|---|---|---|---|---|---|---|---|---|---|
| public | company_drivers | company_drivers_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | company_drivers | company_drivers_created_by_fkey | created_by | users | id | a | a | false | false | true |
| public | company_drivers | company_drivers_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | company_memberships | company_memberships_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | company_memberships | company_memberships_user_id_fkey | user_id | users | id | a | a | false | false | true |
| public | driver_accounts | driver_accounts_auth_user_id_fkey | auth_user_id | users | id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_history_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_history_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_history_verified_by_fkey | verified_by | users | id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_membership_identity_fk | membership_id | driver_memberships | id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_membership_identity_fk | company_id | driver_memberships | company_id | a | a | false | false | true |
| public | driver_employment_history | driver_employment_membership_identity_fk | driver_account_id | driver_memberships | driver_account_id | a | a | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_requesting_company_id_fkey | requesting_company_id | companies | id | a | a | false | false | true |
| public | driver_history_access_logs | driver_history_access_logs_requesting_user_id_fkey | requesting_user_id | users | id | a | a | false | false | true |
| public | driver_history_evidence | driver_history_evidence_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | driver_history_evidence | driver_history_evidence_incident_company_fk | incident_id | driver_incidents | id | a | a | false | false | true |
| public | driver_history_evidence | driver_history_evidence_incident_company_fk | company_id | driver_incidents | company_id | a | a | false | false | true |
| public | driver_history_evidence | driver_history_evidence_uploaded_by_fkey | uploaded_by | users | id | a | a | false | false | true |
| public | driver_history_reviews | driver_history_reviews_employment_history_id_fkey | employment_history_id | driver_employment_history | id | a | a | false | false | true |
| public | driver_history_reviews | driver_history_reviews_incident_id_fkey | incident_id | driver_incidents | id | a | a | false | false | true |
| public | driver_history_reviews | driver_history_reviews_reviewer_id_fkey | reviewer_id | users | id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_membership_identity_fk | membership_id | driver_memberships | id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_membership_identity_fk | company_id | driver_memberships | company_id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_membership_identity_fk | driver_account_id | driver_memberships | driver_account_id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_submitted_by_fkey | submitted_by | users | id | a | a | false | false | true |
| public | driver_incidents | driver_incidents_verified_by_fkey | verified_by | users | id | a | a | false | false | true |
| public | driver_ledger_entries | driver_ledger_company_driver_fk | company_driver_id | company_drivers | id | a | r | false | false | true |
| public | driver_ledger_entries | driver_ledger_company_driver_fk | company_id | company_drivers | company_id | a | r | false | false | true |
| public | driver_ledger_entries | driver_ledger_company_driver_fk | driver_account_id | company_drivers | driver_account_id | a | r | false | false | true |
| public | driver_ledger_entries | driver_ledger_entries_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | driver_ledger_entries | driver_ledger_entries_reviewed_by_fkey | reviewed_by | users | id | a | n | false | false | true |
| public | driver_ledger_entries | driver_ledger_trip_company_fk | trip_id | fleet_trips | id | a | r | false | false | true |
| public | driver_ledger_entries | driver_ledger_trip_company_fk | company_id | fleet_trips | company_id | a | r | false | false | true |
| public | driver_licences | driver_licences_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_approved_by_fkey | approved_by | users | id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_company_driver_fk | company_driver_id | company_drivers | id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_company_driver_fk | company_id | company_drivers | company_id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_company_driver_fk | driver_account_id | company_drivers | driver_account_id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_company_id_fkey | company_id | companies | id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_driver_account_id_fkey | driver_account_id | driver_accounts | id | a | a | false | false | true |
| public | driver_memberships | driver_memberships_invited_by_fkey | invited_by | users | id | a | a | false | false | true |
| public | fleet_audit_events | fleet_audit_events_actor_driver_account_id_fkey | actor_driver_account_id | driver_accounts | id | a | n | false | false | true |
| public | fleet_audit_events | fleet_audit_events_actor_user_id_fkey | actor_user_id | users | id | a | n | false | false | true |
| public | fleet_audit_events | fleet_audit_events_company_id_fkey | company_id | companies | id | a | r | false | false | true |
| public | fleet_challans | fleet_challans_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | fleet_challans | fleet_challans_vehicle_company_fk | vehicle_id | fleet_vehicles | id | a | r | false | false | true |
| public | fleet_challans | fleet_challans_vehicle_company_fk | company_id | fleet_vehicles | company_id | a | r | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_vehicle_company_fk | vehicle_id | fleet_vehicles | id | a | r | false | false | true |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_vehicle_company_fk | company_id | fleet_vehicles | company_id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_company_id_fkey | company_id | companies | id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | fleet_trips | fleet_trips_driver_company_fk | company_driver_id | company_drivers | id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_driver_company_fk | company_id | company_drivers | company_id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_driver_company_fk | driver_account_id | company_drivers | driver_account_id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_vehicle_company_fk | vehicle_id | fleet_vehicles | id | a | r | false | false | true |
| public | fleet_trips | fleet_trips_vehicle_company_fk | company_id | fleet_vehicles | company_id | a | r | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_vehicle_company_fk | vehicle_id | fleet_vehicles | id | a | r | false | false | true |
| public | fleet_vehicle_documents | fleet_vehicle_documents_vehicle_company_fk | company_id | fleet_vehicles | company_id | a | r | false | false | true |
| public | fleet_vehicles | fleet_vehicles_company_id_fkey | company_id | companies | id | a | r | false | false | true |
| public | fleet_vehicles | fleet_vehicles_created_by_fkey | created_by | users | id | a | n | false | false | true |
| public | trip_closures | trip_closures_reviewed_by_fkey | reviewed_by | users | id | a | n | false | false | true |
| public | trip_closures | trip_closures_submitted_by_fkey | submitted_by | users | id | a | n | false | false | true |
| public | trip_closures | trip_closures_trip_company_fk | trip_id | fleet_trips | id | a | r | false | false | true |
| public | trip_closures | trip_closures_trip_company_fk | company_id | fleet_trips | company_id | a | r | false | false | true |
| public | trip_expenses | trip_expenses_entered_by_fkey | entered_by | users | id | a | n | false | false | true |
| public | trip_expenses | trip_expenses_reviewed_by_fkey | reviewed_by | users | id | a | n | false | false | true |
| public | trip_expenses | trip_expenses_trip_company_fk | trip_id | fleet_trips | id | a | r | false | false | true |
| public | trip_expenses | trip_expenses_trip_company_fk | company_id | fleet_trips | company_id | a | r | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_entered_by_fkey | entered_by | users | id | a | n | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_trip_company_fk | trip_id | fleet_trips | id | a | r | false | false | true |
| public | trip_fuel_entries | trip_fuel_entries_trip_company_fk | company_id | fleet_trips | company_id | a | r | false | false | true |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_trip_id_fkey | trip_id | fleet_trips | id | a | c | false | false | true |


## 5. Indexes

| schema_name | table_name | index_name | is_unique | is_primary | is_valid | is_ready | definition |
|---|---|---|---|---|---|---|---|
| public | companies | companies_pkey | true | true | true | true | CREATE UNIQUE INDEX companies_pkey ON public.companies USING btree (id) |
| public | companies | idx_companies_gstin_unique | true | false | true | true | CREATE UNIQUE INDEX idx_companies_gstin_unique ON public.companies USING btree (upper(gstin)) WHERE ((gstin IS NOT NULL) AND (length(TRIM(BOTH FROM gstin)) > 0)) |
| public | company_drivers | company_drivers_company_id_driver_account_id_key | true | false | true | true | CREATE UNIQUE INDEX company_drivers_company_id_driver_account_id_key ON public.company_drivers USING btree (company_id, driver_account_id) |
| public | company_drivers | company_drivers_company_id_local_driver_code_key | true | false | true | true | CREATE UNIQUE INDEX company_drivers_company_id_local_driver_code_key ON public.company_drivers USING btree (company_id, local_driver_code) |
| public | company_drivers | company_drivers_id_company_id_driver_account_id_key | true | false | true | true | CREATE UNIQUE INDEX company_drivers_id_company_id_driver_account_id_key ON public.company_drivers USING btree (id, company_id, driver_account_id) |
| public | company_drivers | company_drivers_pkey | true | true | true | true | CREATE UNIQUE INDEX company_drivers_pkey ON public.company_drivers USING btree (id) |
| public | company_memberships | company_memberships_company_id_user_id_key | true | false | true | true | CREATE UNIQUE INDEX company_memberships_company_id_user_id_key ON public.company_memberships USING btree (company_id, user_id) |
| public | company_memberships | company_memberships_pkey | true | true | true | true | CREATE UNIQUE INDEX company_memberships_pkey ON public.company_memberships USING btree (id) |
| public | driver_accounts | driver_accounts_auth_user_id_key | true | false | true | true | CREATE UNIQUE INDEX driver_accounts_auth_user_id_key ON public.driver_accounts USING btree (auth_user_id) |
| public | driver_accounts | driver_accounts_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_accounts_pkey ON public.driver_accounts USING btree (id) |
| public | driver_employment_history | driver_employment_history_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_employment_history_pkey ON public.driver_employment_history USING btree (id) |
| public | driver_employment_history | idx_driver_employment_history_driver | false | false | true | true | CREATE INDEX idx_driver_employment_history_driver ON public.driver_employment_history USING btree (driver_account_id, verification_status) |
| public | driver_history_access_logs | driver_history_access_logs_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_history_access_logs_pkey ON public.driver_history_access_logs USING btree (id) |
| public | driver_history_access_logs | idx_driver_history_access_driver | false | false | true | true | CREATE INDEX idx_driver_history_access_driver ON public.driver_history_access_logs USING btree (driver_account_id, accessed_at DESC) |
| public | driver_history_evidence | driver_history_evidence_company_id_storage_path_key | true | false | true | true | CREATE UNIQUE INDEX driver_history_evidence_company_id_storage_path_key ON public.driver_history_evidence USING btree (company_id, storage_path) |
| public | driver_history_evidence | driver_history_evidence_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_history_evidence_pkey ON public.driver_history_evidence USING btree (id) |
| public | driver_history_reviews | driver_history_reviews_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_history_reviews_pkey ON public.driver_history_reviews USING btree (id) |
| public | driver_incidents | driver_incidents_id_company_id_key | true | false | true | true | CREATE UNIQUE INDEX driver_incidents_id_company_id_key ON public.driver_incidents USING btree (id, company_id) |
| public | driver_incidents | driver_incidents_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_incidents_pkey ON public.driver_incidents USING btree (id) |
| public | driver_incidents | idx_driver_incidents_company | false | false | true | true | CREATE INDEX idx_driver_incidents_company ON public.driver_incidents USING btree (company_id, created_at DESC) |
| public | driver_incidents | idx_driver_incidents_history | false | false | true | true | CREATE INDEX idx_driver_incidents_history ON public.driver_incidents USING btree (driver_account_id, verification_status) |
| public | driver_ledger_entries | driver_ledger_company_driver_date_idx | false | false | true | true | CREATE INDEX driver_ledger_company_driver_date_idx ON public.driver_ledger_entries USING btree (company_id, driver_account_id, created_at DESC) |
| public | driver_ledger_entries | driver_ledger_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX driver_ledger_company_idempotency_key ON public.driver_ledger_entries USING btree (company_id, idempotency_key) |
| public | driver_ledger_entries | driver_ledger_entries_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_ledger_entries_pkey ON public.driver_ledger_entries USING btree (id) |
| public | driver_licences | driver_licences_dl_fingerprint_key | true | false | true | true | CREATE UNIQUE INDEX driver_licences_dl_fingerprint_key ON public.driver_licences USING btree (dl_fingerprint) |
| public | driver_licences | driver_licences_driver_account_id_key | true | false | true | true | CREATE UNIQUE INDEX driver_licences_driver_account_id_key ON public.driver_licences USING btree (driver_account_id) |
| public | driver_licences | driver_licences_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_licences_pkey ON public.driver_licences USING btree (id) |
| public | driver_memberships | driver_memberships_company_id_driver_account_id_key | true | false | true | true | CREATE UNIQUE INDEX driver_memberships_company_id_driver_account_id_key ON public.driver_memberships USING btree (company_id, driver_account_id) |
| public | driver_memberships | driver_memberships_id_company_id_driver_account_id_key | true | false | true | true | CREATE UNIQUE INDEX driver_memberships_id_company_id_driver_account_id_key ON public.driver_memberships USING btree (id, company_id, driver_account_id) |
| public | driver_memberships | driver_memberships_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_memberships_pkey ON public.driver_memberships USING btree (id) |
| public | driver_memberships | idx_driver_memberships_company | false | false | true | true | CREATE INDEX idx_driver_memberships_company ON public.driver_memberships USING btree (company_id, status) |
| public | driver_memberships | idx_driver_memberships_driver | false | false | true | true | CREATE INDEX idx_driver_memberships_driver ON public.driver_memberships USING btree (driver_account_id, status) |
| public | driver_verification_audit_logs | driver_verification_audit_logs_pkey | true | true | true | true | CREATE UNIQUE INDEX driver_verification_audit_logs_pkey ON public.driver_verification_audit_logs USING btree (id) |
| public | fleet_audit_events | fleet_audit_events_company_entity_idx | false | false | true | true | CREATE INDEX fleet_audit_events_company_entity_idx ON public.fleet_audit_events USING btree (company_id, entity_type, entity_id, received_at DESC) |
| public | fleet_audit_events | fleet_audit_events_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX fleet_audit_events_company_idempotency_key ON public.fleet_audit_events USING btree (company_id, idempotency_key) |
| public | fleet_audit_events | fleet_audit_events_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_audit_events_pkey ON public.fleet_audit_events USING btree (id) |
| public | fleet_challans | fleet_challans_company_vehicle_date_idx | false | false | true | true | CREATE INDEX fleet_challans_company_vehicle_date_idx ON public.fleet_challans USING btree (company_id, vehicle_id, challan_date DESC) |
| public | fleet_challans | fleet_challans_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_challans_pkey ON public.fleet_challans USING btree (id) |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_company_status_idx | false | false | true | true | CREATE INDEX fleet_maintenance_jobs_company_status_idx ON public.fleet_maintenance_jobs USING btree (company_id, status, reported_at DESC) |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_maintenance_jobs_pkey ON public.fleet_maintenance_jobs USING btree (id) |
| public | fleet_trips | fleet_trips_company_driver_idx | false | false | true | true | CREATE INDEX fleet_trips_company_driver_idx ON public.fleet_trips USING btree (company_id, driver_account_id) |
| public | fleet_trips | fleet_trips_company_gc_unique | true | false | true | true | CREATE UNIQUE INDEX fleet_trips_company_gc_unique ON public.fleet_trips USING btree (company_id, gc_number) WHERE ((gc_number IS NOT NULL) AND (length(TRIM(BOTH FROM gc_number)) > 0)) |
| public | fleet_trips | fleet_trips_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX fleet_trips_company_idempotency_key ON public.fleet_trips USING btree (company_id, idempotency_key) WHERE (idempotency_key IS NOT NULL) |
| public | fleet_trips | fleet_trips_company_status_date_idx | false | false | true | true | CREATE INDEX fleet_trips_company_status_date_idx ON public.fleet_trips USING btree (company_id, status, scheduled_date DESC) |
| public | fleet_trips | fleet_trips_company_vehicle_idx | false | false | true | true | CREATE INDEX fleet_trips_company_vehicle_idx ON public.fleet_trips USING btree (company_id, vehicle_id) |
| public | fleet_trips | fleet_trips_id_company_key | true | false | true | true | CREATE UNIQUE INDEX fleet_trips_id_company_key ON public.fleet_trips USING btree (id, company_id) |
| public | fleet_trips | fleet_trips_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_trips_pkey ON public.fleet_trips USING btree (id) |
| public | fleet_vehicle_documents | fleet_vehicle_documents_company_expiry_idx | false | false | true | true | CREATE INDEX fleet_vehicle_documents_company_expiry_idx ON public.fleet_vehicle_documents USING btree (company_id, expiry_date) WHERE (applicable = true) |
| public | fleet_vehicle_documents | fleet_vehicle_documents_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_vehicle_documents_pkey ON public.fleet_vehicle_documents USING btree (id) |
| public | fleet_vehicles | fleet_vehicles_company_registration_key | true | false | true | true | CREATE UNIQUE INDEX fleet_vehicles_company_registration_key ON public.fleet_vehicles USING btree (company_id, registration_number) |
| public | fleet_vehicles | fleet_vehicles_id_company_key | true | false | true | true | CREATE UNIQUE INDEX fleet_vehicles_id_company_key ON public.fleet_vehicles USING btree (id, company_id) |
| public | fleet_vehicles | fleet_vehicles_pkey | true | true | true | true | CREATE UNIQUE INDEX fleet_vehicles_pkey ON public.fleet_vehicles USING btree (id) |
| public | trip_closures | trip_closures_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX trip_closures_company_idempotency_key ON public.trip_closures USING btree (company_id, idempotency_key) |
| public | trip_closures | trip_closures_company_status_idx | false | false | true | true | CREATE INDEX trip_closures_company_status_idx ON public.trip_closures USING btree (company_id, status, submitted_at DESC) |
| public | trip_closures | trip_closures_one_pending_per_trip | true | false | true | true | CREATE UNIQUE INDEX trip_closures_one_pending_per_trip ON public.trip_closures USING btree (trip_id) WHERE (status = 'SUBMITTED'::text) |
| public | trip_closures | trip_closures_pkey | true | true | true | true | CREATE UNIQUE INDEX trip_closures_pkey ON public.trip_closures USING btree (id) |
| public | trip_closures | trip_closures_trip_idx | false | false | true | true | CREATE INDEX trip_closures_trip_idx ON public.trip_closures USING btree (trip_id, submitted_at DESC) |
| public | trip_closures | trip_closures_trip_submission_key | true | false | true | true | CREATE UNIQUE INDEX trip_closures_trip_submission_key ON public.trip_closures USING btree (trip_id, submission_number) |
| public | trip_expenses | trip_expenses_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX trip_expenses_company_idempotency_key ON public.trip_expenses USING btree (company_id, idempotency_key) |
| public | trip_expenses | trip_expenses_company_trip_status_idx | false | false | true | true | CREATE INDEX trip_expenses_company_trip_status_idx ON public.trip_expenses USING btree (company_id, trip_id, approval_status) |
| public | trip_expenses | trip_expenses_pkey | true | true | true | true | CREATE UNIQUE INDEX trip_expenses_pkey ON public.trip_expenses USING btree (id) |
| public | trip_fuel_entries | trip_fuel_entries_company_idempotency_key | true | false | true | true | CREATE UNIQUE INDEX trip_fuel_entries_company_idempotency_key ON public.trip_fuel_entries USING btree (company_id, idempotency_key) |
| public | trip_fuel_entries | trip_fuel_entries_company_trip_time_idx | false | false | true | true | CREATE INDEX trip_fuel_entries_company_trip_time_idx ON public.trip_fuel_entries USING btree (company_id, trip_id, entry_time DESC) |
| public | trip_fuel_entries | trip_fuel_entries_pkey | true | true | true | true | CREATE UNIQUE INDEX trip_fuel_entries_pkey ON public.trip_fuel_entries USING btree (id) |
| public | trip_location_breadcrumbs | idx_trip_loc_breadcrumbs_trip_date | false | false | true | true | CREATE INDEX idx_trip_loc_breadcrumbs_trip_date ON public.trip_location_breadcrumbs USING btree (trip_id, recorded_at DESC) |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_pkey | true | true | true | true | CREATE UNIQUE INDEX trip_location_breadcrumbs_pkey ON public.trip_location_breadcrumbs USING btree (id) |


## 6. Custom types and enums

### 6.1 Custom types

| schema_name | type_name | type_kind | base_type_name | not_null | default_value |
|---|---|---|---|---|---|
| public | companies | c |  | false |  |
| public | company_drivers | c |  | false |  |
| public | company_memberships | c |  | false |  |
| public | driver_accounts | c |  | false |  |
| public | driver_employment_history | c |  | false |  |
| public | driver_history_access_logs | c |  | false |  |
| public | driver_history_evidence | c |  | false |  |
| public | driver_history_reviews | c |  | false |  |
| public | driver_incidents | c |  | false |  |
| public | driver_ledger_entries | c |  | false |  |
| public | driver_licences | c |  | false |  |
| public | driver_memberships | c |  | false |  |
| public | driver_verification_audit_logs | c |  | false |  |
| public | fleet_audit_events | c |  | false |  |
| public | fleet_challans | c |  | false |  |
| public | fleet_maintenance_jobs | c |  | false |  |
| public | fleet_trips | c |  | false |  |
| public | fleet_vehicle_documents | c |  | false |  |
| public | fleet_vehicles | c |  | false |  |
| public | trip_closures | c |  | false |  |
| public | trip_expenses | c |  | false |  |
| public | trip_fuel_entries | c |  | false |  |
| public | trip_location_breadcrumbs | c |  | false |  |

### 6.2 Enum labels

_None recorded._


## 7. Functions and RPCs

Only `public` schema functions are listed. Volatility codes: `i` immutable, `s` stable, `v` volatile.

| schema_name | function_name | identity_arguments | result_type | language | volatility | security_definer | owner | comment |
|---|---|---|---|---|---|---|---|---|
| public | easyfleet_create_company | p_company_id uuid, p_name text, p_legal_name text | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_create_driver_account | p_display_name text | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_create_trip | p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid, p_company_driver_id uuid, p_driver_account_id uuid, p_gc_number text, p_material text, p_tonnes numeric, p_freight_rate numeric, p_bata_advance numeric, p_planned_distance_km numeric | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_create_vehicle | p_company_id uuid, p_vehicle_id uuid, p_registration_number text, p_vehicle_type text, p_make text, p_model text, p_manufacturing_year integer, p_capacity_tonnes numeric, p_odometer_km bigint, p_notes text | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_request_replay | p_company_id uuid, p_idempotency_key uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_request jsonb | boolean | plpgsql | v | true | postgres |  |
| public | easyfleet_review_trip_closure | p_company_id uuid, p_closure_id uuid, p_decision text, p_reviewer_note text, p_idempotency_key uuid | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_set_updated_at |  | trigger | plpgsql | v | false | postgres |  |
| public | easyfleet_start_trip | p_company_id uuid, p_trip_id uuid, p_starting_odometer_km bigint, p_idempotency_key uuid | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_submit_trip_closure | p_company_id uuid, p_trip_id uuid, p_closure_id uuid, p_idempotency_key uuid, p_closing_odometer_km bigint, p_actual_distance_km numeric, p_bata_earned numeric, p_bata_advance numeric, p_delivery_confirmed boolean, p_pod_object_path text, p_closure_notes text | uuid | plpgsql | v | true | postgres |  |
| public | easyfleet_validate_closure_pod_object |  | trigger | plpgsql | v | true | postgres |  |
| public | easyfleet_write_audit_event | p_company_id uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_idempotency_key uuid, p_details jsonb, p_actor_driver_account_id uuid | void | plpgsql | v | true | postgres |  |
| public | get_company_approved_driver_profile | p_company_id uuid, p_driver_account_id uuid | TABLE(display_name text, phone_e164 text, local_driver_code text, employment_role text) | plpgsql | s | true | postgres |  |
| public | get_verified_driver_history | p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text | TABLE(record_type text, source_company_name text, event_date date, category text, verified_summary text) | plpgsql | v | true | postgres |  |
| public | is_approved_company_driver | p_company_id uuid, p_driver_account_id uuid | boolean | sql | s | true | postgres |  |
| public | is_company_history_reviewer | p_company_id uuid | boolean | sql | s | true | postgres |  |
| public | is_company_manager | p_company_id uuid | boolean | sql | s | true | postgres |  |
| public | is_company_member | p_company_id uuid | boolean | sql | s | true | postgres |  |
| public | is_company_operator | p_company_id uuid | boolean | sql | s | true | postgres |  |
| public | is_driver_account_owner | p_driver_account_id uuid | boolean | sql | s | true | postgres |  |
| public | prevent_audit_log_modification |  | trigger | plpgsql | v | true | postgres |  |
| public | rls_auto_enable |  | event_trigger | plpgsql | v | true | postgres |  |
| public | set_driver_official_verification_status | p_driver_account_id uuid, p_new_status text, p_verification_notes text | void | plpgsql | v | true | postgres |  |

### 7.1 Function grants

| schema_name | function_name | identity_arguments | grantee | privilege_type |
|---|---|---|---|---|
| public | easyfleet_create_company | p_company_id uuid, p_name text, p_legal_name text | authenticated | EXECUTE |
| public | easyfleet_create_company | p_company_id uuid, p_name text, p_legal_name text | postgres | EXECUTE |
| public | easyfleet_create_driver_account | p_display_name text | authenticated | EXECUTE |
| public | easyfleet_create_driver_account | p_display_name text | postgres | EXECUTE |
| public | easyfleet_create_trip | p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid, p_company_driver_id uuid, p_driver_account_id uuid, p_gc_number text, p_material text, p_tonnes numeric, p_freight_rate numeric, p_bata_advance numeric, p_planned_distance_km numeric | authenticated | EXECUTE |
| public | easyfleet_create_trip | p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid, p_company_driver_id uuid, p_driver_account_id uuid, p_gc_number text, p_material text, p_tonnes numeric, p_freight_rate numeric, p_bata_advance numeric, p_planned_distance_km numeric | postgres | EXECUTE |
| public | easyfleet_create_vehicle | p_company_id uuid, p_vehicle_id uuid, p_registration_number text, p_vehicle_type text, p_make text, p_model text, p_manufacturing_year integer, p_capacity_tonnes numeric, p_odometer_km bigint, p_notes text | authenticated | EXECUTE |
| public | easyfleet_create_vehicle | p_company_id uuid, p_vehicle_id uuid, p_registration_number text, p_vehicle_type text, p_make text, p_model text, p_manufacturing_year integer, p_capacity_tonnes numeric, p_odometer_km bigint, p_notes text | postgres | EXECUTE |
| public | easyfleet_request_replay | p_company_id uuid, p_idempotency_key uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_request jsonb | postgres | EXECUTE |
| public | easyfleet_review_trip_closure | p_company_id uuid, p_closure_id uuid, p_decision text, p_reviewer_note text, p_idempotency_key uuid | authenticated | EXECUTE |
| public | easyfleet_review_trip_closure | p_company_id uuid, p_closure_id uuid, p_decision text, p_reviewer_note text, p_idempotency_key uuid | postgres | EXECUTE |
| public | easyfleet_set_updated_at |  | postgres | EXECUTE |
| public | easyfleet_start_trip | p_company_id uuid, p_trip_id uuid, p_starting_odometer_km bigint, p_idempotency_key uuid | authenticated | EXECUTE |
| public | easyfleet_start_trip | p_company_id uuid, p_trip_id uuid, p_starting_odometer_km bigint, p_idempotency_key uuid | postgres | EXECUTE |
| public | easyfleet_submit_trip_closure | p_company_id uuid, p_trip_id uuid, p_closure_id uuid, p_idempotency_key uuid, p_closing_odometer_km bigint, p_actual_distance_km numeric, p_bata_earned numeric, p_bata_advance numeric, p_delivery_confirmed boolean, p_pod_object_path text, p_closure_notes text | authenticated | EXECUTE |
| public | easyfleet_submit_trip_closure | p_company_id uuid, p_trip_id uuid, p_closure_id uuid, p_idempotency_key uuid, p_closing_odometer_km bigint, p_actual_distance_km numeric, p_bata_earned numeric, p_bata_advance numeric, p_delivery_confirmed boolean, p_pod_object_path text, p_closure_notes text | postgres | EXECUTE |
| public | easyfleet_validate_closure_pod_object |  | postgres | EXECUTE |
| public | easyfleet_write_audit_event | p_company_id uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_idempotency_key uuid, p_details jsonb, p_actor_driver_account_id uuid | postgres | EXECUTE |
| public | get_company_approved_driver_profile | p_company_id uuid, p_driver_account_id uuid | authenticated | EXECUTE |
| public | get_company_approved_driver_profile | p_company_id uuid, p_driver_account_id uuid | postgres | EXECUTE |
| public | get_company_approved_driver_profile | p_company_id uuid, p_driver_account_id uuid | service_role | EXECUTE |
| public | get_verified_driver_history | p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text | authenticated | EXECUTE |
| public | get_verified_driver_history | p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text | postgres | EXECUTE |
| public | get_verified_driver_history | p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text | service_role | EXECUTE |
| public | is_approved_company_driver | p_company_id uuid, p_driver_account_id uuid | authenticated | EXECUTE |
| public | is_approved_company_driver | p_company_id uuid, p_driver_account_id uuid | postgres | EXECUTE |
| public | is_company_history_reviewer | p_company_id uuid | authenticated | EXECUTE |
| public | is_company_history_reviewer | p_company_id uuid | postgres | EXECUTE |
| public | is_company_history_reviewer | p_company_id uuid | service_role | EXECUTE |
| public | is_company_manager | p_company_id uuid | authenticated | EXECUTE |
| public | is_company_manager | p_company_id uuid | postgres | EXECUTE |
| public | is_company_member | p_company_id uuid | authenticated | EXECUTE |
| public | is_company_member | p_company_id uuid | postgres | EXECUTE |
| public | is_company_member | p_company_id uuid | service_role | EXECUTE |
| public | is_company_operator | p_company_id uuid | authenticated | EXECUTE |
| public | is_company_operator | p_company_id uuid | postgres | EXECUTE |
| public | is_driver_account_owner | p_driver_account_id uuid | authenticated | EXECUTE |
| public | is_driver_account_owner | p_driver_account_id uuid | postgres | EXECUTE |
| public | is_driver_account_owner | p_driver_account_id uuid | service_role | EXECUTE |
| public | prevent_audit_log_modification |  | postgres | EXECUTE |
| public | rls_auto_enable |  | postgres | EXECUTE |
| public | rls_auto_enable |  | service_role | EXECUTE |
| public | set_driver_official_verification_status | p_driver_account_id uuid, p_new_status text, p_verification_notes text | authenticated | EXECUTE |
| public | set_driver_official_verification_status | p_driver_account_id uuid, p_new_status text, p_verification_notes text | postgres | EXECUTE |


## 8. Function definitions

Full `pg_get_functiondef()` output for every public function is included below as recorded catalog data.

<details><summary><code>public.easyfleet_create_company(p_company_id uuid, p_name text, p_legal_name text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_create_company(p_company_id uuid, p_name text, p_legal_name text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_user uuid := (SELECT auth.uid());
    v_request jsonb;
    v_company public.companies%ROWTYPE;
BEGIN
    IF v_user IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
    IF p_company_id IS NULL OR p_name IS NULL OR length(trim(p_name)) < 2 THEN
        RAISE EXCEPTION 'Valid company ID and name required';
    END IF;

    v_request := jsonb_build_object(
        'name', trim(p_name),
        'legal_name', nullif(trim(p_legal_name), '')
    );
    PERFORM pg_advisory_xact_lock(hashtextextended('company:' || p_company_id::text, 0));

    SELECT * INTO v_company FROM public.companies WHERE id = p_company_id FOR UPDATE;
    IF FOUND THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.company_memberships
            WHERE company_id = p_company_id AND user_id = v_user
              AND role = 'OWNER' AND status = 'ACTIVE'
        ) THEN
            RAISE EXCEPTION 'Company ID already exists';
        END IF;
        IF v_company.name IS DISTINCT FROM trim(p_name)
           OR v_company.legal_name IS DISTINCT FROM nullif(trim(p_legal_name), '') THEN
            RAISE EXCEPTION 'Company ID exists with different company details'
                USING ERRCODE = '23505';
        END IF;
        IF public.easyfleet_request_replay(
            p_company_id, p_company_id, 'COMPANY', p_company_id,
            'COMPANY_CREATED', v_request
        ) THEN
            RETURN p_company_id;
        END IF;
        -- Existing company without a matching v2 event is not silently treated
        -- as a successful retry; it may predate this RPC or v1 event format.
        RAISE EXCEPTION 'Company already exists; request cannot be safely replayed'
            USING ERRCODE = '23505';
    END IF;

    INSERT INTO public.companies(id, name, legal_name, status)
    VALUES (p_company_id, trim(p_name), nullif(trim(p_legal_name), ''), 'ACTIVE');

    INSERT INTO public.company_memberships(company_id, user_id, role, status)
    VALUES (p_company_id, v_user, 'OWNER', 'ACTIVE');

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'COMPANY', p_company_id, 'COMPANY_CREATED', p_company_id,
        jsonb_build_object('request', v_request, 'created_by', v_user)
    );
    RETURN p_company_id;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_create_driver_account(p_display_name text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_create_driver_account(p_display_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_driver_account_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.driver_accounts (auth_user_id, display_name, identity_status)
  values (auth.uid(), coalesce(nullif(trim(p_display_name), ''), 'Driver'), 'PENDING')
  on conflict (auth_user_id) do update
    set display_name = excluded.display_name
  returning id into v_driver_account_id;

  return v_driver_account_id;
end;
$function$

```

</details>

<details><summary><code>public.easyfleet_create_trip(p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid, p_company_driver_id uuid, p_driver_account_id uuid, p_gc_number text, p_material text, p_tonnes numeric, p_freight_rate numeric, p_bata_advance numeric, p_planned_distance_km numeric)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_create_trip(p_company_id uuid, p_trip_id uuid, p_origin text, p_destination text, p_scheduled_date date, p_idempotency_key uuid, p_vehicle_id uuid DEFAULT NULL::uuid, p_company_driver_id uuid DEFAULT NULL::uuid, p_driver_account_id uuid DEFAULT NULL::uuid, p_gc_number text DEFAULT NULL::text, p_material text DEFAULT NULL::text, p_tonnes numeric DEFAULT NULL::numeric, p_freight_rate numeric DEFAULT NULL::numeric, p_bata_advance numeric DEFAULT 0, p_planned_distance_km numeric DEFAULT NULL::numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_existing uuid;
    v_existing_trip public.fleet_trips%ROWTYPE;
    v_status text := 'PLANNED';
    v_request jsonb;
BEGIN
    IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
    IF NOT public.is_company_operator(p_company_id) THEN
        RAISE EXCEPTION 'Company operator permission required';
    END IF;
    IF p_company_id IS NULL OR p_trip_id IS NULL OR p_idempotency_key IS NULL
       OR p_origin IS NULL OR length(trim(p_origin)) = 0
       OR p_destination IS NULL OR length(trim(p_destination)) = 0
       OR p_scheduled_date IS NULL THEN
        RAISE EXCEPTION 'Trip ID, idempotency key, route and date required';
    END IF;
    IF (p_company_driver_id IS NULL) <> (p_driver_account_id IS NULL) THEN
        RAISE EXCEPTION 'Company driver and driver account must be supplied together';
    END IF;
    IF COALESCE(p_bata_advance, 0) < 0
       OR (p_tonnes IS NOT NULL AND p_tonnes <= 0)
       OR (p_freight_rate IS NOT NULL AND p_freight_rate < 0)
       OR (p_planned_distance_km IS NOT NULL AND p_planned_distance_km < 0) THEN
        RAISE EXCEPTION 'Invalid trip quantity, rate, advance or distance';
    END IF;

    v_request := jsonb_build_object(
        'trip_id', p_trip_id, 'origin', trim(p_origin), 'destination', trim(p_destination),
        'scheduled_date', p_scheduled_date, 'vehicle_id', p_vehicle_id,
        'company_driver_id', p_company_driver_id, 'driver_account_id', p_driver_account_id,
        'gc_number', nullif(trim(p_gc_number), ''), 'material', nullif(trim(p_material), ''),
        'tonnes', p_tonnes, 'freight_rate', p_freight_rate,
        'bata_advance', COALESCE(p_bata_advance, 0),
        'planned_distance_km', p_planned_distance_km
    );

    PERFORM pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
    IF public.easyfleet_request_replay(
        p_company_id, p_idempotency_key, 'TRIP', p_trip_id, 'TRIP_CREATED', v_request
    ) THEN
        SELECT id INTO v_existing FROM public.fleet_trips
        WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key;
        IF v_existing IS NULL THEN RAISE EXCEPTION 'Idempotency record exists without its trip'; END IF;
        RETURN v_existing;
    END IF;

    SELECT * INTO v_existing_trip FROM public.fleet_trips
    WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key
    FOR UPDATE;
    IF FOUND THEN
        RAISE EXCEPTION 'Trip exists without a matching v2 audit fingerprint; manual reconciliation required'
            USING ERRCODE = '23505';
    END IF;

    IF p_vehicle_id IS NOT NULL THEN
        PERFORM 1 FROM public.fleet_vehicles
        WHERE id = p_vehicle_id AND company_id = p_company_id AND status = 'AVAILABLE'
        FOR UPDATE;
        IF NOT FOUND THEN RAISE EXCEPTION 'Vehicle unavailable or not in this company'; END IF;
    END IF;

    IF p_driver_account_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.company_drivers cd
            WHERE cd.id = p_company_driver_id AND cd.company_id = p_company_id
              AND cd.driver_account_id = p_driver_account_id
        ) THEN RAISE EXCEPTION 'Driver mapping does not belong to this company'; END IF;
        -- This RPC is called by a company operator, not by the driver.
        -- is_approved_company_driver() also checks auth.uid() ownership, so
        -- use the company-side membership check here instead.
        IF NOT EXISTS (
            SELECT 1
            FROM public.driver_memberships dm
            JOIN public.companies c ON c.id = dm.company_id
            WHERE dm.company_id = p_company_id
              AND dm.driver_account_id = p_driver_account_id
              AND dm.status = 'APPROVED'
              AND c.status = 'ACTIVE'
        ) THEN
            RAISE EXCEPTION 'Driver must have approved membership in an active company';
        END IF;
    END IF;

    IF p_vehicle_id IS NOT NULL OR p_driver_account_id IS NOT NULL THEN v_status := 'ASSIGNED'; END IF;
    INSERT INTO public.fleet_trips(
        id, company_id, gc_number, origin, destination, scheduled_date, vehicle_id,
        company_driver_id, driver_account_id, material, tonnes, freight_rate, bata_advance,
        planned_distance_km, status, assigned_at, created_by, idempotency_key
    ) VALUES (
        p_trip_id, p_company_id, nullif(trim(p_gc_number), ''), trim(p_origin), trim(p_destination),
        p_scheduled_date, p_vehicle_id, p_company_driver_id, p_driver_account_id,
        nullif(trim(p_material), ''), p_tonnes, p_freight_rate, COALESCE(p_bata_advance, 0),
        p_planned_distance_km, v_status, CASE WHEN v_status = 'ASSIGNED' THEN now() END,
        (SELECT auth.uid()), p_idempotency_key
    );

    IF p_vehicle_id IS NOT NULL THEN
        UPDATE public.fleet_vehicles SET status = 'ASSIGNED'
        WHERE id = p_vehicle_id AND company_id = p_company_id;
    END IF;

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'TRIP', p_trip_id, 'TRIP_CREATED', p_idempotency_key,
        jsonb_build_object('request', v_request, 'status', v_status)
    );
    RETURN p_trip_id;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_create_vehicle(p_company_id uuid, p_vehicle_id uuid, p_registration_number text, p_vehicle_type text, p_make text, p_model text, p_manufacturing_year integer, p_capacity_tonnes numeric, p_odometer_km bigint, p_notes text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_create_vehicle(p_company_id uuid, p_vehicle_id uuid, p_registration_number text, p_vehicle_type text DEFAULT 'TRUCK'::text, p_make text DEFAULT NULL::text, p_model text DEFAULT NULL::text, p_manufacturing_year integer DEFAULT NULL::integer, p_capacity_tonnes numeric DEFAULT NULL::numeric, p_odometer_km bigint DEFAULT NULL::bigint, p_notes text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_vehicle public.fleet_vehicles%ROWTYPE;
    v_request jsonb;
    v_registration text;
    v_type text;
BEGIN
    IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
    IF NOT public.is_company_operator(p_company_id) THEN
        RAISE EXCEPTION 'Company operator permission required';
    END IF;
    IF p_company_id IS NULL OR p_vehicle_id IS NULL
       OR p_registration_number IS NULL OR length(trim(p_registration_number)) < 3 THEN
        RAISE EXCEPTION 'Valid company, vehicle ID and registration required';
    END IF;
    IF p_odometer_km IS NOT NULL AND p_odometer_km < 0 THEN
        RAISE EXCEPTION 'Odometer cannot be negative';
    END IF;
    IF p_manufacturing_year IS NOT NULL
       AND (p_manufacturing_year < 1900 OR p_manufacturing_year > extract(year FROM current_date)::integer + 1) THEN
        RAISE EXCEPTION 'Invalid manufacturing year';
    END IF;
    IF p_capacity_tonnes IS NOT NULL AND p_capacity_tonnes <= 0 THEN
        RAISE EXCEPTION 'Capacity must be positive';
    END IF;

    v_registration := upper(trim(p_registration_number));
    v_type := COALESCE(nullif(trim(p_vehicle_type), ''), 'TRUCK');
    v_request := jsonb_build_object(
        'registration_number', v_registration,
        'vehicle_type', v_type,
        'make', nullif(trim(p_make), ''),
        'model', nullif(trim(p_model), ''),
        'manufacturing_year', p_manufacturing_year,
        'capacity_tonnes', p_capacity_tonnes,
        'odometer_km', p_odometer_km,
        'notes', p_notes
    );

    PERFORM pg_advisory_xact_lock(hashtextextended('vehicle:' || p_vehicle_id::text, 0));
    SELECT * INTO v_vehicle FROM public.fleet_vehicles
    WHERE id = p_vehicle_id FOR UPDATE;
    IF FOUND THEN
        IF v_vehicle.company_id <> p_company_id THEN
            RAISE EXCEPTION 'Vehicle ID belongs to another company';
        END IF;
        IF public.easyfleet_request_replay(
            p_company_id, p_vehicle_id, 'VEHICLE', p_vehicle_id,
            'VEHICLE_CREATED', v_request
        ) THEN
            RETURN p_vehicle_id;
        END IF;
        RAISE EXCEPTION 'Vehicle already exists; request cannot be safely replayed or payload differs'
            USING ERRCODE = '23505';
    END IF;

    INSERT INTO public.fleet_vehicles(
        id, company_id, registration_number, vehicle_type, make, model,
        manufacturing_year, capacity_tonnes, odometer_km, notes, created_by
    ) VALUES (
        p_vehicle_id, p_company_id, v_registration, v_type,
        nullif(trim(p_make), ''), nullif(trim(p_model), ''),
        p_manufacturing_year, p_capacity_tonnes, p_odometer_km, p_notes,
        (SELECT auth.uid())
    );

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'VEHICLE', p_vehicle_id, 'VEHICLE_CREATED', p_vehicle_id,
        jsonb_build_object('request', v_request)
    );
    RETURN p_vehicle_id;END;
$function$

```

</details>

<details><summary><code>public.easyfleet_request_replay(p_company_id uuid, p_idempotency_key uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_request jsonb)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_request_replay(p_company_id uuid, p_idempotency_key uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_request jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_event public.fleet_audit_events%ROWTYPE;
BEGIN
    SELECT * INTO v_event
    FROM public.fleet_audit_events
    WHERE company_id = p_company_id
      AND idempotency_key = p_idempotency_key;

    IF NOT FOUND THEN
        RETURN false;
    END IF;

    IF v_event.entity_type IS DISTINCT FROM p_entity_type
       OR v_event.entity_id IS DISTINCT FROM p_entity_id
       OR v_event.event_type IS DISTINCT FROM p_event_type
       OR v_event.details->'request' IS DISTINCT FROM COALESCE(p_request, '{}'::jsonb) THEN
        RAISE EXCEPTION 'Idempotency key conflict: key was already used for a different request'
            USING ERRCODE = '23505';
    END IF;

    RETURN true;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_review_trip_closure(p_company_id uuid, p_closure_id uuid, p_decision text, p_reviewer_note text, p_idempotency_key uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_review_trip_closure(p_company_id uuid, p_closure_id uuid, p_decision text, p_reviewer_note text, p_idempotency_key uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_closure public.trip_closures%ROWTYPE;
    v_trip public.fleet_trips%ROWTYPE;
    v_request jsonb;
BEGIN
    IF (SELECT auth.uid()) IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    IF NOT public.is_company_manager(p_company_id) THEN
        RAISE EXCEPTION 'Owner/admin permission required';
    END IF;

    IF p_company_id IS NULL
       OR p_closure_id IS NULL
       OR p_idempotency_key IS NULL
       OR p_decision IS NULL
       OR p_decision NOT IN ('APPROVED', 'REJECTED') THEN
        RAISE EXCEPTION 'Valid closure, decision and idempotency key required';
    END IF;

    SELECT * INTO v_closure
    FROM public.trip_closures
    WHERE id = p_closure_id
      AND company_id = p_company_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Closure not found';
    END IF;

    SELECT * INTO v_trip
    FROM public.fleet_trips
    WHERE id = v_closure.trip_id
      AND company_id = p_company_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Trip not found';
    END IF;

    v_request := jsonb_build_object(
        'closure_id', p_closure_id,
        'trip_id', v_trip.id,
        'decision', p_decision,
        'reviewer_note', nullif(trim(p_reviewer_note), '')
    );

    PERFORM pg_advisory_xact_lock(
        hashtextextended(
            p_company_id::text || ':' || p_idempotency_key::text,
            0
        )
    );

    IF public.easyfleet_request_replay(
        p_company_id,
        p_idempotency_key,
        'TRIP_CLOSURE',
        p_closure_id,
        CASE
            WHEN p_decision = 'APPROVED'
                THEN 'TRIP_CLOSURE_APPROVED'
            ELSE 'TRIP_CLOSURE_REJECTED'
        END,
        v_request
    ) THEN
        RETURN p_closure_id;
    END IF;

    IF v_closure.status <> 'SUBMITTED'
       OR v_trip.status <> 'CLOSURE_PENDING' THEN
        RAISE EXCEPTION
            'Only a submitted closure for a trip awaiting review can be reviewed';
    END IF;

    IF v_closure.submitted_by = (SELECT auth.uid()) THEN
        RAISE EXCEPTION 'The closure submitter cannot review their own closure';
    END IF;

    UPDATE public.trip_closures
    SET status = p_decision,
        reviewed_by = (SELECT auth.uid()),
        reviewed_at = now(),
        reviewer_note = nullif(trim(p_reviewer_note), '')
    WHERE id = p_closure_id
      AND company_id = p_company_id;

    IF p_decision = 'APPROVED' THEN
        UPDATE public.fleet_trips
        SET status = 'COMPLETED',
            completed_at = now()
        WHERE id = v_trip.id
          AND company_id = p_company_id;

        IF v_trip.vehicle_id IS NOT NULL THEN
            UPDATE public.fleet_vehicles
            SET odometer_km = CASE
                    WHEN v_closure.closing_odometer_km IS NULL
                        THEN odometer_km
                    WHEN odometer_km IS NULL
                        THEN v_closure.closing_odometer_km
                    ELSE GREATEST(
                        odometer_km,
                        v_closure.closing_odometer_km
                    )
                END,
                status = 'AVAILABLE'
            WHERE id = v_trip.vehicle_id
              AND company_id = p_company_id;
        END IF;
    ELSE
        UPDATE public.fleet_trips
        SET status = 'IN_TRANSIT'
        WHERE id = v_trip.id
          AND company_id = p_company_id;

        IF v_trip.vehicle_id IS NOT NULL THEN
            UPDATE public.fleet_vehicles
            SET status = 'ON_TRIP'
            WHERE id = v_trip.vehicle_id
              AND company_id = p_company_id;
        END IF;
    END IF;

    PERFORM public.easyfleet_write_audit_event(
        p_company_id,
        'TRIP_CLOSURE',
        p_closure_id,
        CASE
            WHEN p_decision = 'APPROVED'
                THEN 'TRIP_CLOSURE_APPROVED'
            ELSE 'TRIP_CLOSURE_REJECTED'
        END,
        p_idempotency_key,
        jsonb_build_object('request', v_request)
    );

    RETURN p_closure_id;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_set_updated_at()</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
    new.updated_at := now();
    return new;
end;
$function$

```

</details>

<details><summary><code>public.easyfleet_start_trip(p_company_id uuid, p_trip_id uuid, p_starting_odometer_km bigint, p_idempotency_key uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_start_trip(p_company_id uuid, p_trip_id uuid, p_starting_odometer_km bigint, p_idempotency_key uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_trip public.fleet_trips%ROWTYPE;
    v_driver boolean := false;
    v_vehicle_odo bigint;
    v_request jsonb;
BEGIN
    IF (SELECT auth.uid()) IS NULL OR p_idempotency_key IS NULL THEN
        RAISE EXCEPTION 'Authentication and idempotency key required';
    END IF;
    SELECT * INTO v_trip FROM public.fleet_trips
    WHERE id = p_trip_id AND company_id = p_company_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Trip not found'; END IF;

    IF v_trip.driver_account_id IS NOT NULL THEN
        v_driver := public.is_driver_account_owner(v_trip.driver_account_id)
            AND public.is_approved_company_driver(p_company_id, v_trip.driver_account_id);
    END IF;
    IF NOT v_driver AND NOT public.is_company_operator(p_company_id) THEN
        RAISE EXCEPTION 'Assigned driver or company operator permission required';
    END IF;
    IF p_starting_odometer_km IS NOT NULL AND p_starting_odometer_km < 0 THEN
        RAISE EXCEPTION 'Invalid odometer';
    END IF;

    v_request := jsonb_build_object('trip_id', p_trip_id, 'starting_odometer_km', p_starting_odometer_km);
    PERFORM pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
    IF public.easyfleet_request_replay(
        p_company_id, p_idempotency_key, 'TRIP', p_trip_id, 'TRIP_STARTED', v_request
    ) THEN RETURN p_trip_id; END IF;

    IF v_trip.status <> 'ASSIGNED' THEN
        RAISE EXCEPTION 'Trip is not in ASSIGNED state; start request cannot be replayed safely';
    END IF;
    IF v_trip.vehicle_id IS NOT NULL AND p_starting_odometer_km IS NOT NULL THEN
        SELECT odometer_km INTO v_vehicle_odo FROM public.fleet_vehicles
        WHERE id = v_trip.vehicle_id AND company_id = p_company_id FOR UPDATE;
        IF NOT FOUND THEN RAISE EXCEPTION 'Assigned vehicle not found'; END IF;
        IF v_vehicle_odo IS NOT NULL AND p_starting_odometer_km < v_vehicle_odo THEN
            RAISE EXCEPTION 'Starting odometer is below the vehicle recorded odometer';
        END IF;
    END IF;

    UPDATE public.fleet_trips SET status = 'IN_TRANSIT', started_at = now(),
        starting_odometer_km = p_starting_odometer_km
    WHERE id = p_trip_id AND company_id = p_company_id;
    IF v_trip.vehicle_id IS NOT NULL THEN
        UPDATE public.fleet_vehicles SET status = 'ON_TRIP'
        WHERE id = v_trip.vehicle_id AND company_id = p_company_id;
    END IF;

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'TRIP', p_trip_id, 'TRIP_STARTED', p_idempotency_key,
        jsonb_build_object('request', v_request),
        CASE WHEN v_driver THEN v_trip.driver_account_id END
    );
    RETURN p_trip_id;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_submit_trip_closure(p_company_id uuid, p_trip_id uuid, p_closure_id uuid, p_idempotency_key uuid, p_closing_odometer_km bigint, p_actual_distance_km numeric, p_bata_earned numeric, p_bata_advance numeric, p_delivery_confirmed boolean, p_pod_object_path text, p_closure_notes text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_submit_trip_closure(p_company_id uuid, p_trip_id uuid, p_closure_id uuid, p_idempotency_key uuid, p_closing_odometer_km bigint DEFAULT NULL::bigint, p_actual_distance_km numeric DEFAULT NULL::numeric, p_bata_earned numeric DEFAULT 0, p_bata_advance numeric DEFAULT 0, p_delivery_confirmed boolean DEFAULT false, p_pod_object_path text DEFAULT NULL::text, p_closure_notes text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    v_trip public.fleet_trips%ROWTYPE;
    v_existing public.trip_closures%ROWTYPE;
    v_submission integer;
    v_driver boolean := false;
    v_request jsonb;
BEGIN
    IF (SELECT auth.uid()) IS NULL OR p_trip_id IS NULL OR p_closure_id IS NULL OR p_idempotency_key IS NULL THEN
        RAISE EXCEPTION 'Authentication, trip ID, closure ID and idempotency key required';
    END IF;
    SELECT * INTO v_trip FROM public.fleet_trips
    WHERE id = p_trip_id AND company_id = p_company_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Trip not found'; END IF;

    IF v_trip.driver_account_id IS NOT NULL THEN
        v_driver := public.is_driver_account_owner(v_trip.driver_account_id)
            AND public.is_approved_company_driver(p_company_id, v_trip.driver_account_id);
    END IF;
    IF NOT v_driver AND NOT public.is_company_operator(p_company_id) THEN
        RAISE EXCEPTION 'Assigned driver or company operator permission required';
    END IF;

    IF p_closing_odometer_km IS NOT NULL AND p_closing_odometer_km < 0 THEN
        RAISE EXCEPTION 'Invalid closing odometer';
    END IF;
    IF v_trip.starting_odometer_km IS NOT NULL AND p_closing_odometer_km IS NOT NULL
       AND p_closing_odometer_km < v_trip.starting_odometer_km THEN
        RAISE EXCEPTION 'Closing odometer precedes start';
    END IF;
    IF COALESCE(p_bata_earned, 0) < 0 OR COALESCE(p_bata_advance, 0) < 0
       OR (p_actual_distance_km IS NOT NULL AND p_actual_distance_km < 0) THEN
        RAISE EXCEPTION 'Closure amounts and distance cannot be negative';
    END IF;

    IF p_pod_object_path IS NOT NULL THEN
        IF length(p_pod_object_path) > 1024
           OR (length(p_pod_object_path) - length(replace(p_pod_object_path, '/', ''))) <> 4
           OR split_part(p_pod_object_path, '/', 1) <> p_company_id::text
           OR split_part(p_pod_object_path, '/', 2) <> 'trips'
           OR split_part(p_pod_object_path, '/', 3) <> p_trip_id::text
           OR split_part(p_pod_object_path, '/', 4) <> 'pod'
           OR split_part(p_pod_object_path, '/', 5) = ''
           OR split_part(p_pod_object_path, '/', 5) IN ('.', '..') THEN
            RAISE EXCEPTION 'POD path must be company/trips/trip-id/pod/file';
        END IF;
    END IF;

    v_request := jsonb_build_object(
        'trip_id', p_trip_id, 'closure_id', p_closure_id,
        'closing_odometer_km', p_closing_odometer_km,
        'actual_distance_km', p_actual_distance_km,
        'bata_earned', COALESCE(p_bata_earned, 0),
        'bata_advance', COALESCE(p_bata_advance, 0),
        'delivery_confirmed', COALESCE(p_delivery_confirmed, false),
        'pod_object_path', p_pod_object_path,
        'closure_notes', p_closure_notes
    );

    PERFORM pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
    IF public.easyfleet_request_replay(
        p_company_id, p_idempotency_key, 'TRIP', p_trip_id,
        'TRIP_CLOSURE_SUBMITTED', v_request
    ) THEN
        SELECT * INTO v_existing FROM public.trip_closures
        WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key;
        IF NOT FOUND THEN RAISE EXCEPTION 'Idempotency record exists without its closure'; END IF;
        RETURN v_existing.id;
    END IF;

    SELECT * INTO v_existing FROM public.trip_closures
    WHERE company_id = p_company_id AND idempotency_key = p_idempotency_key
    FOR UPDATE;
    IF FOUND THEN
        RAISE EXCEPTION 'Closure exists without a matching v2 audit fingerprint; manual reconciliation required'
            USING ERRCODE = '23505';
    END IF;
    IF v_trip.status <> 'IN_TRANSIT' THEN RAISE EXCEPTION 'Only in-transit trips can be closed'; END IF;

    SELECT COALESCE(max(submission_number), 0) + 1 INTO v_submission
    FROM public.trip_closures WHERE trip_id = p_trip_id;
    INSERT INTO public.trip_closures(
        id, company_id, trip_id, submission_number, status,
        starting_odometer_km, closing_odometer_km, actual_distance_km,
        planned_distance_km, distance_deviation_km, bata_earned, bata_advance,
        delivery_confirmed, pod_object_path, closure_notes,
        submitted_by, submitted_at, idempotency_key
    ) VALUES (
        p_closure_id, p_company_id, p_trip_id, v_submission, 'SUBMITTED',
        v_trip.starting_odometer_km, p_closing_odometer_km, p_actual_distance_km,
        v_trip.planned_distance_km,
        CASE WHEN p_actual_distance_km IS NOT NULL AND v_trip.planned_distance_km IS NOT NULL
             THEN p_actual_distance_km - v_trip.planned_distance_km END,
        COALESCE(p_bata_earned, 0), COALESCE(p_bata_advance, 0),
        COALESCE(p_delivery_confirmed, false), p_pod_object_path, p_closure_notes,
        (SELECT auth.uid()), now(), p_idempotency_key
    );
    UPDATE public.fleet_trips SET status = 'CLOSURE_PENDING'
    WHERE id = p_trip_id AND company_id = p_company_id;

    PERFORM public.easyfleet_write_audit_event(
        p_company_id, 'TRIP', p_trip_id, 'TRIP_CLOSURE_SUBMITTED', p_idempotency_key,
        jsonb_build_object('request', v_request, 'closure_id', p_closure_id,
                           'submission_number', v_submission),
        CASE WHEN v_driver THEN v_trip.driver_account_id END
    );
    RETURN p_closure_id;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_validate_closure_pod_object()</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_validate_closure_pod_object()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    -- A closure without a POD is permitted by this rule.
    IF NEW.pod_object_path IS NULL THEN
        RETURN NEW;
    END IF;

    -- Independently enforce company/trip-specific POD path.
    IF NEW.pod_object_path !~
       (
           '^' || NEW.company_id::text ||
           '/trips/' || NEW.trip_id::text ||
           '/pod/[^/]+$'
       )
    THEN
        RAISE EXCEPTION
            'POD path does not belong to this company and trip.'
            USING ERRCODE = '23514';
    END IF;

    -- The object must already exist in the private bucket.
    IF NOT EXISTS (
        SELECT 1
        FROM storage.objects AS o
        WHERE o.bucket_id = 'easyfleet-private-documents'
          AND o.name = NEW.pod_object_path
    )
    THEN
        RAISE EXCEPTION
            'POD object does not exist in private document storage.'
            USING ERRCODE = '23503';
    END IF;

    RETURN NEW;
END;
$function$

```

</details>

<details><summary><code>public.easyfleet_write_audit_event(p_company_id uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_idempotency_key uuid, p_details jsonb, p_actor_driver_account_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.easyfleet_write_audit_event(p_company_id uuid, p_entity_type text, p_entity_id uuid, p_event_type text, p_idempotency_key uuid, p_details jsonb DEFAULT '{}'::jsonb, p_actor_driver_account_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    IF p_idempotency_key IS NULL THEN RAISE EXCEPTION 'Audit idempotency key required'; END IF;
    INSERT INTO public.fleet_audit_events(
        id, company_id, entity_type, entity_id, event_type,
        actor_user_id, actor_driver_account_id, event_time, idempotency_key, details
    ) VALUES (
        gen_random_uuid(), p_company_id, p_entity_type, p_entity_id, p_event_type,
        (SELECT auth.uid()), p_actor_driver_account_id, now(), p_idempotency_key,
        COALESCE(p_details, '{}'::jsonb)
    );
END; $function$

```

</details>

<details><summary><code>public.get_company_approved_driver_profile(p_company_id uuid, p_driver_account_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.get_company_approved_driver_profile(p_company_id uuid, p_driver_account_id uuid)
 RETURNS TABLE(display_name text, phone_e164 text, local_driver_code text, employment_role text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
    if (select auth.uid()) is null then
        raise exception 'Authentication required';
    end if;

    if not public.is_company_member(p_company_id) then
        raise exception 'Active company membership required';
    end if;

    if not exists (
        select 1
        from public.driver_memberships dm
        where dm.company_id = p_company_id
          and dm.driver_account_id = p_driver_account_id
          and dm.status = 'APPROVED'
    ) then
        raise exception 'Driver does not have an approved membership in this company';
    end if;

    return query
    select
        da.display_name,
        da.phone_e164,
        cd.local_driver_code,
        cd.employment_role
    from public.driver_accounts da
    join public.company_drivers cd
      on cd.driver_account_id = da.id
     and cd.company_id = p_company_id
    where da.id = p_driver_account_id;
end;
$function$

```

</details>

<details><summary><code>public.get_verified_driver_history(p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.get_verified_driver_history(p_requesting_company_id uuid, p_driver_account_id uuid, p_access_purpose text)
 RETURNS TABLE(record_type text, source_company_name text, event_date date, category text, verified_summary text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
    if (select auth.uid()) is null then
        raise exception 'Authentication required';
    end if;

    if p_access_purpose is null
       or length(trim(p_access_purpose)) < 5 then
        raise exception 'A valid access purpose is required';
    end if;

    if not public.is_company_history_reviewer(p_requesting_company_id) then
        raise exception 'Not authorized to view cross-company driver history';
    end if;

    if not exists (
        select 1
        from public.driver_memberships dm
        where dm.company_id = p_requesting_company_id
          and dm.driver_account_id = p_driver_account_id
          and dm.status = 'APPROVED'
    ) then
        raise exception 'Driver does not have an approved membership in the requesting company';
    end if;

    if not exists (
        select 1
        from public.driver_accounts da
        where da.id = p_driver_account_id
    ) then
        raise exception 'Driver identity not found';
    end if;

    insert into public.driver_history_access_logs (
        requesting_company_id,
        requesting_user_id,
        driver_account_id,
        access_purpose
    )
    values (
        p_requesting_company_id,
        (select auth.uid()),
        p_driver_account_id,
        trim(p_access_purpose)
    );

    return query
    select
        'EMPLOYMENT'::text,
        c.name,
        e.started_on,
        'EMPLOYMENT'::text,
        concat(
            'Role: ', e.employment_role,
            '; Started: ', coalesce(e.started_on::text, 'Not recorded'),
            '; Ended: ', coalesce(e.ended_on::text, 'Not recorded')
        )
    from public.driver_employment_history e
    join public.companies c on c.id = e.company_id
    where e.driver_account_id = p_driver_account_id
      and e.verification_status = 'VERIFIED'

    union all

    select
        'INCIDENT'::text,
        c.name,
        i.occurred_at::date,
        i.category,
        i.factual_summary
    from public.driver_incidents i
    join public.companies c on c.id = i.company_id
    where i.driver_account_id = p_driver_account_id
      and i.verification_status = 'VERIFIED'
      and i.verified_by is not null
      and i.verified_at is not null

    order by 3 desc nulls last;
end;
$function$

```

</details>

<details><summary><code>public.is_approved_company_driver(p_company_id uuid, p_driver_account_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_approved_company_driver(p_company_id uuid, p_driver_account_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.driver_memberships dm
        join public.companies c on c.id = dm.company_id
        where dm.company_id = p_company_id
          and dm.driver_account_id = p_driver_account_id
          and dm.status = 'APPROVED'
          and c.status = 'ACTIVE'
          and public.is_driver_account_owner(p_driver_account_id)
    );
$function$

```

</details>

<details><summary><code>public.is_company_history_reviewer(p_company_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_company_history_reviewer(p_company_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.company_memberships cm
        join public.companies c on c.id = cm.company_id
        where cm.company_id = p_company_id
          and cm.user_id = (select auth.uid())
          and cm.status = 'ACTIVE'
          and c.status = 'ACTIVE'
          and cm.role in ('OWNER', 'ADMIN', 'COMPLIANCE')
    );
$function$

```

</details>

<details><summary><code>public.is_company_manager(p_company_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_company_manager(p_company_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.company_memberships cm
        join public.companies c on c.id = cm.company_id
        where cm.company_id = p_company_id
          and cm.user_id = auth.uid()
          and cm.status = 'ACTIVE'
          and c.status = 'ACTIVE'
          and cm.role in ('OWNER', 'ADMIN')
    );
$function$

```

</details>

<details><summary><code>public.is_company_member(p_company_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_company_member(p_company_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.company_memberships cm
        join public.companies c on c.id = cm.company_id
        where cm.company_id = p_company_id
          and cm.user_id = (select auth.uid())
          and cm.status = 'ACTIVE'
          and c.status = 'ACTIVE'
    );
$function$

```

</details>

<details><summary><code>public.is_company_operator(p_company_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_company_operator(p_company_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.company_memberships cm
        join public.companies c on c.id = cm.company_id
        where cm.company_id = p_company_id
          and cm.user_id = auth.uid()
          and cm.status = 'ACTIVE'
          and c.status = 'ACTIVE'
          and cm.role in ('OWNER', 'ADMIN', 'DISPATCHER')
    );
$function$

```

</details>

<details><summary><code>public.is_driver_account_owner(p_driver_account_id uuid)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.is_driver_account_owner(p_driver_account_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    select exists (
        select 1
        from public.driver_accounts da
        where da.id = p_driver_account_id
          and da.auth_user_id = (select auth.uid())
    );
$function$

```

</details>

<details><summary><code>public.prevent_audit_log_modification()</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.prevent_audit_log_modification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
    raise exception 'Driver verification audit logs are immutable and cannot be modified or deleted.';
    return OLD;
end;
$function$

```

</details>

<details><summary><code>public.rls_auto_enable()</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
  tbl name;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        SELECT c.relname INTO tbl FROM pg_catalog.pg_class c WHERE c.oid = cmd.objid;
        EXECUTE format('alter table if exists %I.%I enable row level security', cmd.schema_name, tbl);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$

```

</details>

<details><summary><code>public.set_driver_official_verification_status(p_driver_account_id uuid, p_new_status text, p_verification_notes text)</code></summary>

```sql
CREATE OR REPLACE FUNCTION public.set_driver_official_verification_status(p_driver_account_id uuid, p_new_status text, p_verification_notes text DEFAULT ''::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
    v_old_status text;
    v_company_id uuid;
begin
    if auth.uid() is null then
        raise exception 'Unauthenticated caller.';
    end if;

    if p_new_status not in ('OFFICIALLY_VERIFIED', 'REJECTED', 'MANUAL_REVIEW_REQUIRED') then
        raise exception 'Invalid verification status requested: %', p_new_status;
    end if;

    select document_verification_status into v_old_status
    from public.driver_profiles
    where driver_account_id = p_driver_account_id;

    if v_old_status is null then
        raise exception 'Driver profile not found for account %', p_driver_account_id;
    end if;

    -- Require APPROVED status in driver_memberships (PENDING_APPROVAL is rejected)
    select cm.company_id into v_company_id
    from public.company_memberships cm
    join public.driver_memberships dm on dm.company_id = cm.company_id
    where cm.user_id = auth.uid()
      and cm.status = 'ACTIVE'
      and cm.role in ('OWNER', 'ADMIN', 'COMPLIANCE')
      and dm.driver_account_id = p_driver_account_id
      and dm.status = 'APPROVED'
    limit 1;

    if v_company_id is null and current_setting('role', true) <> 'service_role' then
        raise exception 'Unauthorized: Only compliance operators of a company with APPROVED driver membership can verify licence status.';
    end if;

    perform set_config('easyfleet.trusted_verification', 'true', true);

    update public.driver_profiles
    set document_verification_status = p_new_status,
        updated_at = now()
    where driver_account_id = p_driver_account_id;

    insert into public.driver_verification_audit_logs (
        driver_account_id, verified_by_user_id, company_id, old_status, new_status, verification_notes
    )
    values (
        p_driver_account_id, auth.uid(), v_company_id, coalesce(v_old_status, 'NOT_UPLOADED'), p_new_status, p_verification_notes
    );

    perform set_config('easyfleet.trusted_verification', 'false', true);
end;
$function$

```

</details>

## 9. Triggers

Queried directly from `pg_trigger` with `tgisinternal = false`; `enabled = O` means enabled for all events.

| schema_name | table_name | trigger_name | enabled | definition |
|---|---|---|---|---|
| public | driver_verification_audit_logs | trg_prevent_audit_log_modification | O | CREATE TRIGGER trg_prevent_audit_log_modification BEFORE DELETE OR UPDATE ON public.driver_verification_audit_logs FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_modification() |
| public | fleet_challans | fleet_challans_set_updated_at | O | CREATE TRIGGER fleet_challans_set_updated_at BEFORE UPDATE ON public.fleet_challans FOR EACH ROW EXECUTE FUNCTION easyfleet_set_updated_at() |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_set_updated_at | O | CREATE TRIGGER fleet_maintenance_jobs_set_updated_at BEFORE UPDATE ON public.fleet_maintenance_jobs FOR EACH ROW EXECUTE FUNCTION easyfleet_set_updated_at() |
| public | fleet_trips | fleet_trips_set_updated_at | O | CREATE TRIGGER fleet_trips_set_updated_at BEFORE UPDATE ON public.fleet_trips FOR EACH ROW EXECUTE FUNCTION easyfleet_set_updated_at() |
| public | fleet_vehicle_documents | fleet_vehicle_documents_set_updated_at | O | CREATE TRIGGER fleet_vehicle_documents_set_updated_at BEFORE UPDATE ON public.fleet_vehicle_documents FOR EACH ROW EXECUTE FUNCTION easyfleet_set_updated_at() |
| public | fleet_vehicles | fleet_vehicles_set_updated_at | O | CREATE TRIGGER fleet_vehicles_set_updated_at BEFORE UPDATE ON public.fleet_vehicles FOR EACH ROW EXECUTE FUNCTION easyfleet_set_updated_at() |
| public | trip_closures | trip_closures_validate_pod_object | O | CREATE TRIGGER trip_closures_validate_pod_object BEFORE INSERT OR UPDATE OF company_id, trip_id, pod_object_path ON public.trip_closures FOR EACH ROW EXECUTE FUNCTION easyfleet_validate_closure_pod_object() |


## 10. RLS policies

| schema_name | table_name | policy_name | permissive | roles | cmd | qual | with_check |
|---|---|---|---|---|---|---|---|
| public | companies | companies_member_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(id) |  |
| public | company_drivers | company_drivers_scoped_read | PERMISSIVE | {authenticated} | SELECT | (is_company_member(company_id) OR is_driver_account_owner(driver_account_id)) |  |
| public | company_memberships | company_memberships_scoped_read | PERMISSIVE | {authenticated} | SELECT | ((user_id = ( SELECT auth.uid() AS uid)) OR is_company_history_reviewer(company_id)) |  |
| public | driver_accounts | driver_accounts_owner_read | PERMISSIVE | {authenticated} | SELECT | (auth_user_id = ( SELECT auth.uid() AS uid)) |  |
| public | driver_employment_history | employment_company_read | PERMISSIVE | {authenticated} | SELECT | (is_company_history_reviewer(company_id) OR is_driver_account_owner(driver_account_id)) |  |
| public | driver_history_access_logs | history_access_log_reviewer_read | PERMISSIVE | {authenticated} | SELECT | is_company_history_reviewer(requesting_company_id) |  |
| public | driver_history_evidence | evidence_reviewer_read | PERMISSIVE | {authenticated} | SELECT | is_company_history_reviewer(company_id) |  |
| public | driver_history_reviews | reviews_reviewer_read | PERMISSIVE | {authenticated} | SELECT | ((EXISTS ( SELECT 1<br>   FROM driver_incidents i<br>  WHERE ((i.id = driver_history_reviews.incident_id) AND is_company_history_reviewer(i.company_id)))) OR (EXISTS ( SELECT 1<br>   FROM driver_employment_history e<br>  WHERE ((e.id = driver_history_reviews.employment_history_id) AND is_company_history_reviewer(e.company_id))))) |  |
| public | driver_incidents | incidents_reviewer_read | PERMISSIVE | {authenticated} | SELECT | (is_company_history_reviewer(company_id) OR is_driver_account_owner(driver_account_id)) |  |
| public | driver_ledger_entries | driver_ledger_scoped_read | PERMISSIVE | {authenticated} | SELECT | (is_company_manager(company_id) OR (is_driver_account_owner(driver_account_id) AND is_approved_company_driver(company_id, driver_account_id))) |  |
| public | driver_memberships | driver_memberships_scoped_read | PERMISSIVE | {authenticated} | SELECT | (is_company_history_reviewer(company_id) OR is_driver_account_owner(driver_account_id)) |  |
| public | fleet_audit_events | fleet_audit_events_manager_read | PERMISSIVE | {authenticated} | SELECT | is_company_manager(company_id) |  |
| public | fleet_challans | fleet_challans_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | fleet_maintenance_jobs | fleet_maintenance_jobs_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | fleet_trips | fleet_trips_company_read | PERMISSIVE | {authenticated} | SELECT | (is_company_member(company_id) OR ((driver_account_id IS NOT NULL) AND is_driver_account_owner(driver_account_id) AND is_approved_company_driver(company_id, driver_account_id))) |  |
| public | fleet_vehicle_documents | fleet_vehicle_documents_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | fleet_vehicles | fleet_vehicles_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | trip_closures | trip_closures_scoped_read | PERMISSIVE | {authenticated} | SELECT | (is_company_manager(company_id) OR (EXISTS ( SELECT 1<br>   FROM fleet_trips t<br>  WHERE ((t.id = trip_closures.trip_id) AND (t.company_id = trip_closures.company_id) AND (t.driver_account_id IS NOT NULL) AND is_driver_account_owner(t.driver_account_id) AND is_approved_company_driver(t.company_id, t.driver_account_id))))) |  |
| public | trip_expenses | trip_expenses_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | trip_fuel_entries | trip_fuel_entries_company_read | PERMISSIVE | {authenticated} | SELECT | is_company_member(company_id) |  |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_insert | PERMISSIVE | {public} | INSERT |  | ((auth.role() = 'authenticated'::text) AND (EXISTS ( SELECT 1<br>   FROM (fleet_trips ft<br>     JOIN driver_accounts da ON ((da.id = ft.driver_account_id)))<br>  WHERE ((ft.id = trip_location_breadcrumbs.trip_id) AND (da.auth_user_id = auth.uid()))))) |
| public | trip_location_breadcrumbs | trip_location_breadcrumbs_select | PERMISSIVE | {public} | SELECT | ((auth.role() = 'authenticated'::text) AND ((EXISTS ( SELECT 1<br>   FROM (fleet_trips ft<br>     JOIN company_memberships cm ON ((cm.company_id = ft.company_id)))<br>  WHERE ((ft.id = trip_location_breadcrumbs.trip_id) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text)))) OR (EXISTS ( SELECT 1<br>   FROM (fleet_trips ft<br>     JOIN driver_accounts da ON ((da.id = ft.driver_account_id)))<br>  WHERE ((ft.id = trip_location_breadcrumbs.trip_id) AND (da.auth_user_id = auth.uid())))))) |  |
| storage | objects | easyfleet_company_documents_insert | PERMISSIVE | {public} | INSERT |  | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'company_documents'::text) AND (EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text) AND (cm.role = ANY (ARRAY['OWNER'::text, 'ADMIN'::text])))))) |
| storage | objects | easyfleet_company_documents_select | PERMISSIVE | {public} | SELECT | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'company_documents'::text) AND (EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text))))) |  |
| storage | objects | easyfleet_driver_documents_insert | PERMISSIVE | {public} | INSERT |  | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[3] = ANY (ARRAY['licence'::text, 'identity'::text, 'profile'::text])) AND (((storage.foldername(name))[2] = ( SELECT (driver_accounts.id)::text AS id<br>   FROM driver_accounts<br>  WHERE (driver_accounts.auth_user_id = auth.uid()))) OR (EXISTS ( SELECT 1<br>   FROM (company_memberships cm<br>     JOIN driver_memberships dm ON ((dm.company_id = cm.company_id)))<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text) AND (cm.role = ANY (ARRAY['OWNER'::text, 'ADMIN'::text, 'DISPATCHER'::text, 'COMPLIANCE'::text])) AND ((dm.driver_account_id)::text = (storage.foldername(objects.name))[2]) AND (dm.status = 'APPROVED'::text)))))) |
| storage | objects | easyfleet_driver_documents_select | PERMISSIVE | {public} | SELECT | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[3] = ANY (ARRAY['licence'::text, 'identity'::text, 'profile'::text])) AND (((storage.foldername(name))[2] = ( SELECT (driver_accounts.id)::text AS id<br>   FROM driver_accounts<br>  WHERE (driver_accounts.auth_user_id = auth.uid()))) OR (EXISTS ( SELECT 1<br>   FROM (company_memberships cm<br>     JOIN driver_memberships dm ON ((dm.company_id = cm.company_id)))<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text) AND ((dm.driver_account_id)::text = (storage.foldername(objects.name))[2]) AND (dm.status = 'APPROVED'::text)))))) |  |
| storage | objects | easyfleet_trip_documents_insert | PERMISSIVE | {public} | INSERT |  | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'trips'::text) AND ((storage.foldername(name))[4] = ANY (ARRAY['pod'::text, 'receipts'::text])) AND ((EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text)))) OR (EXISTS ( SELECT 1<br>   FROM (fleet_trips ft<br>     JOIN driver_accounts da ON ((da.id = ft.driver_account_id)))<br>  WHERE (((ft.id)::text = (storage.foldername(objects.name))[3]) AND ((ft.company_id)::text = (storage.foldername(objects.name))[1]) AND (da.auth_user_id = auth.uid())))))) |
| storage | objects | easyfleet_trip_documents_select | PERMISSIVE | {public} | SELECT | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'trips'::text) AND ((storage.foldername(name))[4] = ANY (ARRAY['pod'::text, 'receipts'::text])) AND ((EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text)))) OR (EXISTS ( SELECT 1<br>   FROM (fleet_trips ft<br>     JOIN driver_accounts da ON ((da.id = ft.driver_account_id)))<br>  WHERE (((ft.id)::text = (storage.foldername(objects.name))[3]) AND ((ft.company_id)::text = (storage.foldername(objects.name))[1]) AND (da.auth_user_id = auth.uid())))))) |  |
| storage | objects | easyfleet_vehicle_documents_insert | PERMISSIVE | {public} | INSERT |  | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'vehicles'::text) AND ((storage.foldername(name))[4] = ANY (ARRAY['rc'::text, 'insurance'::text, 'fitness'::text, 'permit'::text, 'puc'::text, 'tax'::text, 'other'::text])) AND (EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text) AND (cm.role = ANY (ARRAY['OWNER'::text, 'ADMIN'::text, 'DISPATCHER'::text])))))) |
| storage | objects | easyfleet_vehicle_documents_select | PERMISSIVE | {public} | SELECT | ((bucket_id = 'easyfleet-private-documents'::text) AND (auth.role() = 'authenticated'::text) AND ((storage.foldername(name))[2] = 'vehicles'::text) AND ((storage.foldername(name))[4] = ANY (ARRAY['rc'::text, 'insurance'::text, 'fitness'::text, 'permit'::text, 'puc'::text, 'tax'::text, 'other'::text])) AND (EXISTS ( SELECT 1<br>   FROM company_memberships cm<br>  WHERE (((cm.company_id)::text = (storage.foldername(objects.name))[1]) AND (cm.user_id = auth.uid()) AND (cm.status = 'ACTIVE'::text))))) |  |


## 11. Table privileges

ACL codes: `r` SELECT, `a` INSERT, `w` UPDATE, `d` DELETE, `D` TRUNCATE, `x` REFERENCES, `t` TRIGGER, `m` MAINTAIN.

| schema_name | table_name | role_name | access_control_list |
|---|---|---|---|
| public | companies | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | company_drivers | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | company_memberships | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_accounts | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_employment_history | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_history_access_logs | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_history_evidence | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_history_reviews | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_incidents | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_ledger_entries | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_licences | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_memberships | postgres | {postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=r/postgres} |
| public | driver_verification_audit_logs | postgres |  |
| public | fleet_audit_events | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | fleet_challans | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | fleet_maintenance_jobs | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | fleet_trips | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | fleet_vehicle_documents | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | fleet_vehicles | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | trip_closures | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | trip_expenses | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | trip_fuel_entries | postgres | {postgres=arwdDxtm/postgres,authenticated=r/postgres} |
| public | trip_location_breadcrumbs | postgres |  |


## 12. Storage

### 12.1 Buckets

| id | name | public | file_size_limit | allowed_mime_types | created_at | updated_at |
|---|---|---|---|---|---|---|
| easyfleet-private-documents | easyfleet-private-documents | false | 20971520 | ["application/pdf", "image/jpeg", "image/png", "image/webp"] | 2026-10-30 18:45:33.607349+00 | 2026-10-30 18:45:33.607349+00 |

### 12.2 Storage policies are listed in section 10

## 13. Realtime

### 13.1 Publications

| pubname | puballtables | pubinsert | pubupdate | pubdelete | pubtruncate |
|---|---|---|---|---|---|
| supabase_realtime | false | true | true | true | true |

### 13.2 Published tables

| pubname | schemaname | tablename |
|---|---|---|
| supabase_realtime | public | driver_memberships |
| supabase_realtime | public | fleet_trips |
| supabase_realtime | public | trip_location_breadcrumbs |


## 14. Raw evidence

The exact read-only query files and JSON results used for this report are stored outside the repository at `/tmp/opencode/phase1b/backend/`.

- `00_environment.sql/json`
- `01_tables.sql/json`
- `02_columns.sql/json`
- `03_constraints.sql/json`
- `04_foreign_keys.sql/json`
- `05_indexes.sql/json`
- `06_types.sql/json`
- `07_enum_labels.sql/json`
- `08_functions.sql/json`
- `09_function_definitions.sql/json`
- `10_function_grants.sql/json`
- `11b_triggers_direct.sql/json`
- `12_rls_policies.sql/json`
- `13b_table_privileges.sql/json`
- `14_storage_buckets.sql/json`
- `15_realtime_publications.sql/json`
- `16_realtime_tables.sql/json`

## 15. Post-audit additive RPCs

The audit snapshot above was captured before implementation. During Phase 1B implementation, two additive functions were created and verified read-only. No existing object was replaced.

| Function | Arguments | Security definer | Search path | Grants |
|---|---|---|---|---|
| `public.easyfleet_submit_driver_licence` | `p_driver_account_id uuid, p_licence_class text, p_licence_fingerprint text, p_storage_path text` | true | `search_path=""` | `authenticated`, `postgres` |
| `public.easyfleet_submit_company_gst` | `p_company_id uuid, p_gstin text, p_legal_name text, p_storage_path text` | true | `search_path=""` | `authenticated`, `postgres` |

Both functions check `auth.uid()`, fully qualify catalog objects, write only through existing tables, and append audit events via the existing `public.easyfleet_write_audit_event` RPC.
