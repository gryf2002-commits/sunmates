-- ============================================================
-- SunMates — Session 35 : FEED communautaire (type Insta)
-- ============================================================
-- Un vrai fil où les membres PUBLIENT (quête accomplie, « posé à tel endroit »,
-- mot du jour…) + likes. Lecture par tous (sauf comptes bannis), écriture = la sienne.
-- Rejouable. À exécuter dans le SQL Editor de Supabase.
-- ============================================================

create table if not exists feed_posts (
  id         bigint generated always as identity primary key,
  user_id    uuid references auth.users(id) on delete cascade,
  kind       text default 'post',         -- post | spot | quest
  body       text,
  city       text,
  created_at timestamptz default now()
);
alter table feed_posts enable row level security;
drop policy if exists "feed read"   on feed_posts;
create policy "feed read"   on feed_posts for select to authenticated using (true);
drop policy if exists "feed insert" on feed_posts;
create policy "feed insert" on feed_posts for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "feed delete" on feed_posts;
create policy "feed delete" on feed_posts for delete to authenticated using (auth.uid() = user_id);

create table if not exists feed_likes (
  post_id bigint references feed_posts(id) on delete cascade,
  user_id uuid   references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (post_id, user_id)
);
alter table feed_likes enable row level security;
drop policy if exists "likes read"   on feed_likes;
create policy "likes read"   on feed_likes for select to authenticated using (true);
drop policy if exists "likes insert" on feed_likes;
create policy "likes insert" on feed_likes for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "likes delete" on feed_likes;
create policy "likes delete" on feed_likes for delete to authenticated using (auth.uid() = user_id);

-- Liste du fil : posts + auteur + nb de likes + « est-ce que je l'ai liké » (comptes bannis exclus)
create or replace function feed_list(p_limit int default 40)
returns table (id bigint, user_id uuid, username text, avatar_url text, is_verified boolean,
               kind text, body text, city text, created_at timestamptz, likes bigint, liked boolean)
language sql security definer set search_path = public as $$
  select f.id, f.user_id, p.username, p.avatar_url, p.is_verified, f.kind, f.body, f.city, f.created_at,
    (select count(*) from feed_likes l where l.post_id = f.id)::bigint as likes,
    exists (select 1 from feed_likes l where l.post_id = f.id and l.user_id = auth.uid()) as liked
  from feed_posts f join profiles p on p.id = f.user_id
  where coalesce(p.banned, false) = false
  order by f.created_at desc
  limit p_limit;
$$;
grant execute on function feed_list(int) to authenticated;

-- Like / unlike (toggle) → renvoie l'état + le compteur
create or replace function toggle_feed_like(p_post bigint)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_liked boolean; v_n bigint;
begin
  if v_uid is null then return jsonb_build_object('ok', false); end if;
  if exists (select 1 from feed_likes where post_id = p_post and user_id = v_uid) then
    delete from feed_likes where post_id = p_post and user_id = v_uid; v_liked := false;
  else
    insert into feed_likes (post_id, user_id) values (p_post, v_uid) on conflict do nothing; v_liked := true;
  end if;
  select count(*) into v_n from feed_likes where post_id = p_post;
  return jsonb_build_object('ok', true, 'liked', v_liked, 'likes', v_n);
end; $$;
grant execute on function toggle_feed_like(bigint) to authenticated;

-- ============================================================
-- Fin. Le fil d'accueil devient un vrai feed communautaire (posts + likes).
-- ============================================================
