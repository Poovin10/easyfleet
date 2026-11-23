-- EasyFleet Phase 2 migration 10: vehicle compliance document registration.
-- The storage bucket already permits company managers/DISPATCHERs to upload
-- vehicle documents, but fleet_vehicle_documents had no INSERT grant. This
-- RPC records the metadata after a successful private Storage upload and
-- validates that the object path belongs to the same company/vehicle/type.

begin;

create or replace function public.easyfleet_add_vehicle_document(
  p_company_id uuid,
  p_vehicle_id uuid,
  p_document_type text,
  p_storage_object_path text,
  p_document_number text default null,
  p_issue_date date default null,
  p_expiry_date date default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_registration text;
  v_type_lower text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if not exists (
    select 1 from public.company_memberships cm
    where cm.company_id = p_company_id
      and cm.user_id = (select auth.uid())
      and cm.status = 'ACTIVE'
      and cm.role in ('OWNER', 'ADMIN', 'DISPATCHER')
  ) then
    raise exception 'Active company membership required';
  end if;

  select fv.registration_number into v_registration
  from public.fleet_vehicles fv
  where fv.id = p_vehicle_id and fv.company_id = p_company_id;
  if not found then
    raise exception 'VEHICLE_NOT_FOUND';
  end if;

  -- Storage policies use lowercase folder names; the metadata table uses
  -- uppercase enum-like values. Normalise once at the boundary.
  v_type_lower := lower(trim(coalesce(p_document_type, '')));
  if v_type_lower not in ('rc', 'insurance', 'fitness', 'permit', 'puc', 'tax', 'other') then
    raise exception 'INVALID_DOCUMENT_TYPE';
  end if;

  -- Storage policy path shape: <company>/vehicles/<vehicle>/<type>/<file>
  if p_storage_object_path is null
     or split_part(p_storage_object_path, '/', 1) <> p_company_id::text
     or split_part(p_storage_object_path, '/', 2) <> 'vehicles'
     or split_part(p_storage_object_path, '/', 3) <> p_vehicle_id::text
     or split_part(p_storage_object_path, '/', 4) <> v_type_lower then
    raise exception 'INVALID_STORAGE_PATH';
  end if;

  v_id := gen_random_uuid();
  insert into public.fleet_vehicle_documents (
    id, company_id, vehicle_id, document_type, document_number,
    issue_date, expiry_date, applicable, storage_object_path, notes, created_by
  ) values (
    v_id, p_company_id, p_vehicle_id, upper(v_type_lower),
    nullif(trim(p_document_number), ''), p_issue_date, p_expiry_date, true,
    p_storage_object_path, nullif(trim(p_notes), ''), (select auth.uid())
  );

  perform public.easyfleet_write_audit_event(
    p_company_id, 'FLEET_VEHICLE', p_vehicle_id, 'VEHICLE_DOCUMENT_ADDED',
    v_id,
    jsonb_build_object(
      'document_type', p_document_type,
      'registration_number', v_registration,
      'storage_object_path', p_storage_object_path
    )
  );
  return v_id;
end;
$$;

revoke all on function public.easyfleet_add_vehicle_document(uuid, uuid, text, text, text, date, date, text) from public;
grant execute on function public.easyfleet_add_vehicle_document(uuid, uuid, text, text, text, date, date, text) to authenticated;

commit;
