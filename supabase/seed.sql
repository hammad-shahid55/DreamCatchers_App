begin;

delete from auth.users where email like '%@example.com';

with demo(id, username, gender, ethnicity, status, birthday, personality, education) as (
  values
    ('a0000000-0000-4000-8000-000000000001'::uuid, 'ayesha_k',     'Female', 'South Asian',             'single',            '1998-03-14', 'ENFP', 'bachelors'),
    ('a0000000-0000-4000-8000-000000000002'::uuid, 'bilal.dev',    'Male',   'Arab',                    'in_a_relationship', '1995-07-02', 'INTJ', 'masters'),
    ('a0000000-0000-4000-8000-000000000003'::uuid, 'sara_writes',  'Female', 'Hispanic/Latino',         'single',     '2000-11-21', 'INFJ', 'bachelors'),
    ('a0000000-0000-4000-8000-000000000004'::uuid, 'omar_travels', 'Male',   'Black/African-descent',   'married',           '1993-01-30', 'ESTP', 'high_school'),
    ('a0000000-0000-4000-8000-000000000005'::uuid, 'zara.art',     'Non-binary', 'Asian',               'other',   '1999-09-09', 'ISFP', 'doctorate'),
    ('a0000000-0000-4000-8000-000000000006'::uuid, 'hamza_fit',    'Male',   'White/Caucasian',         'single',            '1996-05-18', 'ESTJ', 'middle_school')
)
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', d.id, 'authenticated', 'authenticated',
  replace(d.username, '.', '_') || '@example.com',
  extensions.crypt('Demo1234', extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object(
    'username', d.username, 'gender', d.gender, 'ethnicity', d.ethnicity,
    'relationship_status', d.status, 'birthday', d.birthday,
    'personality_type', d.personality, 'education_level', d.education
  ),
  now() - interval '30 days', now(),
  '', '', '', ''
from demo d;

insert into auth.identities (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
select gen_random_uuid(), u.id, u.id::text, 'email',
       jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
       now(), now(), now()
from auth.users u
where u.email like '%@example.com';

update public.profiles p set avatar_url = a.url
from (values
  ('a0000000-0000-4000-8000-000000000001'::uuid, 'https://randomuser.me/api/portraits/women/44.jpg'),
  ('a0000000-0000-4000-8000-000000000002'::uuid, 'https://randomuser.me/api/portraits/men/32.jpg'),
  ('a0000000-0000-4000-8000-000000000003'::uuid, 'https://randomuser.me/api/portraits/women/68.jpg'),
  ('a0000000-0000-4000-8000-000000000004'::uuid, 'https://randomuser.me/api/portraits/men/75.jpg'),
  ('a0000000-0000-4000-8000-000000000005'::uuid, 'https://randomuser.me/api/portraits/women/21.jpg')
) as a(id, url)
where p.id = a.id;

insert into public.posts (id, author_id, content, media_url, media_type, created_at) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   'Sunset walks are my therapy. Who else believes the best conversations happen at golden hour? 🌅',
   'https://picsum.photos/id/1011/1080/1350', 'image', now() - interval '3 hours'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002',
   'Hot take: the best first date is a long walk + street food. No pressure, real conversation. Agree or disagree?',
   null, null, now() - interval '6 hours'),
  ('b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003',
   null,
   'https://picsum.photos/id/1025/1080/1350', 'image', now() - interval '9 hours'),
  ('b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000004',
   'Caught this little guy on my morning trip. Nature never stops surprising me 🦋',
   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', 'video', now() - interval '14 hours'),
  ('b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000005',
   'Finished my first canvas painting this year. It took 3 weeks and a lot of coffee ☕🎨',
   'https://picsum.photos/id/1040/1080/1350', 'image', now() - interval '1 day'),
  ('b0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000006',
   'Reminder: consistency beats intensity. 20 minutes a day > 3 hours once a week. Who''s training today? 💪',
   null, null, now() - interval '1 day 5 hours'),
  ('b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000003',
   'What''s a book that changed how you see relationships? Mine: "Attached". Drop yours below 📚',
   null, null, now() - interval '2 days'),
  ('b0000000-0000-4000-8000-000000000008', 'a0000000-0000-4000-8000-000000000004',
   'Mountains > beaches. Fight me. ⛰️',
   'https://picsum.photos/id/1018/1080/1350', 'image', now() - interval '3 days'),
  ('b0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000001',
   'Introvert or extrovert, what''s your personality type? I''m an ENFP and I talk to plants.',
   null, null, now() - interval '4 days'),
  ('b0000000-0000-4000-8000-000000000010', 'a0000000-0000-4000-8000-000000000002',
   null,
   'https://picsum.photos/id/1062/1080/1350', 'image', now() - interval '5 days'),
  ('b0000000-0000-4000-8000-000000000011', 'a0000000-0000-4000-8000-000000000005',
   'Rainy day playlist recommendations? Need something cozy 🌧️🎧',
   null, null, now() - interval '6 days'),
  ('b0000000-0000-4000-8000-000000000012', 'a0000000-0000-4000-8000-000000000006',
   'Meal prep Sunday done. Healthy food can taste good, I promise 🥗',
   'https://picsum.photos/id/1080/1080/1350', 'image', now() - interval '8 days');

insert into public.post_likes (post_id, user_id)
select p.post_id::uuid, u.user_id::uuid
from (values
  ('b0000000-0000-4000-8000-000000000001', 5),
  ('b0000000-0000-4000-8000-000000000002', 4),
  ('b0000000-0000-4000-8000-000000000003', 3),
  ('b0000000-0000-4000-8000-000000000004', 6),
  ('b0000000-0000-4000-8000-000000000005', 4),
  ('b0000000-0000-4000-8000-000000000006', 2),
  ('b0000000-0000-4000-8000-000000000007', 5),
  ('b0000000-0000-4000-8000-000000000008', 6),
  ('b0000000-0000-4000-8000-000000000009', 3),
  ('b0000000-0000-4000-8000-000000000010', 2),
  ('b0000000-0000-4000-8000-000000000011', 1)
) as p(post_id, n)
cross join lateral (
  select ('a0000000-0000-4000-8000-00000000000' || g)::text as user_id
  from generate_series(1, p.n) g
) u;

insert into public.comments (post_id, author_id, content, created_at) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'This view is unreal 😍', now() - interval '2 hours'),
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'Golden hour hits different', now() - interval '100 minutes'),
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000005', 'Where is this? Adding it to my list!', now() - interval '80 minutes'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', '100% agree, coffee dates feel like interviews 😂', now() - interval '5 hours'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000003', 'Street food is the ultimate vibe check', now() - interval '4 hours'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000006', 'Walks yes, but add ice cream', now() - interval '3 hours'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000005', 'Disagree, museum dates are better!', now() - interval '2 hours'),
  ('b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000003', 'So peaceful 🦋', now() - interval '12 hours'),
  ('b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', 'Nature is the best filter', now() - interval '10 hours'),
  ('b0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000003', 'The colors are amazing!', now() - interval '20 hours'),
  ('b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000001', 'The 5 Love Languages ❤️', now() - interval '40 hours'),
  ('b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000002', 'Nonviolent Communication, a game changer', now() - interval '38 hours'),
  ('b0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000005', 'Adding both to my reading list', now() - interval '30 hours'),
  ('b0000000-0000-4000-8000-000000000008', 'a0000000-0000-4000-8000-000000000006', 'Mountains all the way', now() - interval '2 days'),
  ('b0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000002', 'INTJ here, I talk to my code', now() - interval '3 days');

insert into public.post_shares (post_id, user_id)
select s.post_id::uuid, ('a0000000-0000-4000-8000-00000000000' || ((g % 6) + 1))::uuid
from (values
  ('b0000000-0000-4000-8000-000000000001', 3),
  ('b0000000-0000-4000-8000-000000000002', 4),
  ('b0000000-0000-4000-8000-000000000004', 2),
  ('b0000000-0000-4000-8000-000000000005', 1),
  ('b0000000-0000-4000-8000-000000000007', 2),
  ('b0000000-0000-4000-8000-000000000008', 1)
) as s(post_id, n)
cross join lateral generate_series(1, s.n) g;

commit;
