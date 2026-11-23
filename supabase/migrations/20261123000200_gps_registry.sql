-- EasyFleet Phase 2 migration 2: provider-independent GPS integration.
-- Additive only. Existing trip_location_breadcrumbs rows are preserved;
-- new columns are nullable or defaulted.

begin;

-- ---------------------------------------------------------------------------
-- 1. Provider catalog. Any number of providers can be registered; each
--    company stores its own credentials and field-mapping config.
-- ---------------------------------------------------------------------------
create table if not exists public.gps_providers (
  id text primary key,
  display_name text not null,
  adapter_kind text not null default 'GENERIC_HTTP_JSON'
    check (adapter_kind in ('GENERIC_HTTP_JSON')),
  credential_fields jsonb not null default '[]'::jsonb,
  default_config jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.gps_providers enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='gps_providers' and policyname='gps_providers_select') then
    create policy gps_providers_select on public.gps_providers
      for select to authenticated using (is_active);
  end if;
end $$;
grant select on public.gps_providers to authenticated;

insert into public.gps_providers (id, display_name, adapter_kind, credential_fields, default_config)
values (
  'generic_http_json',
  'Generic HTTP/JSON GPS provider',
  'GENERIC_HTTP_JSON',
  '[
    {"key": "api_key", "label": "API key / token", "secret": true},
    {"key": "api_secret", "label": "API secret (optional)", "secret": true},
    {"key": "username", "label": "Username (optional)", "secret": false},
    {"key": "password", "label": "Password (optional)", "secret": true}
  ]'::jsonb,
  '{
    "base_url": "",
    "positions_path": "/positions",
    "auth_style": "bearer",
    "auth_header": "Authorization",
    "device_param": "device_id",
    "items_pointer": "/data",
    "field_map": {
      "external_device_id": "device_id",
      "latitude": "latitude",
      "longitude": "longitude",
      "recorded_at": "timestamp",
      "speed_kmh": "speed",
      "heading": "heading",
      "accuracy_meters": "accuracy"
    },
    "time_format": "iso8601"
  }'::jsonb
)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 2. Per-company provider credentials, encrypted at rest with a vault key.
--    No SELECT policy: plaintext/ciphertext never leaves via PostgREST.
-- ---------------------------------------------------------------------------
create table if not exists public.gps_provider_credentials (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  provider_id text not null references public.gps_providers (id),
  label text not null default 'default',
  credentials_cipher bytea not null,
  config jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, provider_id, label)
);
alter table public.gps_provider_credentials enable row level security;
-- Access exclusively through SECURITY DEFINER RPCs below.

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'gps_provider_credentials_updated_at') then
    create trigger gps_provider_credentials_updated_at
      before update on public.gps_provider_credentials
      for each row execute function public.easyfleet_set_updated_at();
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 3. Device registry and vehicle mapping.
-- ---------------------------------------------------------------------------
create table if not exists public.gps_devices (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id),
  provider_id text not null references public.gps_providers (id),
  credential_id uuid references public.gps_provider_credentials (id),
  external_device_id text not null,
  imei text,
  sim_number text,
  label text,
  vehicle_id uuid references public.fleet_vehicles (id),
  status text not null default 'UNBOUND'
    check (status in ('UNBOUND', 'ACTIVE', 'OFFLINE', 'FAULTY')),
  last_seen_at timestamptz,
  last_latitude double precision,
  last_longitude double precision,
  created_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, provider_id, external_device_id)
);
create index if not exists gps_devices_vehicle_idx on public.gps_devices (vehicle_id);
alter table public.gps_devices enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='gps_devices' and policyname='gps_devices_select') then
    create policy gps_devices_select on public.gps_devices
      for select to authenticated using (public.is_company_member(company_id));
  end if;
end $$;
grant select on public.gps_devices to authenticated;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'gps_devices_updated_at') then
    create trigger gps_devices_updated_at
      before update on public.gps_devices
      for each row execute function public.easyfleet_set_updated_at();
  end if;
