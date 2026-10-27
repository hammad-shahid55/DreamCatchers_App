create table if not exists public.post_reports (
  id          bigint generated always as identity primary key,
  post_id     uuid not null references public.posts (id) on delete cascade,
  reporter_id uuid not null default auth.uid()
              references public.profiles (id) on delete cascade,
  reason      text not null check (char_length(btrim(reason)) between 1 and 60),
  created_at  timestamptz not null default now(),
  constraint post_reports_unique unique (post_id, reporter_id)
);

create index if not exists post_reports_post_idx on public.post_reports (post_id);
create index if not exists post_reports_reporter_idx on public.post_reports (reporter_id);

alter table public.post_reports enable row level security;
revoke all on public.post_reports from anon, authenticated;
grant select on public.post_reports to authenticated;
grant insert (post_id, reporter_id, reason) on public.post_reports to authenticated;

drop policy if exists "post_reports_select_own" on public.post_reports;
create policy "post_reports_select_own" on public.post_reports
  for select to authenticated
  using ((select auth.uid()) = reporter_id);

drop policy if exists "post_reports_insert_own" on public.post_reports;
create policy "post_reports_insert_own" on public.post_reports
  for insert to authenticated
  with check (
    (select auth.uid()) = reporter_id
    and not exists (
      select 1 from public.posts p
      where p.id = post_id and p.author_id = (select auth.uid())
    )
  );
