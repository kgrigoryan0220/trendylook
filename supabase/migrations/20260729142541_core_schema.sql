-- Trendy Look: core schema (profiles, subscriptions, checks)
-- per TECH_SPEC_v1.2.md section 6.4

create extension if not exists pgcrypto;

-- profiles (расширение auth.users; email не дублируется — берётся из auth.users)
create table public.profiles (
  id                uuid primary key references auth.users(id) on delete cascade,
  display_name      text,
  avatar_url        text,
  free_checks_used  int not null default 0,
  locale            text default 'ru',
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

-- subscriptions
create type public.plan_type as enum ('weekly', 'halfyear');
create type public.sub_status as enum ('active', 'grace', 'expired', 'cancelled');

create table public.subscriptions (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles(id) on delete cascade,
  plan              public.plan_type not null,
  status            public.sub_status not null default 'active',
  revenuecat_id     text,
  expires_at        timestamptz,
  grace_expires_at  timestamptz,
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

-- у пользователя может быть только одна активная/grace подписка одновременно
create unique index idx_one_active_subscription_per_user
  on public.subscriptions(user_id)
  where status in ('active', 'grace');

create index idx_subscriptions_user on public.subscriptions(user_id);

-- checks (история проверок)
create table public.checks (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles(id) on delete cascade,
  image_path        text not null,
  trend_score       int not null check (trend_score between 0 and 100),
  trend_label       text not null,
  ai_response       jsonb not null,
  share_image_path  text,
  deleted_at        timestamptz,
  created_at        timestamptz default now()
);

create index idx_checks_user_created on public.checks(user_id, created_at desc);
