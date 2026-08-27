-- Промокоды (PROMO_CODES_PLAN.md, разд. 3): выдача Pro через RevenueCat
-- promotional entitlement, локально фиксируем только каталог кодов и
-- журнал активаций. Источник истины по entitlement остаётся subscriptions
-- (пишется тем же revenuecat-webhook), redeem-promo лишь инициирует grant.

alter type plan_type add value if not exists 'promo';

alter table public.subscriptions
  add column if not exists source text not null default 'revenuecat',
  add column if not exists promo_code_id uuid;

alter table public.subscriptions
  add constraint subscriptions_source_check check (source in ('revenuecat', 'promo'));

create table public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  max_redemptions integer not null check (max_redemptions >= 1),
  redemption_count integer not null default 0 check (redemption_count >= 0),
  duration_days integer not null check (duration_days between 1 and 365),
  valid_until timestamptz null,
  is_active boolean not null default true,
  note text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.promo_codes is
  'Каталог промокодов. Создаются вручную админом через Table Editor (см. PROMO_CODES_PLAN.md, разд. 8). Недоступны authenticated/anon — только service role (redeem-promo).';

-- Нормализация кода (UPPER, без пробелов) на случай, если админ ввёл
-- код в другом регистре через Table Editor — RPC ниже всегда ищет по
-- upper(trim(code)), так что хранимое значение должно совпадать.
create function public.normalize_promo_code()
returns trigger
language plpgsql
as $$
begin
  new.code := upper(trim(new.code));
  return new;
end;
$$;

create trigger promo_codes_normalize_code
  before insert or update of code on public.promo_codes
  for each row execute function public.normalize_promo_code();

alter table public.subscriptions
  add constraint subscriptions_promo_code_id_fkey
  foreign key (promo_code_id) references public.promo_codes(id);

create table public.promo_redemptions (
  id uuid primary key default gen_random_uuid(),
  promo_code_id uuid not null references public.promo_codes(id),
  user_id uuid not null references public.profiles(id),
  granted_expires_at timestamptz not null,
  revenuecat_request_id text null,
  redeemed_at timestamptz not null default now(),
  unique (promo_code_id, user_id)
);

comment on table public.promo_redemptions is
  'Журнал активаций. Строка резервируется атомарно RPC reserve_promo_redemption ДО вызова RevenueCat API (redemption_count уже инкрементирован); если grant в RC не удался, redeem-promo откатывает через release_promo_redemption.';

create index idx_promo_redemptions_user on public.promo_redemptions(user_id);

alter table public.promo_codes enable row level security;
alter table public.promo_redemptions enable row level security;

-- promo_codes: без политик для authenticated/anon -> полностью закрыта,
-- кроме service role (та же модель, что и pg_cron функции ниже).
create policy "Users read own redemptions" on public.promo_redemptions
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- Резервирует слот атомарно: блокирует строку promo_codes, валидирует
-- (active/valid_until/limit/дубликат), сразу инкрементирует
-- redemption_count и создаёт запись в promo_redemptions — это и есть
-- граница атомарности, т.к. последующий вызов RevenueCat API снаружи
-- транзакции удержать нельзя. При неудаче RC вызывающий обязан вызвать
-- release_promo_redemption, иначе слот считается использованным навсегда.
create function public.reserve_promo_redemption(p_code text, p_user_id uuid)
returns table (
  redemption_id uuid,
  promo_code_id uuid,
  granted_expires_at timestamptz
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

  return query select v_redemption_id, v_code.id, v_granted_expires;
end;
$$;

comment on function public.reserve_promo_redemption is
  'Вызывается только из redeem-promo (service role) ДО обращения к RevenueCat API. При ошибке RC вызывающий обязан откатить через release_promo_redemption.';

-- Откат резервации, если grant в RevenueCat не удался — освобождает
-- слот (decrement) и удаляет запись, чтобы пользователь мог повторить.
create function public.release_promo_redemption(p_redemption_id uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_promo_code_id uuid;
begin
  delete from public.promo_redemptions
  where id = p_redemption_id
  returning promo_code_id into v_promo_code_id;

  if v_promo_code_id is not null then
    update public.promo_codes
    set redemption_count = greatest(redemption_count - 1, 0),
        updated_at = now()
    where id = v_promo_code_id;
  end if;
end;
$$;

comment on function public.release_promo_redemption is
  'Откат reserve_promo_redemption при неудаче RevenueCat grant. Вызывается только из redeem-promo (service role).';

-- Записывает revenuecat_request_id после успешного grant (для отладки).
create function public.confirm_promo_redemption(p_redemption_id uuid, p_revenuecat_request_id text)
returns void
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  update public.promo_redemptions
  set revenuecat_request_id = p_revenuecat_request_id
  where id = p_redemption_id;
end;
$$;

comment on function public.confirm_promo_redemption is
  'Помечает резервацию подтверждённой после успешного RevenueCat grant. Вызывается только из redeem-promo (service role).';

revoke all on function public.reserve_promo_redemption(text, uuid) from public;
revoke all on function public.release_promo_redemption(uuid) from public;
revoke all on function public.confirm_promo_redemption(uuid, text) from public;
grant execute on function public.reserve_promo_redemption(text, uuid) to service_role;
grant execute on function public.release_promo_redemption(uuid) to service_role;
grant execute on function public.confirm_promo_redemption(uuid, text) to service_role;
