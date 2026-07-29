-- Perf advisor fix: auth.<function>() re-evaluated per-row in RLS policies.
-- Wrap in (select ...) so Postgres caches it as an InitPlan.

drop policy "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles
  for select using ((select auth.uid()) = id);

drop policy "Users update own profile" on public.profiles;
create policy "Users update own profile" on public.profiles
  for update using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

drop policy "Users read own checks" on public.checks;
create policy "Users read own checks" on public.checks
  for select using ((select auth.uid()) = user_id and deleted_at is null);

drop policy "Users soft-delete own checks" on public.checks;
create policy "Users soft-delete own checks" on public.checks
  for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

drop policy "Users read own subscription" on public.subscriptions;
create policy "Users read own subscription" on public.subscriptions
  for select using ((select auth.uid()) = user_id);
