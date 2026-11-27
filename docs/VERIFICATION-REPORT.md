# EasyFleet Flutter — implementation & verification report

Date: 2026-11-27
Repository: `git@github.com:Poovin10/easyfleet.git` (branch `main`)
Supabase project: `iktekjnisqmbjtoictnc` (production)

## 1. Scope completed in this pass

- **Driver app**
  - Trip-start dialog cancellation no longer starts a trip with a null odometer.
  - Continuous GPS capture via an Android foreground service (`location` type),
    sharing the idempotent SQLite outbox with the UI sync loop. Active trip id
    survives process restart; stop cancels the timer and service.
  - Password change now requires the current password (verified by Supabase).
  - Connectivity and minimum-version gates are wired into the app root.
- **Transporter app**
  - ₹100 driver contact unlock: confirmation dialog, stable idempotency key,
    phone reveal, server-side billing via `easyfleet_lookup_driver_contact`.
  - Vehicle compliance documents: private Storage upload + RPC registration,
    list per vehicle, type/path validation on the backend.
  - Password change now requires the current password.
  - Same connectivity/version gates as the driver app.
- **Shared packages / backend**
  - `DriverContact` domain model, network service methods and table/RPC names.
  - Sync auth failures release the outbox claim without consuming a retry.
  - `connectivityStreamProvider` emits the current state before live changes.
  - Migrations 8–11 applied to the remote database with history repaired only
    after confirming the objects existed; no migration was replayed blindly.
  - Rollback script, migration inventory and GPS integration docs updated.

### Follow-up fixes (same-day)

- **Email confirmation link landed on `localhost:3000`.** Supabase Auth had
  `site_url=http://localhost:3000` and an empty redirect allowlist.
  `site_url` is now `https://app.easyfleet.in/auth/callback` and the allowlist
  (`uri_allow_list`) contains that URL plus
  `com.easyfleet.driver://auth/callback` and
  `com.easyfleet.transporter://auth/callback`. Both apps now pass the matching
  `emailRedirectTo` to `signUp`/`signInWithOtp`, declare the custom-scheme
  intent filter (Android) and URL scheme (iOS), and `supabase_flutter` exchanges
  the PKCE code for a session when the link is opened on the device. Old links
  already in inboxes still point at `localhost`; use a fresh confirmation
  email. Email verification remains enabled — it was not disabled to mask the
  redirect bug.
- **PostgREST "could not find a relationship between `fleet_trips` and
  `driver_accounts` in the schema cache".** The apps embed
  `driver_accounts(display_name)` in trip and ledger queries, but those tables
  only had a composite FK via `company_drivers`. Migration 11 adds direct FKs
  for `fleet_trips.driver_account_id` and `driver_ledger_entries.driver_account_id`
  and reloads the PostgREST schema. Backend coverage grew to 88 assertions.

### Follow-up fixes (2026-11-27): installed-app UI gaps

- **Empty-looking Settings.** Both Settings tabs now contain explicit
  sections: account identity, profile/document shortcuts, security (password),
  offline-sync diagnostics, app version and sign-out. Transporter Settings also
  links to company profile/GST, trucks & compliance, drivers, subscription, GPS
  devices, accounting and notifications.
- **Transporter could not add a manual driver.** A "Drivers" tab now has an
  **Add driver** action backed by the new `easyfleet_add_manual_company_driver`
  RPC. It creates an account with no auth user, links it to the company and
  grants an approved membership. Migration 13 adds a scoped
  `driver_accounts_company_read` policy so company reviewers can actually see
  those manually added drivers (the owner/staff-only SELECT policies hid them).
- **Truck/compliance entry point was not discoverable.** Transporter navigation
  now includes a **Fleet** tab. The Vehicles screen has **Add truck**, a
  **Compliance** tab listing every truck's uploaded documents (type, number,
  expiry) and an **Upload compliance document** action; Settings deep-links to
  the same screen.
- Migrations 12 and 13 were applied individually to production and their
  history rows repaired only after verifying the objects existed. Backend
  coverage grew from 88 to 92 assertions.

