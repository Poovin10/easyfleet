-- EasyFleet Phase 2 migration 13: let company reviewers read linked driver
-- accounts. Manual drivers have no auth_user_id, so the existing owner/staff
-- SELECT policies hide them from the transporter who created them. The new
-- policy only exposes accounts already linked to a company the caller reviews.

begin;

create policy driver_accounts_company_read
  on public.driver_accounts
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.company_drivers cd
      where cd.driver_account_id = driver_accounts.id
        and public.is_company_history_reviewer(cd.company_id)
    )
  );

notify pgrst, 'reload schema';

commit;
