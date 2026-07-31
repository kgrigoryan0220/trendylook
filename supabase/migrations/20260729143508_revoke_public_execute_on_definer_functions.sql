-- Закрываем найденный advisor'ом security lint: SECURITY DEFINER функции
-- не должны быть вызываемы через PostgREST RPC (/rest/v1/rpc/...) публично.

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.sweep_subscription_grace_periods() from public, anon, authenticated;