end $$;

create table if not exists public.gps_device_positions (
  id uuid primary key default gen_random_uuid(),
  device_id uuid not null references public.gps_devices (id),
  company_id uuid not null references public.companies (id),
  trip_id uuid references public.fleet_trips (id),
  latitude double precision not null,
  longitude double precision not null,
  speed_kmh double precision,
  heading double precision,
  accuracy_meters double precision,
  recorded_at timestamptz not null,
  received_at timestamptz not null default now(),
  unique (device_id, recorded_at)
);
create index if not exists gps_device_positions_company_time_idx
  on public.gps_device_positions (company_id, recorded_at desc);
create index if not exists gps_device_positions_trip_idx
  on public.gps_device_positions (trip_id, recorded_at);
alter table public.gps_device_positions enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='gps_device_positions' and policyname='gps_device_positions_select') then
    create policy gps_device_positions_select on public.gps_device_positions
      for select to authenticated using (public.is_company_member(company_id));
  end if;
end $$;
grant select on public.gps_device_positions to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Unified trip telemetry: extend breadcrumbs with source identification
--    and idempotency (native queue contract). Existing rows keep defaults.
-- ---------------------------------------------------------------------------
alter table public.trip_location_breadcrumbs
  add column if not exists source text not null default 'DRIVER_PHONE';
alter table public.trip_location_breadcrumbs
  add column if not exists device_id uuid references public.gps_devices (id);
alter table public.trip_location_breadcrumbs
  add column if not exists idempotency_key uuid;
alter table public.trip_location_breadcrumbs
  add column if not exists speed_kmh double precision;
