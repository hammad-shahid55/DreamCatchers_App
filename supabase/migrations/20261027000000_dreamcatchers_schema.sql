do $$ begin
  create type public.gender_type as enum
    ('male', 'female', 'non_binary', 'other', 'prefer_not_to_say');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.relationship_status_type as enum
    ('single', 'in_a_relationship', 'engaged', 'married',
     'separated', 'divorced', 'widowed', 'its_complicated');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.education_level_type as enum
    ('high_school', 'diploma', 'associate', 'bachelors',
     'masters', 'doctorate', 'other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.personality_type as enum (
    'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
    'ISTP', 'ISFP', 'INFP', 'INTP',
    'ESTP', 'ESFP', 'ENFP', 'ENTP',
    'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.media_type as enum ('image', 'video');
exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id                  uuid primary key references auth.users (id) on delete cascade,
  username            text not null,
  email               text not null,
  ethnicity           text,
  gender              public.gender_type,
  relationship_status public.relationship_status_type,
  birthday            date,
  personality_type    public.personality_type,
  education_level     public.education_level_type,
  avatar_url          text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint profiles_username_format check (username ~ '^[A-Za-z0-9_.]{3,30}$'),
  constraint profiles_ethnicity_length check (ethnicity is null or char_length(ethnicity) <= 60)
);

create unique index if not exists profiles_username_lower_key
  on public.profiles (lower(username));

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (
    id, username, email, ethnicity, gender, relationship_status,
    birthday, personality_type, education_level
  )
  values (
    new.id,
    coalesce(
      nullif(btrim(meta ->> 'username'), ''),
      'user_' || replace(left(new.id::text, 8), '-', '')
    ),
    coalesce(new.email, ''),
    nullif(btrim(meta ->> 'ethnicity'), ''),
    nullif(meta ->> 'gender', '')::public.gender_type,
    nullif(meta ->> 'relationship_status', '')::public.relationship_status_type,
    nullif(meta ->> 'birthday', '')::date,
    nullif(meta ->> 'personality_type', '')::public.personality_type,
    nullif(meta ->> 'education_level', '')::public.education_level_type
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = coalesce(new.email, '') where id = new.id;
  return new;
end;
$$;

revoke execute on function public.handle_user_email_change() from public, anon, authenticated;

drop trigger if exists on_auth_user_email_updated on auth.users;
create trigger on_auth_user_email_updated
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email)
  execute function public.handle_user_email_change();

create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1 from public.profiles
    where lower(username) = lower(btrim(p_username))
  );
$$;

revoke execute on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to anon, authenticated;

create table if not exists public.posts (
  id            uuid primary key default gen_random_uuid(),
  author_id     uuid not null default auth.uid()
                references public.profiles (id) on delete cascade,
  content       text,
  media_url     text,
  media_path    text,
  media_type    public.media_type,
  like_count    integer not null default 0 check (like_count >= 0),
  comment_count integer not null default 0 check (comment_count >= 0),
  share_count   integer not null default 0 check (share_count >= 0),
  created_at    timestamptz not null default now(),
  constraint posts_content_length check (content is null or char_length(content) <= 2000),
  constraint posts_has_body check (
    nullif(btrim(coalesce(content, '')), '') is not null or media_url is not null
  ),
  constraint posts_media_consistency check ((media_url is null) = (media_type is null))
);

create index if not exists posts_created_at_id_idx
  on public.posts (created_at desc, id desc);

create index if not exists posts_author_created_idx
  on public.posts (author_id, created_at desc, id desc);

create table if not exists public.post_likes (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null default auth.uid()
             references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index if not exists post_likes_user_idx on public.post_likes (user_id);

create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts (id) on delete cascade,
  author_id  uuid not null default auth.uid()
             references public.profiles (id) on delete cascade,
  content    text not null,
  created_at timestamptz not null default now(),
  constraint comments_content_length check (char_length(btrim(content)) between 1 and 1000)
);
create index if not exists comments_post_created_idx
  on public.comments (post_id, created_at desc, id desc);
create index if not exists comments_author_idx on public.comments (author_id);

