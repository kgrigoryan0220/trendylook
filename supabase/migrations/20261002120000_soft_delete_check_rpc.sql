-- HIST-03: soft-delete with hard failure if no row updated.
-- Drop previous boolean-returning signature if present (CREATE OR REPLACE
-- cannot change return type).
drop function if exists public.soft_delete_check(uuid);

-- SECURITY DEFINER bypasses RLS edge-cases; ownership via auth.uid().
-- Raises on failure so the Flutter client doesn't depend on boolean parsing.

create function public.soft_delete_check(p_id uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  updated_count int;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  update public.checks
  set deleted_at = now()
  where id = p_id
    and user_id = auth.uid()
    and deleted_at is null;

  get diagnostics updated_count = row_count;

  if updated_count = 0 then
    raise exception 'check_not_found_or_forbidden' using errcode = 'P0001';
  end if;
end;
$$;

revoke all on function public.soft_delete_check(uuid) from public;
grant execute on function public.soft_delete_check(uuid) to authenticated;

comment on function public.soft_delete_check(uuid) is
  'Soft-deletes own check (sets deleted_at). Raises if nothing updated.';
