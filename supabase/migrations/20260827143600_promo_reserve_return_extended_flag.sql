-- Добавляем в возврат reserve_promo_redemption признак, был ли уже
-- активен Pro на момент редима (нужно для ответа redeem-promo: "extended").
drop function public.reserve_promo_redemption(text, uuid);

create function public.reserve_promo_redemption(p_code text, p_user_id uuid)
returns table (
  redemption_id uuid,
  promo_code_id uuid,
  granted_expires_at timestamptz,
  extended boolean
)
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_code record;
  v_current_expires timestamptz;
  v_granted_expires timestamptz;
  v_redemption_id uuid;
begin
  select * into v_code
  from public.promo_codes
  where code = upper(trim(p_code))
  for update;

  if not found then
    raise exception 'code_not_found' using errcode = 'P0001';
  end if;

  if not v_code.is_active then
    raise exception 'code_expired' using errcode = 'P0002';
  end if;

  if v_code.valid_until is not null and v_code.valid_until < now() then
    raise exception 'code_expired' using errcode = 'P0002';
  end if;

  if v_code.redemption_count >= v_code.max_redemptions then
    raise exception 'code_exhausted' using errcode = 'P0003';
  end if;

  if exists (
    select 1 from public.promo_redemptions
    where promo_code_id = v_code.id and user_id = p_user_id
  ) then
    raise exception 'already_redeemed' using errcode = 'P0004';
  end if;

  select expires_at into v_current_expires
  from public.subscriptions
  where user_id = p_user_id and status in ('active', 'grace')
  limit 1;

  v_granted_expires := greatest(
    coalesce(v_current_expires, now()),
    now() + make_interval(days => v_code.duration_days)
  );

  update public.promo_codes
  set redemption_count = redemption_count + 1,
      updated_at = now()
  where id = v_code.id;

  insert into public.promo_redemptions (promo_code_id, user_id, granted_expires_at)
  values (v_code.id, p_user_id, v_granted_expires)
  returning id into v_redemption_id;

  return query select v_redemption_id, v_code.id, v_granted_expires, (v_current_expires is not null);
end;
$$;

comment on function public.reserve_promo_redemption is
  'Вызывается только из redeem-promo (service role) ДО обращения к RevenueCat API. При ошибке RC вызывающий обязан откатить через release_promo_redemption.';

revoke execute on function public.reserve_promo_redemption(text, uuid) from public, anon, authenticated;
grant execute on function public.reserve_promo_redemption(text, uuid) to service_role;
