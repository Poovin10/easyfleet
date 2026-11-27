-- EasyFleet Phase 2 migration 12: manual (non-app) company drivers.
--
-- Transporters need to register drivers who do not use the Driver app. This
-- RPC creates a driver account with no auth user and immediately adds an
-- approved company membership through the existing guarded RPC. No existing
-- rows, columns, policies or grants are changed.

begin;

create or replace function public.easyfleet_add_manual_company_driver(
  p_company_id uuid,
  p_display_name text,
  p_phone_e164 text default null,
  p_local_driver_code text default null
) returns uuid
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_driver_account_id uuid;
  v_company_driver_id uuid;
  v_name text;
  v_phone text;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required';
  end if;
  if not public.is_company_manager(p_company_id) then
    raise exception 'Active OWNER or ADMIN company membership required';
  end if;

  v_name := nullif(btrim(coalesce(p_display_name, '')), '');
  if v_name is null then
    raise exception 'Driver name is required';
  end if;

  v_phone := nullif(btrim(coalesce(p_phone_e164, '')), '');
  if v_phone is not null and v_phone !~ '^\+?[0-9][0-9 ()-]{5,18}$' then
    raise exception 'Enter a valid phone number';
  end if;

  insert into public.driver_accounts (
    auth_user_id, display_name, phone_e164, identity_status
  ) values (null, v_name, v_phone, 'PENDING')
  returning id into v_driver_account_id;

  v_company_driver_id := public.easyfleet_add_company_driver(
    p_company_id, v_driver_account_id, p_local_driver_code
  );

  perform public.easyfleet_write_audit_event(
    p_company_id,
    'COMPANY_DRIVER',
    v_company_driver_id,
    'MANUAL_DRIVER_ADDED',
    gen_random_uuid(),
    jsonb_build_object(
      'driver_account_id', v_driver_account_id,
      'display_name', v_name
    )
  );

  return v_driver_account_id;
end;
$$;

revoke all on function public.easyfleet_add_manual_company_driver(uuid, text, text, text) from public;
grant execute on function public.easyfleet_add_manual_company_driver(uuid, text, text, text) to authenticated;

notify pgrst, 'reload schema';

commit;
