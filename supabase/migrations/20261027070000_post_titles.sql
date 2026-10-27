alter table public.posts
  add column if not exists title text
  check (title is null or char_length(title) <= 120);

alter table public.posts drop constraint if exists posts_has_body;
alter table public.posts add constraint posts_has_body check (
  nullif(btrim(coalesce(title, '')), '') is not null
  or nullif(btrim(coalesce(content, '')), '') is not null
  or media_url is not null
);

grant insert (author_id, title, content, media_url, media_path, media_type)
  on public.posts to authenticated;
grant update (title, content) on public.posts to authenticated;

create or replace function public.stamp_post_edit()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.content is distinct from old.content
     or new.title is distinct from old.title then
    new.edited_at := now();
  end if;
  return new;
end;
$$;

drop function if exists public.get_feed(integer, timestamptz, uuid, uuid);
drop function if exists public.get_trending_posts(integer, integer, integer);
drop function if exists public.get_post(uuid);

create function public.get_feed(
  p_limit             integer     default 10,
  p_cursor_created_at timestamptz default null,
  p_cursor_id         uuid        default null,
  p_author_id         uuid        default null
)
returns table (
  id uuid, author_id uuid, author_username text, author_avatar_url text,
  title text, content text, media_url text, media_path text,
  media_type public.media_type, like_count integer, comment_count integer,
  share_count integer, created_at timestamptz, is_liked boolean,
  trending_score double precision
)
language sql stable security invoker set search_path = ''
as $$
  select
    p.id, p.author_id, pr.username, pr.avatar_url,
    p.title, p.content, p.media_url, p.media_path, p.media_type,
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

create function public.get_trending_posts(
  p_limit       integer default 10,
  p_offset      integer default 0,
  p_window_days integer default 30
)
returns table (
  id uuid, author_id uuid, author_username text, author_avatar_url text,
  title text, content text, media_url text, media_path text,
  media_type public.media_type, like_count integer, comment_count integer,
  share_count integer, created_at timestamptz, is_liked boolean,
  trending_score double precision
)
language sql stable security invoker set search_path = ''
as $$
  select
    p.id, p.author_id, pr.username, pr.avatar_url,
    p.title, p.content, p.media_url, p.media_path, p.media_type,
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

create function public.get_post(p_post_id uuid)
returns table (
  id uuid, author_id uuid, author_username text, author_avatar_url text,
  title text, content text, media_url text, media_path text,
  media_type public.media_type, like_count integer, comment_count integer,
  share_count integer, created_at timestamptz, is_liked boolean,
  trending_score double precision
)
language sql stable security invoker set search_path = ''
as $$
  select
    p.id, p.author_id, pr.username, pr.avatar_url,
    p.title, p.content, p.media_url, p.media_path, p.media_type,
    p.like_count, p.comment_count, p.share_count, p.created_at,
    exists (
      select 1 from public.post_likes l
      where l.post_id = p.id and l.user_id = (select auth.uid())
    ),
    null::double precision
  from public.posts p
  join public.profiles pr on pr.id = p.author_id
  where p.id = p_post_id;
$$;

revoke execute on function public.get_feed(integer, timestamptz, uuid, uuid) from public, anon;
revoke execute on function public.get_trending_posts(integer, integer, integer) from public, anon;
revoke execute on function public.get_post(uuid) from public, anon;
grant execute on function public.get_feed(integer, timestamptz, uuid, uuid) to authenticated;
grant execute on function public.get_trending_posts(integer, integer, integer) to authenticated;
grant execute on function public.get_post(uuid) to authenticated;

notify pgrst, 'reload schema';
