-- EasyFleet Phase 2 backend test suite.
-- Runs inside a transaction that is rolled back: no test data persists.
-- Role simulation: SET LOCAL ROLE authenticated + request.jwt.claims.

begin;

create temp table test_results (seq serial, name text, ok boolean, detail text);
grant all on test_results to public;
grant usage, select on sequence test_results_seq_seq to public;

-- Fixture IDs captured as postgres (RLS hides driver_accounts from other users).
create temp table fx (k text primary key, v uuid);
grant all on fx to public;

-- ---------------------------------------------------------------------------
-- Fixtures (as postgres)
-- ---------------------------------------------------------------------------
insert into auth.users (id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
values
  ('11111111-1111-4111-8111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase2-transporter@test.easyfleet', 'x', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"display_name":"Test Transporter"}'),
  ('22222222-2222-4222-8222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase2-driver@test.easyfleet', 'x', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"display_name":"Test Driver","app_role":"driver"}'),
  ('33333333-3333-4333-8333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase2-office@test.easyfleet', 'x', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"display_name":"Test Office"}'),
  ('44444444-4444-4444-8444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'phase2-outsider@test.easyfleet', 'x', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"display_name":"Test Outsider"}');

insert into public.platform_staff (user_id, staff_role)
values ('33333333-3333-4333-8333-333333333333', 'VERIFICATION_OFFICER');

-- ---------------------------------------------------------------------------
-- Transporter: company registration + trial subscription
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

do $$
declare v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
begin
  perform public.easyfleet_create_company(v_company, 'Test Transport Co', 'Test Transport Company Pvt Ltd');
  insert into test_results(name, ok, detail)
  select 'company registration', exists(select 1 from public.companies where id = v_company), '';
  insert into test_results(name, ok, detail)
  select 'owner membership created', exists(select 1 from public.company_memberships where company_id = v_company and role = 'OWNER' and status = 'ACTIVE'), '';
  insert into test_results(name, ok, detail)
  select 'trial subscription seeded', exists(select 1 from public.company_subscriptions where company_id = v_company and status = 'TRIAL' and valid_until > now()), '';
end $$;

-- GST submission
do $$
declare v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
begin
  perform public.easyfleet_submit_company_gst(v_company, '29ABCDE1234F1Z5', 'Test Transport Company Pvt Ltd', v_company::text || '/company_documents/gst.jpg');
  insert into test_results(name, ok, detail)
  select 'gst submission pending', (select gst_verification_status from public.companies where id = v_company) = 'PENDING', '';
  insert into test_results(name, ok, detail)
  select 'gst submission history', exists(select 1 from public.document_review_history where company_id = v_company and decision = 'SUBMITTED'), '';
end $$;

-- Company cannot self-approve GST
do $$
begin
  begin
    perform public.easyfleet_review_company_gst('aaaaaaaa-0000-4000-8000-000000000001', 'APPROVED', null, gen_random_uuid());
    insert into test_results(name, ok, detail) values ('gst self-approval blocked', false, 'no exception raised');
  exception when others then
    insert into test_results(name, ok, detail) values ('gst self-approval blocked', true, sqlerrm);
  end;
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Driver: account bootstrap + DL submission
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';

do $$
declare v_da uuid;
begin
  v_da := public.easyfleet_create_driver_account('Test Driver');
  insert into test_results(name, ok, detail)
  select 'driver account bootstrap', v_da is not null, '';
  -- idempotent second call
  insert into test_results(name, ok, detail)
  select 'driver bootstrap idempotent', public.easyfleet_create_driver_account('Test Driver') = v_da, '';
  perform public.easyfleet_submit_driver_licence(v_da, 'HMV', 'KL0120200001234', 'personal/' || v_da::text || '/licence/dl.jpg');
  insert into test_results(name, ok, detail)
  select 'dl submission pending', (select verification_status from public.driver_licences where driver_account_id = v_da) = 'PENDING', '';
  insert into test_results(name, ok, detail)
  select 'dl encrypted at rest', (select encrypted_dl is not null and length(encrypted_dl) > 0 from public.driver_licences where driver_account_id = v_da), '';
  insert into test_results(name, ok, detail)
  select 'dl owner can read own licence', exists(select 1 from public.driver_licences where driver_account_id = v_da), '';
end $$;

reset role;
insert into fx values ('driver_account_id', (select id from public.driver_accounts where auth_user_id = '22222222-2222-4222-8222-222222222222'));

-- ---------------------------------------------------------------------------
-- Office: DL/GST verification, B-01 repair
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}';

