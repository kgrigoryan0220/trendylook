-- Row Level Security per TECH_SPEC_v1.2.md section 6.4

alter table public.profiles enable row level security;
create policy "Users read own profile" on public.profiles
  for select using (auth.uid() = id);
create policy "Users update own profile" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

alter table public.checks enable row level security;
create policy "Users read own checks" on public.checks
  for select using (auth.uid() = user_id and deleted_at is null);
create policy "Users soft-delete own checks" on public.checks
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.subscriptions enable row level security;
create policy "Users read own subscription" on public.subscriptions
  for select using (auth.uid() = user_id);
