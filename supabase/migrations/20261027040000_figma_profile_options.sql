alter table public.profiles alter column gender type text using gender::text;

update public.profiles set gender = case gender
  when 'male' then 'Male'
  when 'female' then 'Female'
  when 'non_binary' then 'Non-binary'
  when 'other' then 'Others'
  when 'prefer_not_to_say' then 'Others'
  else gender
end;

drop type if exists public.gender_type;

alter table public.profiles drop constraint if exists profiles_gender_length;
alter table public.profiles
  add constraint profiles_gender_length check (gender is null or char_length(gender) <= 40);

alter type public.relationship_status_type add value if not exists 'other';
alter type public.education_level_type add value if not exists 'middle_school' before 'high_school';

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
    nullif(btrim(meta ->> 'gender'), ''),
    nullif(meta ->> 'relationship_status', '')::public.relationship_status_type,
    nullif(meta ->> 'birthday', '')::date,
    nullif(meta ->> 'personality_type', '')::public.personality_type,
    nullif(meta ->> 'education_level', '')::public.education_level_type
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;
