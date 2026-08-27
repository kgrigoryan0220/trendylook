-- Advisors: default privileges на public-схеме автоматически дают anon/
-- authenticated EXECUTE на новые функции — revoke from public в исходной
-- миграции этого не перекрывает (как и для handle_new_user/sweep_*, см.
-- 20260729143508_revoke_public_execute_on_definer_functions.sql).

revoke execute on function public.reserve_promo_redemption(text, uuid) from public, anon, authenticated;
revoke execute on function public.release_promo_redemption(uuid) from public, anon, authenticated;
revoke execute on function public.confirm_promo_redemption(uuid, text) from public, anon, authenticated;

-- normalize_promo_code — обычный trigger-функция без нужды в API-доступе,
-- но advisor всё равно требует зафиксированный search_path.
alter function public.normalize_promo_code() set search_path to 'public';
revoke execute on function public.normalize_promo_code() from public, anon, authenticated;

-- Индекс под FK subscriptions.promo_code_id (advisor: unindexed_foreign_keys).
create index idx_subscriptions_promo_code on public.subscriptions(promo_code_id);

-- RLS enabled без политик на promo_codes — намеренно (только service role),
-- но advisor "rls_enabled_no_policy" остаётся информационным без explicit
-- deny-политики. Явная политика "нет доступа" убирает шум и документирует
-- намерение прямо в схеме.
create policy "No client access" on public.promo_codes
  for all
  to authenticated, anon
  using (false);
