alter table public.comments
  add column if not exists parent_id uuid references public.comments (id) on delete cascade,
  add column if not exists reply_count integer not null default 0 check (reply_count >= 0);

create index if not exists comments_parent_created_idx
  on public.comments (parent_id, created_at, id)
  where parent_id is not null;

create index if not exists comments_post_toplevel_idx
  on public.comments (post_id, created_at desc, id desc)
  where parent_id is null;

create or replace function public.validate_comment_reply()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_parent public.comments%rowtype;
begin
  if new.parent_id is null then
    return new;
  end if;
  select * into v_parent from public.comments where id = new.parent_id;
  if not found then
    raise exception 'Parent comment not found' using errcode = '23503';
  end if;
  if v_parent.post_id <> new.post_id then
    raise exception 'Reply must belong to the same post' using errcode = '23514';
  end if;
  if v_parent.parent_id is not null then
    raise exception 'Replies can only answer top-level comments' using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function public.validate_comment_reply() from public, anon, authenticated;

drop trigger if exists comments_validate_reply on public.comments;
create trigger comments_validate_reply
  before insert on public.comments
  for each row execute function public.validate_comment_reply();

create or replace function public.sync_comment_reply_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' and new.parent_id is not null then
    update public.comments set reply_count = reply_count + 1 where id = new.parent_id;
  elsif tg_op = 'DELETE' and old.parent_id is not null then
    update public.comments set reply_count = greatest(reply_count - 1, 0) where id = old.parent_id;
  end if;
  return null;
end;
$$;

revoke execute on function public.sync_comment_reply_count() from public, anon, authenticated;

drop trigger if exists comments_sync_reply_count on public.comments;
create trigger comments_sync_reply_count
  after insert or delete on public.comments
  for each row execute function public.sync_comment_reply_count();

grant insert (post_id, author_id, content, parent_id) on public.comments to authenticated;

drop function if exists public.get_post_comments(uuid, integer, timestamptz, uuid);

create function public.get_post_comments(
  p_post_id           uuid,
  p_limit             integer     default 20,
  p_cursor_created_at timestamptz default null,
  p_cursor_id         uuid        default null
)
returns table (
  id                uuid,
  post_id           uuid,
  parent_id         uuid,
  author_id         uuid,
  author_username   text,
  author_avatar_url text,
  content           text,
  reply_count       integer,
  created_at        timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.id, c.post_id, c.parent_id, c.author_id, pr.username, pr.avatar_url,
         c.content, c.reply_count, c.created_at
  from public.comments c
  join public.profiles pr on pr.id = c.author_id
  where c.post_id = p_post_id
    and c.parent_id is null
    and (
      p_cursor_created_at is null
      or (c.created_at, c.id) < (p_cursor_created_at, p_cursor_id)
    )
  order by c.created_at desc, c.id desc
  limit least(greatest(coalesce(p_limit, 20), 1), 50);
$$;

create or replace function public.get_comment_replies(
  p_parent_id         uuid,
  p_limit             integer     default 20,
  p_cursor_created_at timestamptz default null,
  p_cursor_id         uuid        default null
)
returns table (
  id                uuid,
  post_id           uuid,
  parent_id         uuid,
  author_id         uuid,
  author_username   text,
  author_avatar_url text,
  content           text,
  reply_count       integer,
  created_at        timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.id, c.post_id, c.parent_id, c.author_id, pr.username, pr.avatar_url,
         c.content, c.reply_count, c.created_at
  from public.comments c
  join public.profiles pr on pr.id = c.author_id
  where c.parent_id = p_parent_id
    and (
      p_cursor_created_at is null
      or (c.created_at, c.id) > (p_cursor_created_at, p_cursor_id)
    )
  order by c.created_at asc, c.id asc
  limit least(greatest(coalesce(p_limit, 20), 1), 50);
$$;

create or replace function public.get_post(p_post_id uuid)
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
  where p.id = p_post_id;
$$;

revoke execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) from public, anon;
revoke execute on function public.get_comment_replies(uuid, integer, timestamptz, uuid) from public, anon;
revoke execute on function public.get_post(uuid) from public, anon;
grant execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.get_comment_replies(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.get_post(uuid) to authenticated;

notify pgrst, 'reload schema';
