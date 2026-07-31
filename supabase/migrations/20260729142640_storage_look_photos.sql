-- Storage bucket look-photos (private) + policies per TECH_SPEC_v1.2.md section 6.4/6.6

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('look-photos', 'look-photos', false, 10485760, array['image/jpeg','image/png','image/heic','image/heif'])
on conflict (id) do nothing;

create policy "Users upload own photos"
  on storage.objects for insert
  with check (bucket_id = 'look-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users read own photos"
  on storage.objects for select
  using (bucket_id = 'look-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users delete own photos"
  on storage.objects for delete
  using (bucket_id = 'look-photos' and (storage.foldername(name))[1] = auth.uid()::text);