do $$
declare v_da uuid;
begin
  select v into v_da from fx where k = 'driver_account_id';
  -- rejection requires reason
  begin
    perform public.easyfleet_review_driver_licence(v_da, 'REJECTED', null, gen_random_uuid());
    insert into test_results(name, ok, detail) values ('dl rejection requires reason', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('dl rejection requires reason', true, sqlerrm);
  end;
  -- B-01 repaired RPC works against driver_licences
  perform public.set_driver_official_verification_status(v_da, 'MANUAL_REVIEW_REQUIRED', 'checking');
  insert into test_results(name, ok, detail)
  select 'B-01 repair: review-required', (select verification_status from public.driver_licences where driver_account_id = v_da) = 'REVIEW_REQUIRED', '';
  -- office approval
  perform public.easyfleet_review_driver_licence(v_da, 'APPROVED', 'documents clear', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'office dl approval', (select verification_status from public.driver_licences where driver_account_id = v_da) = 'VERIFIED', '';
  insert into test_results(name, ok, detail)
  select 'dl review history recorded', exists(select 1 from public.document_review_history where driver_account_id = v_da and decision = 'APPROVED'), '';
  insert into test_results(name, ok, detail)
  select 'legacy verification audit log written', exists(select 1 from public.driver_verification_audit_logs where driver_account_id = v_da), '';
  -- office GST approval
  perform public.easyfleet_review_company_gst('aaaaaaaa-0000-4000-8000-000000000001', 'APPROVED', null, gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'office gst approval', (select gst_verification_status from public.companies where id = 'aaaaaaaa-0000-4000-8000-000000000001') = 'VERIFIED', '';
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Transporter: Rs 100 driver contact lookup billing
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

do $$
declare
  v_da uuid;
  v_key uuid := 'dddddddd-0000-4000-8000-000000000009';
  v_contact jsonb;
begin
  select v into v_da from fx where k = 'driver_account_id';
  v_contact := public.easyfleet_lookup_driver_contact(v_da, v_key);
  insert into test_results(name, ok, detail)
  select 'contact lookup returns verified driver',
         v_contact->>'driver_account_id' = v_da::text
         and v_contact ? 'phone_e164', '';
  insert into test_results(name, ok, detail)
  select 'contact lookup billed 100 INR',
         (select amount_inr = 100 and purpose = 'CONTACT_LOOKUP'
          from public.payment_transactions where idempotency_key = v_key), '';

  -- Replay is idempotent: same contact, no second charge.
  v_contact := public.easyfleet_lookup_driver_contact(v_da, v_key);
  insert into test_results(name, ok, detail)
  select 'contact lookup replay is idempotent',
         (v_contact->>'already_unlocked')::boolean
         and (select count(*) = 1 from public.payment_transactions
              where idempotency_key = v_key), '';
end $$;

reset role;

-- Outsider cannot verify
set local role authenticated;
set local request.jwt.claims = '{"sub":"44444444-4444-4444-8444-444444444444","role":"authenticated"}';
do $$
declare v_da uuid;
begin
  select v into v_da from fx where k = 'driver_account_id';
  begin
    perform public.set_driver_official_verification_status(v_da, 'OFFICIALLY_VERIFIED', '');
    insert into test_results(name, ok, detail) values ('unauthorized verification blocked', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('unauthorized verification blocked', true, sqlerrm);
  end;
  begin
    perform public.easyfleet_review_driver_licence(v_da, 'APPROVED', null, gen_random_uuid());
    insert into test_results(name, ok, detail) values ('unauthorized office review blocked', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('unauthorized office review blocked', true, sqlerrm);
  end;
  insert into test_results(name, ok, detail)
  select 'RLS: outsider sees no licences', not exists(select 1 from public.driver_licences), '';
  insert into test_results(name, ok, detail)
  select 'RLS: outsider sees no trips', not exists(select 1 from public.fleet_trips), '';
  insert into test_results(name, ok, detail)
  select 'RLS: outsider sees no payments', not exists(select 1 from public.payment_transactions), '';
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Transporter: vehicle, driver, trip, subscription enforcement
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

do $$
declare
  v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
  v_vehicle uuid := 'bbbbbbbb-0000-4000-8000-000000000001';
  v_da uuid;
  v_cd uuid;
  v_trip uuid := 'cccccccc-0000-4000-8000-000000000001';
  v_key uuid := 'dddddddd-0000-4000-8000-000000000001';
  v_doc uuid;
begin
  select v into v_da from fx where k = 'driver_account_id';
  perform public.easyfleet_create_vehicle(v_company, v_vehicle, 'KL01AB1234', 'TRUCK', 'Tata', 'LPT', 2022, 16, 1000, null);
  insert into test_results(name, ok, detail)
  select 'vehicle created', exists(select 1 from public.fleet_vehicles where id = v_vehicle), '';
  -- replay same vehicle id + same payload returns id
  insert into test_results(name, ok, detail)
  select 'vehicle replay idempotent', public.easyfleet_create_vehicle(v_company, v_vehicle, 'KL01AB1234', 'TRUCK', 'Tata', 'LPT', 2022, 16, 1000, null) = v_vehicle, '';

  v_doc := public.easyfleet_add_vehicle_document(
    v_company, v_vehicle, 'rc',
    v_company::text || '/vehicles/' || v_vehicle::text || '/rc/rc.jpg',
    'KL01AB1234'
  );
  insert into test_results(name, ok, detail)
  select 'vehicle compliance document registered',
         exists(select 1 from public.fleet_vehicle_documents where id = v_doc), '';
  begin
    perform public.easyfleet_add_vehicle_document(
      v_company, v_vehicle, 'rc', 'wrong/path/rc.jpg', 'KL01AB1234'
    );
    insert into test_results(name, ok, detail)
    values ('vehicle document path validated', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail)
    values ('vehicle document path validated', sqlerrm like 'INVALID_STORAGE_PATH%', sqlerrm);
  end;

  v_cd := public.easyfleet_add_company_driver(v_company, v_da, null);
  insert into test_results(name, ok, detail)
  select 'company driver + approved membership', exists(select 1 from public.driver_memberships where company_id = v_company and driver_account_id = v_da and status = 'APPROVED'), '';

  perform public.easyfleet_create_trip(v_company, v_trip, 'Kochi', 'Chennai', current_date + 1, v_key, v_vehicle, v_cd, v_da, 'GC-001', 'Steel', 10, 25000, 500, 550);
  insert into test_results(name, ok, detail)
  select 'trip created ASSIGNED', (select status from public.fleet_trips where id = v_trip) = 'ASSIGNED', '';
  insert into test_results(name, ok, detail)
  select 'vehicle marked ASSIGNED', (select status from public.fleet_vehicles where id = v_vehicle) = 'ASSIGNED', '';
  insert into test_results(name, ok, detail)
  select 'trip replay idempotent', public.easyfleet_create_trip(v_company, v_trip, 'Kochi', 'Chennai', current_date + 1, v_key, v_vehicle, v_cd, v_da, 'GC-001', 'Steel', 10, 25000, 500, 550) = v_trip, '';
  -- same key, different payload must conflict
  begin
    perform public.easyfleet_create_trip(v_company, v_trip, 'Kochi', 'Bangalore', current_date + 1, v_key, v_vehicle, v_cd, v_da, 'GC-001', 'Steel', 10, 25000, 500, 550);
    insert into test_results(name, ok, detail) values ('trip idempotency conflict detected', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('trip idempotency conflict detected', true, sqlerrm);
  end;
end $$;

-- Subscription enforcement: expire the trial as postgres, then retry.
reset role;
update public.company_subscriptions set valid_until = now() - interval '1 day', status = 'EXPIRED'
where company_id = 'aaaaaaaa-0000-4000-8000-000000000001';
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

do $$
declare
  v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
  v_trip2 uuid := 'cccccccc-0000-4000-8000-000000000002';
  v_sub uuid;
  v_until timestamptz;
  v_pay_key uuid := 'eeeeeeee-0000-4000-8000-000000000001';
begin
  begin
    perform public.easyfleet_create_trip(v_company, v_trip2, 'Kochi', 'Madurai', current_date + 2, gen_random_uuid());
    insert into test_results(name, ok, detail) values ('expired subscription blocks trips', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail)
    values ('expired subscription blocks trips', sqlerrm like 'SUBSCRIPTION_REQUIRED%', sqlerrm);
  end;

  v_sub := public.easyfleet_pay_subscription(v_company, 'TRANSPORTER_MONTHLY', 'MANUAL', v_pay_key, null, 'test payment');
  insert into test_results(name, ok, detail)
  select 'subscription activated', (select status from public.company_subscriptions where id = v_sub) = 'ACTIVE', '';
  insert into test_results(name, ok, detail)
  select 'payment recorded at plan price', exists(select 1 from public.payment_transactions where subscription_id = v_sub and amount_inr = 1500 and purpose = 'SUBSCRIPTION'), '';
  insert into test_results(name, ok, detail)
  select 'payment replay idempotent', public.easyfleet_pay_subscription(v_company, 'TRANSPORTER_MONTHLY', 'MANUAL', v_pay_key, null, 'test payment') = v_sub, '';
  insert into test_results(name, ok, detail)
  select 'no duplicate payment on replay', (select count(*) from public.payment_transactions where idempotency_key = v_pay_key) = 1, '';

  select valid_until into v_until from public.company_subscriptions where id = v_sub;
  perform public.easyfleet_pay_subscription(v_company, 'TRANSPORTER_MONTHLY', 'UPI', gen_random_uuid(), 'upi-ref-123', null);
  insert into test_results(name, ok, detail)
  select 'renewal extends validity', (select valid_until from public.company_subscriptions where id = v_sub) > v_until, '';
  insert into test_results(name, ok, detail)
  select 'renewal recorded', exists(select 1 from public.payment_transactions where subscription_id = v_sub and purpose = 'RENEWAL' and method = 'UPI'), '';
  begin
    perform public.easyfleet_pay_subscription(v_company, 'TRANSPORTER_MONTHLY', 'RAZORPAY', gen_random_uuid(), null, null);
    insert into test_results(name, ok, detail) values ('gateway payment requires reference', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('gateway payment requires reference', true, sqlerrm);
  end;

  perform public.easyfleet_create_trip(v_company, v_trip2, 'Kochi', 'Madurai', current_date + 2, gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'active subscription allows trips', exists(select 1 from public.fleet_trips where id = v_trip2), '';
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Driver: start trip, fuel, expense, breakdown, breadcrumbs
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';

do $$
declare
  v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
  v_trip uuid := 'cccccccc-0000-4000-8000-000000000001';
  v_fuel uuid := 'ffffffff-0000-4000-8000-000000000001';
  v_exp uuid := 'ffffffff-0000-4000-8000-000000000002';
  v_job uuid := 'ffffffff-0000-4000-8000-000000000003';
  v_bc uuid := 'ffffffff-0000-4000-8000-000000000004';
  v_key uuid := 'ffffffff-0000-4000-8000-000000000005';
begin
  perform public.easyfleet_start_trip(v_company, v_trip, 1000, gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'driver starts trip', (select status from public.fleet_trips where id = v_trip) = 'IN_TRANSIT', '';
  insert into test_results(name, ok, detail)
  select 'vehicle ON_TRIP', (select status from public.fleet_vehicles where id = 'bbbbbbbb-0000-4000-8000-000000000001') = 'ON_TRIP', '';

  perform public.easyfleet_add_fuel_entry(v_company, v_trip, v_fuel, 'DIESEL', 120, 11000, v_key, 91.5, 'HP Pump Kochi', 1100, 'BILL-1', null, now());
  insert into test_results(name, ok, detail)
  select 'fuel entry recorded', exists(select 1 from public.trip_fuel_entries where id = v_fuel), '';
  insert into test_results(name, ok, detail)
  select 'fuel replay idempotent', public.easyfleet_add_fuel_entry(v_company, v_trip, v_fuel, 'DIESEL', 120, 11000, v_key, 91.5, 'HP Pump Kochi', 1100, 'BILL-1', null, now()) = v_fuel, '';
  perform public.easyfleet_add_fuel_entry(v_company, v_trip, gen_random_uuid(), 'ADBLUE', 10, 600, gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'adblue shares fuel table', exists(select 1 from public.trip_fuel_entries where trip_id = v_trip and fuel_type = 'ADBLUE'), '';

  perform public.easyfleet_add_expense_entry(v_company, v_trip, v_exp, 'TOLL', 450, gen_random_uuid(), 'Highway toll', 1200, null, null);
  insert into test_results(name, ok, detail)
  select 'expense recorded pending', (select approval_status from public.trip_expenses where id = v_exp) = 'PENDING', '';

  perform public.easyfleet_report_breakdown(v_company, v_trip, v_job, 'Brake noise', gen_random_uuid(), 1300, 'Near Salem');
  insert into test_results(name, ok, detail)
  select 'breakdown reported', exists(select 1 from public.fleet_maintenance_jobs where id = v_job and status = 'REPORTED'), '';

  perform public.easyfleet_capture_breadcrumb(v_trip, v_bc, 9.9312, 76.2673, now(), v_key, 8);
  perform public.easyfleet_capture_breadcrumb(v_trip, gen_random_uuid(), 9.94, 76.27, now(), v_key, 8);
  insert into test_results(name, ok, detail)
  select 'breadcrumb idempotent (1 row)', (select count(*) from public.trip_location_breadcrumbs where idempotency_key = v_key) = 1, '';
  insert into test_results(name, ok, detail)
  select 'driver reads own trip', exists(select 1 from public.fleet_trips where id = v_trip), '';
  insert into test_results(name, ok, detail)
  select 'driver reads own fuel entries', exists(select 1 from public.trip_fuel_entries where trip_id = v_trip), '';
  insert into test_results(name, ok, detail)
  select 'driver reads trip audit history', exists(select 1 from public.fleet_audit_events where entity_id = v_trip), '';
  insert into test_results(name, ok, detail)
  select 'driver received notifications', exists(select 1 from public.notifications where user_id = '22222222-2222-4222-8222-222222222222'), '';
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Transporter: expense review, maintenance, GPS, marketplace, closure
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

do $$
declare
  v_company uuid := 'aaaaaaaa-0000-4000-8000-000000000001';
  v_trip uuid := 'cccccccc-0000-4000-8000-000000000001';
  v_vehicle uuid := 'bbbbbbbb-0000-4000-8000-000000000001';
  v_exp uuid := 'ffffffff-0000-4000-8000-000000000002';
  v_maint uuid := 'ffffffff-0000-4000-8000-000000000003';
  v_cred uuid;
  v_device uuid := '99999999-0000-4000-8000-000000000001';
  v_ingest_key uuid := '99999999-0000-4000-8000-000000000002';
  v_points jsonb;
  v_n integer;
  v_da uuid;
  v_job_post uuid := '88888888-0000-4000-8000-000000000001';
  v_app uuid;
  v_assignment uuid := '88888888-0000-4000-8000-000000000002';
  v_closure uuid := '88888888-0000-4000-8000-000000000003';
begin
  perform public.easyfleet_review_expense(v_company, v_exp, 'APPROVED', 'ok', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'expense approved', (select approval_status from public.trip_expenses where id = v_exp) = 'APPROVED', '';

  perform public.easyfleet_update_maintenance_job(v_company, v_maint, 'SENT', 'Salem Workshop', 5000, null, null, null, gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'maintenance sent', (select status from public.fleet_maintenance_jobs where id = v_maint) = 'SENT', '';

  -- GPS credentials: encrypted roundtrip
  v_cred := public.easyfleet_set_gps_credentials(v_company, 'generic_http_json', 'primary',
    '{"api_key":"secret-test-key-123"}'::jsonb,
    '{"base_url":"https://gps.example.com","positions_path":"/positions"}'::jsonb);
  insert into test_results(name, ok, detail)
  select 'gps credentials stored', v_cred is not null, '';
  insert into fx values ('gps_credential_id', v_cred);
  insert into test_results(name, ok, detail)
  select 'gps credentials decrypt roundtrip',
    (public.easyfleet_get_gps_credentials(v_cred)->'credentials'->>'api_key') = 'secret-test-key-123', '';
  insert into test_results(name, ok, detail)
  select 'gps credential list masked', not exists(
    select 1 from public.easyfleet_list_gps_credentials(v_company) l where l.config ? 'api_key'), '';

  perform public.easyfleet_register_gps_device(v_company, v_device, 'generic_http_json', 'DEV-001', v_cred, '356938035643809', '919876543210', 'Truck tracker');
  perform public.easyfleet_assign_gps_device(v_company, v_device, v_vehicle);
  insert into test_results(name, ok, detail)
  select 'device assigned to vehicle', (select vehicle_id from public.gps_devices where id = v_device) = v_vehicle, '';

  v_points := jsonb_build_array(
    jsonb_build_object('latitude', 10.0, 'longitude', 76.3, 'recorded_at', (now() - interval '2 minutes')::text, 'speed_kmh', 45),
    jsonb_build_object('latitude', 10.1, 'longitude', 76.4, 'recorded_at', (now() - interval '1 minute')::text, 'speed_kmh', 50)
  );
  v_n := public.easyfleet_ingest_device_positions(v_company, v_device, v_points, v_ingest_key);
  insert into test_results(name, ok, detail) values ('gps ingest inserts points', v_n = 2, 'inserted=' || v_n);
  insert into test_results(name, ok, detail)
  select 'gps replay returns 0', public.easyfleet_ingest_device_positions(v_company, v_device, v_points, v_ingest_key) = 0, '';
  insert into test_results(name, ok, detail)
  select 'unified trip view has device source', exists(
    select 1 from public.trip_unified_locations where trip_id = v_trip and source = 'GPS_DEVICE'), '';
  insert into test_results(name, ok, detail)
  select 'device last_seen updated', (select last_seen_at is not null from public.gps_devices where id = v_device), '';

  -- Marketplace
  perform public.easyfleet_post_job(v_company, v_job_post, 'HMV driver Kochi-Chennai', gen_random_uuid(),
    'Steel load', 'Kochi', 'Chennai', 'Steel', 10, 'TRUCK', array['HMV'], 'Kochi', 'Kerala', 25000, 'PER_TRIP', current_date + 3);
  insert into test_results(name, ok, detail)
  select 'job posted', exists(select 1 from public.job_postings where id = v_job_post and status = 'OPEN'), '';

  select v into v_da from fx where k = 'driver_account_id';
  insert into test_results(name, ok, detail)
  select 'verified driver discoverable', exists(
    select 1 from public.easyfleet_search_drivers('HMV', null, 50) d where d.driver_account_id = v_da), '';

  -- Closure review by transporter (driver submitted below in driver section)
  perform public.easyfleet_add_ledger_entry(v_company, gen_random_uuid(), v_da, 'ADVANCE', 500, gen_random_uuid(), v_trip, 'Trip advance');
  insert into test_results(name, ok, detail)
  select 'ledger advance recorded', exists(select 1 from public.driver_ledger_entries where driver_account_id = v_da and entry_type = 'ADVANCE'), '';
end $$;

reset role;

-- Driver applies to job; outsider cannot
set local role authenticated;
set local request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';
do $$
declare v_app uuid;
begin
  v_app := public.easyfleet_apply_to_job('88888888-0000-4000-8000-000000000001', gen_random_uuid(), 'I know this route', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'driver application created', exists(select 1 from public.job_applications where id = v_app and status = 'APPLIED'), '';
  insert into test_results(name, ok, detail)
  select 'duplicate application idempotent', public.easyfleet_apply_to_job('88888888-0000-4000-8000-000000000001', gen_random_uuid(), 'I know this route', gen_random_uuid()) = v_app, '';
  insert into test_results(name, ok, detail)
  select 'driver reads open jobs', exists(select 1 from public.job_postings where status = 'OPEN'), '';
  -- driver submits closure
  perform public.easyfleet_submit_trip_closure('aaaaaaaa-0000-4000-8000-000000000001',
    'cccccccc-0000-4000-8000-000000000001', '88888888-0000-4000-8000-000000000003', gen_random_uuid(),
    1550, 550, 1500, 500, true, null, 'Delivered');
  insert into test_results(name, ok, detail)
  select 'closure submitted', (select status from public.fleet_trips where id = 'cccccccc-0000-4000-8000-000000000001') = 'CLOSURE_PENDING', '';
  -- driver reads own ledger
  insert into test_results(name, ok, detail)
  select 'driver reads own ledger', exists(select 1 from public.driver_ledger_entries), '';
end $$;
reset role;

set local role authenticated;
set local request.jwt.claims = '{"sub":"44444444-4444-4444-8444-444444444444","role":"authenticated"}';
do $$
begin
  begin
    perform public.easyfleet_apply_to_job('88888888-0000-4000-8000-000000000001', gen_random_uuid(), null, null);
    insert into test_results(name, ok, detail) values ('non-driver cannot apply', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('non-driver cannot apply', true, sqlerrm);
  end;
  begin
    perform public.easyfleet_post_job('aaaaaaaa-0000-4000-8000-000000000001', gen_random_uuid(), 'hack', gen_random_uuid());
    insert into test_results(name, ok, detail) values ('outsider cannot post jobs', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('outsider cannot post jobs', true, sqlerrm);
  end;
  begin
    perform public.easyfleet_get_gps_credentials((select v from fx where k = 'gps_credential_id'));
    insert into test_results(name, ok, detail) values ('outsider cannot read gps credentials', false, 'no exception');
  exception when others then
    insert into test_results(name, ok, detail) values ('outsider cannot read gps credentials', true, sqlerrm);
  end;
  insert into test_results(name, ok, detail)
  select 'RLS: outsider sees no devices', not exists(select 1 from public.gps_devices), '';
  insert into test_results(name, ok, detail)
  select 'RLS: outsider sees no applications', not exists(select 1 from public.job_applications), '';
end $$;
reset role;

-- Transporter appoints driver, reviews closure
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
do $$
declare v_app uuid;
begin
  select id into v_app from public.job_applications where job_id = '88888888-0000-4000-8000-000000000001';
  perform public.easyfleet_review_application(v_app, 'SHORTLISTED', 'good profile', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'application shortlisted', (select status from public.job_applications where id = v_app) = 'SHORTLISTED', '';
  perform public.easyfleet_appoint_driver(v_app, '88888888-0000-4000-8000-000000000002', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'appointment atomic: assignment', exists(select 1 from public.job_assignments where id = '88888888-0000-4000-8000-000000000002' and status = 'ACTIVE'), '';
  insert into test_results(name, ok, detail)
  select 'appointment: job filled', (select status from public.job_postings where id = '88888888-0000-4000-8000-000000000001') = 'FILLED', '';
  insert into test_results(name, ok, detail)
  select 'appointment: application appointed', (select status from public.job_applications where id = v_app) = 'APPOINTED', '';

  perform public.easyfleet_review_trip_closure('aaaaaaaa-0000-4000-8000-000000000001',
    '88888888-0000-4000-8000-000000000003', 'APPROVED', 'POD verified', gen_random_uuid());
  insert into test_results(name, ok, detail)
  select 'closure approved -> trip completed', (select status from public.fleet_trips where id = 'cccccccc-0000-4000-8000-000000000001') = 'COMPLETED', '';
  insert into test_results(name, ok, detail)
  select 'vehicle released + odometer updated', (select status = 'AVAILABLE' and odometer_km >= 1550 from public.fleet_vehicles where id = 'bbbbbbbb-0000-4000-8000-000000000001'), '';
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Integrity: append-only audit + review history
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    update public.fleet_audit_events set event_type = 'HACKED' where id = (select id from public.fleet_audit_events limit 1);
    insert into test_results(name, ok, detail) values ('audit events immutable', false, 'update succeeded');
  exception when others then
    insert into test_results(name, ok, detail) values ('audit events immutable', true, sqlerrm);
  end;
  begin
    delete from public.document_review_history where id = (select id from public.document_review_history limit 1);
    insert into test_results(name, ok, detail) values ('review history immutable', false, 'delete succeeded');
  exception when others then
    insert into test_results(name, ok, detail) values ('review history immutable', true, sqlerrm);
  end;
end $$;

-- ---------------------------------------------------------------------------
-- PostgREST embedded relationships used by the Flutter clients.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into test_results(name, ok, detail)
  select 'trips -> driver_accounts relationship',
         exists(select 1 from pg_constraint where conrelid = 'public.fleet_trips'::regclass and conname = 'fleet_trips_driver_account_fkey'),
         'embedded driver_accounts(display_name)';
  insert into test_results(name, ok, detail)
  select 'ledger -> driver_accounts relationship',
         exists(select 1 from pg_constraint where conrelid = 'public.driver_ledger_entries'::regclass and conname = 'driver_ledger_entries_driver_account_fkey'),
         'embedded driver_accounts(display_name)';
end $$;

-- ---------------------------------------------------------------------------
-- Manual (non-app) drivers created by a transporter.
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
do $$
declare v_driver uuid;
begin
  v_driver := public.easyfleet_add_manual_company_driver(
    'aaaaaaaa-0000-4000-8000-000000000001', 'Manual Driver',
    '+919876543210', 'MAN-1'
  );
  insert into test_results(name, ok, detail)
  select 'manual driver account has no auth user',
         exists(select 1 from public.driver_accounts where id = v_driver and auth_user_id is null), '';
  insert into test_results(name, ok, detail)
  select 'manual driver company link created',
         exists(select 1 from public.company_drivers where company_id = 'aaaaaaaa-0000-4000-8000-000000000001' and driver_account_id = v_driver), '';
  insert into test_results(name, ok, detail)
  select 'manual driver membership approved',
         exists(select 1 from public.driver_memberships where company_id = 'aaaaaaaa-0000-4000-8000-000000000001' and driver_account_id = v_driver and status = 'APPROVED'), '';
  insert into test_results(name, ok, detail)
  select 'manual driver audit recorded',
         exists(select 1 from public.fleet_audit_events where company_id = 'aaaaaaaa-0000-4000-8000-000000000001' and event_type = 'MANUAL_DRIVER_ADDED'), '';
end $$;
reset role;

select name, ok, detail from test_results order by seq;

rollback;
