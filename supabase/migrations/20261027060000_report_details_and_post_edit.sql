alter table public.post_reports
  add column if not exists details text
  check (details is null or char_length(details) <= 1000);

grant insert (post_id, reporter_id, reason, details) on public.post_reports to authenticated;

alter table public.posts add column if not exists edited_at timestamptz;

grant update (content) on public.posts to authenticated;

drop policy if exists "posts_update_own" on public.posts;
create policy "posts_update_own" on public.posts
  for update to authenticated
  using ((select auth.uid()) = author_id)
  with check ((select auth.uid()) = author_id);

create or replace function public.stamp_post_edit()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.content is distinct from old.content then
    new.edited_at := now();
  end if;
  return new;
end;
$$;

revoke execute on function public.stamp_post_edit() from public, anon, authenticated;

drop trigger if exists posts_stamp_edit on public.posts;
create trigger posts_stamp_edit
  before update on public.posts
  for each row execute function public.stamp_post_edit();
