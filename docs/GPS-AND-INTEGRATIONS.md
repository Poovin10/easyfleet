# EasyFleet — GPS Provider Integration & External Integrations

## Architecture (provider-independent)

```
┌────────────────────┐        ┌─────────────────────────────┐
│ Driver phone GPS   │        │ Transporter GPS devices     │
│ geolocator stream  │        │ (any vendor, per company)   │
│ ~15 s / 10 m       │        │                             │
└────────┬───────────┘        └──────────────┬──────────────┘
         │ offline queue                     │ GenericHttpJsonAdapter
         │ (sqflite outbox)                  │ fetch with company credentials
         ▼                                   ▼
easyfleet_capture_breadcrumb      easyfleet_ingest_device_positions
         │                                   │
         ▼                                   ▼
   trip_location_breadcrumbs  ◄──── gps_device_positions
   source = DRIVER_PHONE            source = GPS_DEVICE
         │
         ▼
   trip_unified_locations (security-invoker view)
         │
         ▼
   Driver trip map / Transporter fleet map (flutter_map + OSM)
```

Key properties:

- **No vendor lock-in.** Providers are rows in `gps_providers`; each company
  stores its own credentials and field-mapping config. Two transporters can
  use different vendors simultaneously.
- **Credentials encrypted at rest** with `pgp_sym_encrypt` using a key held
  in Supabase Vault (`easyfleet_gps_credentials_key`). The credentials table
  has no SELECT policy; access is only through manager-scoped RPCs, and every
  plaintext read is written to `fleet_audit_events`
  (`GPS_CREDENTIALS_ACCESSED`).
- **Source identification.** Every unified point carries `source`
  (`DRIVER_PHONE` | `GPS_DEVICE`) and optional `device_id`.
- **Offline & stale handling.** Phone breadcrumbs queue locally with
  idempotency keys and retry ≤ 5 times before dead-letter. Auth/expired-session
  failures release the queue claim without consuming an attempt. Devices are
  shown OFFLINE/stale when `last_seen_at` is older than 30 minutes.
- **Continuous driver capture.** Starting trip tracking launches a foreground
  service (`flutter_background_service`, Android `foregroundServiceType=
  location`). Its isolate captures a high-accuracy fix every 15 s for the
  active trip, writes it through the same idempotent SQLite outbox, and
  flushes to `easyfleet_capture_breadcrumb` when online. The notification shows
  queued/synced counts; stopping the trip cancels the timer and service. The
  active trip id survives process restarts via SharedPreferences.
  The app still needs location "Always allow"/background permission from the
  user and an OEM battery-optimization exemption on some Android devices.
- **Idempotent ingestion.** Batches ≤ 500 points; duplicate
  `(device_id, recorded_at)` points are skipped; replayed batch keys return 0.
- **Trip association.** Ingestion resolves the vehicle's current
  IN_TRANSIT/ASSIGNED trip and mirrors points into the unified breadcrumb
  stream, which is published for Realtime.

## Adding a GPS provider

1. Register the provider (server-side, postgres/service_role):

```sql
insert into public.gps_providers (id, display_name, adapter_kind, credential_fields, default_config)
values (
  'my_vendor',
  'My GPS Vendor',
  'GENERIC_HTTP_JSON',
  '[{"key":"api_key","label":"API token","secret":true}]',
  '{
     "base_url": "https://api.myvendor.com",
     "positions_path": "/v2/positions",
     "auth_style": "bearer",
     "device_param": "device",
     "items_pointer": "/result/items",
     "field_map": {
       "latitude": "lat", "longitude": "lon",
       "recorded_at": "gps_time", "speed_kmh": "speed", "heading": "course"
     },
     "time_format": "epoch_seconds"
   }'
);
```

2. In the Transporter app: **GPS devices → Configure** — pick the provider,
   enter the company's API credentials and base URL. Values are encrypted
   server-side.
3. **Register device** with the vendor's device id (IMEI/SIM optional), then
   **Assign vehicle**.
4. **Sync now** fetches positions through the adapter and ingests them. For
   continuous sync, schedule the same call (e.g. WorkManager or a server
   cron calling `easyfleet_ingest_device_positions` with service_role).

### Adapter config reference (`GenericHttpJsonAdapter`)

| Key | Meaning | Default |
|---|---|---|
| `base_url` | API origin (required) | — |
| `positions_path` | path appended to base_url | `/positions` |
| `auth_style` | `bearer` / `header` / `query` / `basic` | `bearer` |
| `auth_header` | header name for `header` style | `Authorization` |
| `auth_query_param` | query param for `query` style | `key` |
| `credential_key` | credential field holding the token | `api_key` |
| `device_param` | query param carrying the device id | `device_id` |
| `since_param` | optional start-time filter param | — |
| `items_pointer` | JSON pointer to the array (`''` = root) | `/data` |
| `field_map` | normalized field → vendor field | identity names |
| `time_format` | `iso8601` / `epoch_seconds` / `epoch_millis` | `iso8601` |

Non-HTTP/JSON vendors: implement `GpsProviderAdapter` in
`packages/network/lib/src/gps_provider_adapter.dart` and register a new
`adapter_kind`. The ingestion contract (`NormalizedPosition.toJson`) stays
identical.

Unit tests: `packages/network/test/gps_adapter_test.dart` (field mapping,
auth styles, epoch parsing, invalid-point filtering, ordering).

## Maps

Both apps use `flutter_map` with OpenStreetMap tiles — **no maps API key is
required**. The previous `google_maps_flutter` dependency and
`MAPS_API_KEY` manifest placeholders were removed.

## Payment gateway extension point

Subscription payments are recorded through `easyfleet_pay_subscription` with
method `MANUAL`, `UPI`, `RAZORPAY` or `OTHER`. UPI/Razorpay require a provider
reference. The server stores the transaction and activates the subscription;
**gateway webhook verification is the designated extension point**: deploy a
Supabase Edge Function that validates the Razorpay webhook signature and
calls the same RPC with `service_role`. No gateway secrets exist in the mobile
apps. Pricing is server-authoritative (`subscription_plans`), ₹1,500 / 30
days, no transaction fees.

## Notifications

All business events (DL/GST submission & review, job applications,
appointments, breakdowns, expense reviews, ledger entries, trip cancellation)
create recipient-scoped rows in `notifications`, published for Realtime and
rendered in both apps with unread badges and mark-read support.