alter table public.trip_location_breadcrumbs
  add column if not exists heading double precision;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'trip_location_breadcrumbs_source_check') then
    alter table public.trip_location_breadcrumbs
      add constraint trip_location_breadcrumbs_source_check
      check (source in ('DRIVER_PHONE', 'GPS_DEVICE'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'trip_location_breadcrumbs_idempotency_key_key') then
    alter table public.trip_location_breadcrumbs
      add constraint trip_location_breadcrumbs_idempotency_key_key unique (idempotency_key);
  end if;
end $$;

create or replace view public.trip_unified_locations
with (security_invoker = true) as
select
  b.id,
  b.trip_id,
  t.company_id,
  b.latitude,
  b.longitude,
  b.speed_kmh,
  b.heading,
  b.accuracy_meters,
  b.recorded_at,
  b.source,
  b.device_id
from public.trip_location_breadcrumbs b
join public.fleet_trips t on t.id = b.trip_id;
grant select on public.trip_unified_locations to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Credential management RPCs (manager-only, encrypted at rest).
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_set_gps_credentials(
  p_company_id uuid,
  p_provider_id text,
  p_label text,
  p_credentials_json jsonb,
  p_config jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_key text;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;
  if p_credentials_json is null or p_credentials_json = '{}'::jsonb then
    raise exception 'Credentials are required';
  end if;
  if not exists (select 1 from public.gps_providers where id = p_provider_id and is_active) then
    raise exception 'Unknown GPS provider';
  end if;

  select decrypted_secret into v_key
  from vault.decrypted_secrets where name = 'easyfleet_gps_credentials_key';

  insert into public.gps_provider_credentials (
    company_id, provider_id, label, credentials_cipher, config, created_by
  ) values (
    p_company_id, p_provider_id, coalesce(nullif(trim(p_label), ''), 'default'),
    extensions.pgp_sym_encrypt(p_credentials_json::text, v_key),
    coalesce(p_config, '{}'::jsonb), auth.uid()
  )
  on conflict (company_id, provider_id, label) do update set
    credentials_cipher = excluded.credentials_cipher,
    config = excluded.config,
    updated_at = now()
  returning id into v_id;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'GPS_CREDENTIALS', v_id, 'GPS_CREDENTIALS_UPDATED',
    gen_random_uuid(), jsonb_build_object('provider_id', p_provider_id, 'label', p_label)
  );
  return v_id;
end;
$$;
revoke all on function public.easyfleet_set_gps_credentials(uuid, text, text, jsonb, jsonb) from public;
grant execute on function public.easyfleet_set_gps_credentials(uuid, text, text, jsonb, jsonb) to authenticated;

create or replace function public.easyfleet_get_gps_credentials(p_credential_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row public.gps_provider_credentials%rowtype;
  v_key text;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into v_row from public.gps_provider_credentials where id = p_credential_id;
  if not found then raise exception 'Credentials not found'; end if;
  if not public.is_company_manager(v_row.company_id)
     and current_setting('role', true) <> 'service_role' then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;

  select decrypted_secret into v_key
  from vault.decrypted_secrets where name = 'easyfleet_gps_credentials_key';

  -- Access to provider secrets is itself audited.
  perform public.easyfleet_write_audit_event(
    v_row.company_id, 'GPS_CREDENTIALS', v_row.id, 'GPS_CREDENTIALS_ACCESSED',
    gen_random_uuid(), jsonb_build_object('provider_id', v_row.provider_id)
  );

  return jsonb_build_object(
    'id', v_row.id,
    'provider_id', v_row.provider_id,
    'label', v_row.label,
    'config', v_row.config,
    'credentials', extensions.pgp_sym_decrypt(v_row.credentials_cipher, v_key)::jsonb
  );
end;
$$;
revoke all on function public.easyfleet_get_gps_credentials(uuid) from public;
grant execute on function public.easyfleet_get_gps_credentials(uuid) to authenticated;

create or replace function public.easyfleet_list_gps_credentials(p_company_id uuid)
returns table (id uuid, provider_id text, label text, config jsonb, created_at timestamptz, updated_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select c.id, c.provider_id, c.label, c.config, c.created_at, c.updated_at
  from public.gps_provider_credentials c
  where c.company_id = p_company_id
    and (public.is_company_manager(p_company_id) or current_setting('role', true) = 'service_role')
  order by c.created_at;
$$;
revoke all on function public.easyfleet_list_gps_credentials(uuid) from public;
grant execute on function public.easyfleet_list_gps_credentials(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Device registration / assignment RPCs.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_register_gps_device(
  p_company_id uuid,
  p_device_id uuid,
  p_provider_id text,
  p_external_device_id text,
  p_credential_id uuid default null,
  p_imei text default null,
  p_sim_number text default null,
  p_label text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_existing public.gps_devices%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if p_device_id is null or nullif(trim(p_external_device_id), '') is null then
    raise exception 'Device ID and external device ID are required';
  end if;
  if not exists (select 1 from public.gps_providers where id = p_provider_id and is_active) then
    raise exception 'Unknown GPS provider';
  end if;
  if p_credential_id is not null and not exists (
    select 1 from public.gps_provider_credentials
    where id = p_credential_id and company_id = p_company_id and provider_id = p_provider_id
  ) then
    raise exception 'Credentials do not belong to this company and provider';
  end if;

  select * into v_existing from public.gps_devices where id = p_device_id for update;
  if found then
    if v_existing.company_id <> p_company_id then
      raise exception 'Device ID belongs to another company';
    end if;
    return p_device_id;
  end if;

  insert into public.gps_devices (
    id, company_id, provider_id, credential_id, external_device_id,
    imei, sim_number, label, created_by
  ) values (
    p_device_id, p_company_id, p_provider_id, p_credential_id, trim(p_external_device_id),
    nullif(trim(p_imei), ''), nullif(trim(p_sim_number), ''), nullif(trim(p_label), ''), auth.uid()
  )
  on conflict (company_id, provider_id, external_device_id) do update set
    credential_id = coalesce(excluded.credential_id, public.gps_devices.credential_id),
    imei = coalesce(excluded.imei, public.gps_devices.imei),
    sim_number = coalesce(excluded.sim_number, public.gps_devices.sim_number),
    label = coalesce(excluded.label, public.gps_devices.label),
    updated_at = now()
  returning id into p_device_id;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'GPS_DEVICE', p_device_id, 'GPS_DEVICE_REGISTERED',
    p_device_id, jsonb_build_object('provider_id', p_provider_id, 'external_device_id', trim(p_external_device_id))
  );
  return p_device_id;
end;
$$;
revoke all on function public.easyfleet_register_gps_device(uuid, uuid, text, text, uuid, text, text, text) from public;
grant execute on function public.easyfleet_register_gps_device(uuid, uuid, text, text, uuid, text, text, text) to authenticated;

create or replace function public.easyfleet_assign_gps_device(
  p_company_id uuid,
  p_device_id uuid,
  p_vehicle_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_device public.gps_devices%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;

  select * into v_device from public.gps_devices
  where id = p_device_id and company_id = p_company_id for update;
  if not found then raise exception 'Device not found in this company'; end if;

  if p_vehicle_id is not null then
    if not exists (
      select 1 from public.fleet_vehicles where id = p_vehicle_id and company_id = p_company_id
    ) then
      raise exception 'Vehicle not found in this company';
    end if;
    -- One active device per vehicle: unbind any other device on this vehicle.
    update public.gps_devices
    set vehicle_id = null, status = 'UNBOUND', updated_at = now()
    where vehicle_id = p_vehicle_id and company_id = p_company_id and id <> p_device_id;
  end if;

  update public.gps_devices
  set vehicle_id = p_vehicle_id,
      status = case when p_vehicle_id is null then 'UNBOUND' else 'ACTIVE' end,
      updated_at = now()
  where id = p_device_id;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'GPS_DEVICE', p_device_id, 'GPS_DEVICE_ASSIGNED',
    gen_random_uuid(), jsonb_build_object('vehicle_id', p_vehicle_id)
  );
  return p_device_id;
end;
$$;
revoke all on function public.easyfleet_assign_gps_device(uuid, uuid, uuid) from public;
grant execute on function public.easyfleet_assign_gps_device(uuid, uuid, uuid) to authenticated;

create or replace function public.easyfleet_set_gps_device_status(
  p_company_id uuid,
  p_device_id uuid,
  p_status text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if p_status not in ('UNBOUND', 'ACTIVE', 'OFFLINE', 'FAULTY') then
    raise exception 'Invalid device status';
  end if;
  update public.gps_devices set status = p_status, updated_at = now()
  where id = p_device_id and company_id = p_company_id;
  if not found then raise exception 'Device not found in this company'; end if;
  return p_device_id;
end;
$$;
revoke all on function public.easyfleet_set_gps_device_status(uuid, uuid, text) from public;
grant execute on function public.easyfleet_set_gps_device_status(uuid, uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Position ingestion: device positions + unified trip breadcrumbs.
--    Called by the transporter sync adapter (operator) or a server worker.
-- ---------------------------------------------------------------------------
create or replace function public.easyfleet_ingest_device_positions(
  p_company_id uuid,
  p_device_id uuid,
  p_positions jsonb,
  p_idempotency_key uuid
)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_device public.gps_devices%rowtype;
  v_trip_id uuid;
  v_point jsonb;
  v_recorded timestamptz;
  v_lat double precision;
  v_lng double precision;
  v_inserted integer := 0;
  v_request jsonb;
  v_last_ts timestamptz;
  v_last_lat double precision;
  v_last_lng double precision;
begin
  if auth.uid() is null and current_setting('role', true) <> 'service_role' then
    raise exception 'Authentication required';
  end if;
  if current_setting('role', true) <> 'service_role'
     and not public.is_company_operator(p_company_id) then
    raise exception 'Company operator permission required';
  end if;
  if p_idempotency_key is null then raise exception 'Idempotency key required'; end if;
  if p_positions is null or jsonb_typeof(p_positions) <> 'array' then
    raise exception 'Positions must be a JSON array';
  end if;
  if jsonb_array_length(p_positions) > 500 then
    raise exception 'Batch too large (max 500 points)';
  end if;

  select * into v_device from public.gps_devices
  where id = p_device_id and company_id = p_company_id for update;
  if not found then raise exception 'Device not found in this company'; end if;

  v_request := jsonb_build_object('device_id', p_device_id, 'positions', p_positions);
  perform pg_advisory_xact_lock(hashtextextended(p_company_id::text || ':' || p_idempotency_key::text, 0));
  if public.easyfleet_request_replay(
    p_company_id, p_idempotency_key, 'GPS_DEVICE', p_device_id, 'GPS_POSITIONS_INGESTED', v_request
  ) then
    return 0;
  end if;

  -- Resolve the trip this vehicle is currently running (if any).
  if v_device.vehicle_id is not null then
    select ft.id into v_trip_id
    from public.fleet_trips ft
    where ft.company_id = p_company_id
      and ft.vehicle_id = v_device.vehicle_id
      and ft.status in ('IN_TRANSIT', 'ASSIGNED')
    order by case ft.status when 'IN_TRANSIT' then 0 else 1 end, ft.created_at desc
    limit 1;
  end if;

  for v_point in select * from jsonb_array_elements(p_positions) loop
    v_lat := (v_point->>'latitude')::double precision;
    v_lng := (v_point->>'longitude')::double precision;
    v_recorded := (v_point->>'recorded_at')::timestamptz;
    if v_lat is null or v_lng is null or v_recorded is null
       or v_lat < -90 or v_lat > 90 or v_lng < -180 or v_lng > 180 then
      raise exception 'Invalid position point: %', v_point;
    end if;

    insert into public.gps_device_positions (
      device_id, company_id, trip_id, latitude, longitude,
      speed_kmh, heading, accuracy_meters, recorded_at
    ) values (
      p_device_id, p_company_id, v_trip_id, v_lat, v_lng,
      (v_point->>'speed_kmh')::double precision,
      (v_point->>'heading')::double precision,
      (v_point->>'accuracy_meters')::double precision,
      v_recorded
    )
    on conflict (device_id, recorded_at) do nothing;

    if found then
      v_inserted := v_inserted + 1;
      if v_trip_id is not null then
        insert into public.trip_location_breadcrumbs (
          trip_id, latitude, longitude, accuracy_meters, recorded_at,
          source, device_id, speed_kmh, heading
        ) values (
          v_trip_id, v_lat, v_lng,
          coalesce((v_point->>'accuracy_meters')::double precision, 0),
          v_recorded, 'GPS_DEVICE', p_device_id,
          (v_point->>'speed_kmh')::double precision,
          (v_point->>'heading')::double precision
        )
        on conflict do nothing;
      end if;
      if v_last_ts is null or v_recorded > v_last_ts then
        v_last_ts := v_recorded; v_last_lat := v_lat; v_last_lng := v_lng;
      end if;
    end if;
  end loop;

  if v_last_ts is not null then
    update public.gps_devices
    set last_seen_at = greatest(coalesce(last_seen_at, '-infinity'::timestamptz), v_last_ts),
        last_latitude = v_last_lat,
        last_longitude = v_last_lng,
        status = case when status = 'FAULTY' then 'FAULTY' else 'ACTIVE' end,
        updated_at = now()
    where id = p_device_id;
  end if;

  perform public.easyfleet_write_audit_event(
    p_company_id, 'GPS_DEVICE', p_device_id, 'GPS_POSITIONS_INGESTED',
    p_idempotency_key, jsonb_build_object('request', v_request, 'inserted', v_inserted)
  );
  return v_inserted;
end;
$$;
revoke all on function public.easyfleet_ingest_device_positions(uuid, uuid, jsonb, uuid) from public;
grant execute on function public.easyfleet_ingest_device_positions(uuid, uuid, jsonb, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 8. Realtime for device telemetry.
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.gps_devices;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.gps_device_positions;
  exception when duplicate_object then null;
  end;
end $$;

commit;
