delete from public.comments where parent_id is not null;

drop trigger if exists comments_validate_reply on public.comments;
drop trigger if exists comments_sync_reply_count on public.comments;
drop function if exists public.validate_comment_reply();
drop function if exists public.sync_comment_reply_count();
drop function if exists public.get_comment_replies(uuid, integer, timestamptz, uuid);

drop index if exists public.comments_parent_created_idx;
drop index if exists public.comments_post_toplevel_idx;

drop function if exists public.get_post_comments(uuid, integer, timestamptz, uuid);

alter table public.comments
  drop column if exists parent_id,
  drop column if exists reply_count;

grant insert (post_id, author_id, content) on public.comments to authenticated;

create function public.get_post_comments(
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

revoke execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) from public, anon;
grant execute on function public.get_post_comments(uuid, integer, timestamptz, uuid) to authenticated;

notify pgrst, 'reload schema';