create table if not exists public.post_shares (
  id         bigint generated always as identity primary key,
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null default auth.uid()
             references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists post_shares_post_idx on public.post_shares (post_id);
create index if not exists post_shares_user_idx on public.post_shares (user_id);

create or replace function public.sync_post_counters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post_id uuid;
  v_delta   integer;
begin
  if tg_op = 'INSERT' then
    v_post_id := new.post_id;
    v_delta := 1;
  else
    v_post_id := old.post_id;
    v_delta := -1;
  end if;

  if tg_table_name = 'post_likes' then
    update public.posts
       set like_count = greatest(like_count + v_delta, 0)
     where id = v_post_id;
  elsif tg_table_name = 'comments' then
    update public.posts
       set comment_count = greatest(comment_count + v_delta, 0)
     where id = v_post_id;
  elsif tg_table_name = 'post_shares' then
    update public.posts
       set share_count = greatest(share_count + v_delta, 0)
     where id = v_post_id;
  end if;

  return null;
end;
$$;

revoke execute on function public.sync_post_counters() from public, anon, authenticated;

drop trigger if exists post_likes_sync_counter on public.post_likes;
create trigger post_likes_sync_counter
  after insert or delete on public.post_likes
  for each row execute function public.sync_post_counters();

drop trigger if exists comments_sync_counter on public.comments;
create trigger comments_sync_counter
  after insert or delete on public.comments
  for each row execute function public.sync_post_counters();

drop trigger if exists post_shares_sync_counter on public.post_shares;
create trigger post_shares_sync_counter
  after insert or delete on public.post_shares
  for each row execute function public.sync_post_counters();

alter table public.profiles    enable row level security;
alter table public.posts       enable row level security;
alter table public.post_likes  enable row level security;
alter table public.comments    enable row level security;
alter table public.post_shares enable row level security;

revoke all on public.profiles, public.posts, public.post_likes,
              public.comments, public.post_shares
  from anon, authenticated;

grant select (id, username, ethnicity, gender, relationship_status, birthday,
              personality_type, education_level, avatar_url, created_at, updated_at)
  on public.profiles to authenticated;
grant update (ethnicity, gender, relationship_status, birthday,
              personality_type, education_level, avatar_url)
  on public.profiles to authenticated;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated" on public.profiles
  for select to authenticated using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

grant select on public.posts to authenticated;
grant insert (author_id, content, media_url, media_path, media_type)
  on public.posts to authenticated;
grant delete on public.posts to authenticated;

drop policy if exists "posts_select_authenticated" on public.posts;
create policy "posts_select_authenticated" on public.posts
  for select to authenticated using (true);

drop policy if exists "posts_insert_own" on public.posts;
create policy "posts_insert_own" on public.posts
  for insert to authenticated
  with check ((select auth.uid()) = author_id);

drop policy if exists "posts_delete_own" on public.posts;
create policy "posts_delete_own" on public.posts
  for delete to authenticated
  using ((select auth.uid()) = author_id);

grant select, delete on public.post_likes to authenticated;
grant insert (post_id, user_id) on public.post_likes to authenticated;

drop policy if exists "post_likes_select_own" on public.post_likes;
create policy "post_likes_select_own" on public.post_likes
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "post_likes_insert_own" on public.post_likes;
create policy "post_likes_insert_own" on public.post_likes
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "post_likes_delete_own" on public.post_likes;
create policy "post_likes_delete_own" on public.post_likes
  for delete to authenticated using ((select auth.uid()) = user_id);

grant select, delete on public.comments to authenticated;
grant insert (post_id, author_id, content) on public.comments to authenticated;

drop policy if exists "comments_select_authenticated" on public.comments;
create policy "comments_select_authenticated" on public.comments
  for select to authenticated using (true);

drop policy if exists "comments_insert_own" on public.comments;
create policy "comments_insert_own" on public.comments
  for insert to authenticated with check ((select auth.uid()) = author_id);

drop policy if exists "comments_delete_own" on public.comments;
create policy "comments_delete_own" on public.comments
  for delete to authenticated using ((select auth.uid()) = author_id);

grant select on public.post_shares to authenticated;
grant insert (post_id, user_id) on public.post_shares to authenticated;

drop policy if exists "post_shares_select_own" on public.post_shares;
create policy "post_shares_select_own" on public.post_shares
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "post_shares_insert_own" on public.post_shares;
create policy "post_shares_insert_own" on public.post_shares
  for insert to authenticated with check ((select auth.uid()) = user_id);

create or replace function public.get_feed(
  p_limit             integer     default 10,
  p_cursor_created_at timestamptz default null,
  p_cursor_id         uuid        default null,
  p_author_id         uuid        default null
)
returns table (
  id                uuid,
  author_id         uuid,
  author_username   text,
  author_avatar_url text,
  content           text,
  media_url         text,
  media_path        text,
  media_type        public.media_type,
  like_count        integer,
  comment_count     integer,
  share_count       integer,
  created_at        timestamptz,
  is_liked          boolean,
  trending_score    double precision
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    p.id, p.author_id, pr.username, pr.avatar_url,
    p.content, p.media_url, p.media_path, p.media_type,
    p.like_count, p.comment_count, p.share_count, p.created_at,
    exists (
      select 1 from public.post_likes l
      where l.post_id = p.id and l.user_id = (select auth.uid())
    ),
    null::double precision
  from public.posts p
  join public.profiles pr on pr.id = p.author_id
  where (p_author_id is null or p.author_id = p_author_id)
    and (
      p_cursor_created_at is null
      or (p.created_at, p.id) < (p_cursor_created_at, p_cursor_id)
    )
  order by p.created_at desc, p.id desc
  limit least(greatest(coalesce(p_limit, 10), 1), 50);
$$;

create or replace function public.get_trending_posts(
  p_limit       integer default 10,
  p_offset      integer default 0,
  p_window_days integer default 30
)
returns table (
  id                uuid,
  author_id         uuid,
  author_username   text,
  author_avatar_url text,
  content           text,
  media_url         text,
  media_path        text,
  media_type        public.media_type,
  like_count        integer,
  comment_count     integer,
  share_count       integer,
  created_at        timestamptz,
  is_liked          boolean,
  trending_score    double precision
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    p.id, p.author_id, pr.username, pr.avatar_url,
    p.content, p.media_url, p.media_path, p.media_type,
    p.like_count, p.comment_count, p.share_count, p.created_at,
    exists (
      select 1 from public.post_likes l
      where l.post_id = p.id and l.user_id = (select auth.uid())
    ),
    s.score
  from public.posts p
  join public.profiles pr on pr.id = p.author_id
  cross join lateral (
    select (
      (p.like_count * 1.0 + p.comment_count * 2.0 + p.share_count * 3.0)
      / power(extract(epoch from (now() - p.created_at)) / 3600.0 + 2.0, 1.5)
    )::double precision as score
  ) s
  where p.created_at >= now() - make_interval(days => greatest(coalesce(p_window_days, 30), 1))
    and (p.like_count + p.comment_count + p.share_count) > 0
  order by s.score desc, p.created_at desc, p.id desc
  limit least(greatest(coalesce(p_limit, 10), 1), 50)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

create or replace function public.get_post_comments(
  p_post_id           uuid,
  p_limit             integer     default 20,
  p_cursor_created_at timestamptz default null,
  p_cursor_id         uuid        default null
)
returns table (
  id                uuid,
  post_id           uuid,
  author_id         uuid,
  author_username   text,
  author_avatar_url text,
  content           text,
  created_at        timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.id, c.post_id, c.author_id, pr.username, pr.avatar_url, c.content, c.created_at
  from public.comments c
  join public.profiles pr on pr.id = c.author_id
  where c.post_id = p_post_id
    and (
      p_cursor_created_at is null
      or (c.created_at, c.id) < (p_cursor_created_at, p_cursor_id)
    )
  order by c.created_at desc, c.id desc
  limit least(greatest(coalesce(p_limit, 20), 1), 50);
$$;

revoke execute on function public.get_feed(integer, timestamptz, uuid, uuid) from public, anon;
revoke execute on function public.get_trending_posts(integer, integer, integer) from public, anon;
revoke execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) from public, anon;
grant execute on function public.get_feed(integer, timestamptz, uuid, uuid) to authenticated;
grant execute on function public.get_trending_posts(integer, integer, integer) to authenticated;
grant execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) to authenticated;

notify pgrst, 'reload schema';

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'post-media',
  'post-media',
  true,
  52428800,
  array[
    'image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic',
    'video/mp4', 'video/quicktime', 'video/webm', 'video/3gpp'
  ]
)
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "post_media_read" on storage.objects;
create policy "post_media_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'post-media');

drop policy if exists "post_media_insert_own_folder" on storage.objects;
create policy "post_media_insert_own_folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'post-media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "post_media_delete_own_folder" on storage.objects;
create policy "post_media_delete_own_folder" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'post-media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
