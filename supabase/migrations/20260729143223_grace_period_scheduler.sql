-- PAY-05 (TECH_SPEC_v1.2.md 5.5, 6.4): переход active -> grace -> expired по расписанию.

create extension if not exists pg_cron with schema extensions;

create or replace function public.sweep_subscription_grace_periods()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- active -> grace: подписка формально истекла, даём 24ч
  update public.subscriptions
  set status = 'grace',
      grace_expires_at = expires_at + interval '24 hours',
      updated_at = now()
  where status = 'active'
    and expires_at is not null
    and expires_at < now();

  -- grace -> expired: истёк grace-период
  update public.subscriptions
  set status = 'expired',
      updated_at = now()
  where status = 'grace'
    and grace_expires_at is not null
    and grace_expires_at < now();
end;
$$;

select cron.schedule(
  'sweep-subscription-grace-periods',
  '*/15 * * * *',
  $$select public.sweep_subscription_grace_periods();$$
);