## 2. Verification results actually observed

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | PASS — 110 files, 0 changed |
| `flutter analyze` | PASS — No issues found |
| Driver tests (`flutter test`) | PASS — 6/6 (new Settings screen test) |
| Transporter tests (`flutter test`) | PASS — 9/9 (new Settings, manual driver, compliance tests) |
| Domain package tests | PASS — 7/7 |
| Network package tests | PASS — 7/7 |
| Sync package tests | PASS — 9/9 (includes auth-release contract tests) |
| Backend `phase2_backend_tests.sql` (rolled-back transaction) | PASS — 92/92 assertions |
| Live catalog recheck | 37 tables / 60 functions / 46 policies / 13 Phase-2 history rows |
| Android debug builds | See §3 |
| GitHub Actions CI | Not triggered — no GitHub API token available in this environment; every CI step was reproduced locally (see above) |
| APK install/launch on device | Not possible — no Android device or emulator is attached; APK integrity checked with Android build tools instead |

## 3. APK artifacts

Both were built from the final staged source with:

```bash
flutter build apk --debug \
  --dart-define=SUPABASE_URL=https://iktekjnisqmbjtoictnc.supabase.co \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=APP_VERSION=1.0.0
```

| App | Exact path | Bytes | SHA-256 |
|---|---|---:|---|
| Driver | `/home/ubuntu/easyfleet-flutter/apps/driver/build/app/outputs/flutter-apk/app-debug.apk` | 234,815,342 | `554dcd63763fe4c464a4d7bbede0b6485ca49bc23c3c133d40abfbee9ea3fb47` |
| Transporter | `/home/ubuntu/easyfleet-flutter/apps/transporter/build/app/outputs/flutter-apk/app-debug.apk` | 232,257,461 | `6c789ee0ce77a2ef3f34dcbc1bc87e70384994c81bba9ad1fb1542451fc28442` |

Build outcomes: driver `✓ Built` in 77.2 s; transporter `✓ Built` in 69.5 s.
The rebuilt kernel snapshots contain the new strings (`DL profile & documents`
in Driver; `Add driver manually`, `Upload compliance document` and
`Trucks & compliance` in Transporter), confirming the shipped APKs include the
fixes rather than only the source tree.
`aapt2 dump badging` confirms `com.easyfleet.driver` and
`com.easyfleet.transporter`, both `versionName=1.0.0`, `minSdk=29`,
`targetSdk=36`. `aapt dump xmltree` on both APKs confirms the new
`com.easyfleet.<app>://auth/callback` and `https://app.easyfleet.in/auth/callback`
intent filters are present in the shipped manifests. Flutter also emitted
matching `.apk.sha1` sidecar files.

No device or emulator is attached (`adb devices` empty), so an actual
install/launch could not be observed; this is the only unverified mandatory
check. GitHub Actions CI was likewise not triggered because no GitHub API
token is available. The workflow YAML parses successfully and all of its
validate/build steps were executed locally with the results above.

## 4. Known remaining limitations (not blockers for delivery)

- Offline reads are not cached; queued writes sync on reconnect, but screens
  require a live Supabase connection for data.
- Push notification delivery (FCM/OneSignal) and payment gateway webhook
  verification are server-side extension points; local Realtime notifications
  and manual/provider-reference payments are implemented.
- Vendor GPS feeds require each transporter's own API credentials and adapter
  config; continuous server-side ingestion needs an external scheduler.
- Office-only DL/GST approval UI is intentionally out of scope for these two
  driver/transporter apps.

## 5. Migration / deployment notes

- `supabase migration list --remote=...` now shows all thirteen Phase-2 versions
  (`20261123*` and `20261124*`) present locally **and** remotely, plus ten older
  remote-only Phase-1 migrations that must not be reverted or replayed. Because
  those older files are absent locally, `supabase db push` intentionally refuses
  to run; apply new versions individually with `supabase db query --file ...`
  (as done for migrations 8–13) or sync them into a scratch checkout with
  `supabase db pull`.
- `supabase/rollback/20261123_phase2_rollback.sql` covers the original ten
  versions and aborts if new tables contain data. It should only be run after
  rolling the apps back to the Phase-1B commit; migrations 11–13 add constraints,
  an RPC and a policy rather than new data tables.
- GitHub Actions requires the repository variable `SUPABASE_PUBLISHABLE_KEY`;
  no secret of any kind is committed to this repository.
- The shipped APKs are **debug** builds with only the publishable anon key
  injected. Production signing, `assetlinks.json`, FCM and payment webhooks
  remain deployment tasks.

## 6. Reproduce the checks

```bash
cd easyfleet-flutter
dart format --output=none --set-exit-if-changed .
flutter analyze
for d in apps/driver apps/transporter packages/domain packages/network packages/sync; do
  (cd "$d" && flutter test)
done
supabase db query --remote=iktekjnisqmbjtoictnc \
  --file supabase/tests/phase2_backend_tests.sql --output-format json
```
