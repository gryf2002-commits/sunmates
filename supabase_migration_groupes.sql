-- ============================================================
-- SunMates — CONVERSATIONS DE GROUPE (#6, passe 7)
-- À exécuter dans Supabase : SQL Editor → New query → coller → Run.
-- Idempotent : tu peux le relancer sans risque.
--
-- Règles (sécurité d'abord) :
--  · seul le CRÉATEUR ajoute des membres, et uniquement des Mates
--    avec qui il a une connexion ACCEPTÉE ;
--  · seuls les MEMBRES voient le groupe et ses messages ;
--  · chacun peut QUITTER un groupe (le créateur peut retirer un membre).
-- ============================================================

create table if not exists public.group_chats (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 60),
  emoji text default '👥',
  creator uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

create table if not exists public.group_members (
  group_id bigint not null references public.group_chats(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  added_by uuid references auth.users(id),
  created_at timestamptz default now(),
  primary key (group_id, user_id)
);

create table if not exists public.group_messages (
  id bigint generated always as identity primary key,
  group_id bigint not null references public.group_chats(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 1000),
  created_at timestamptz default now()
);

alter table public.group_chats enable row level security;
alter table public.group_members enable row level security;
alter table public.group_messages enable row level security;

-- Helper SECURITY DEFINER : « suis-je membre ? » sans récursion de policy.
create or replace function public.is_group_member(gid bigint)
returns boolean language sql security definer set search_path = public as $$
  select exists (select 1 from group_members where group_id = gid and user_id = auth.uid());
$$;
revoke all on function public.is_group_member(bigint) from public;
grant execute on function public.is_group_member(bigint) to authenticated;

-- group_chats
drop policy if exists "membres voient le groupe" on public.group_chats;
create policy "membres voient le groupe" on public.group_chats
  for select using (creator = auth.uid() or public.is_group_member(id));
drop policy if exists "creer son groupe" on public.group_chats;
create policy "creer son groupe" on public.group_chats
  for insert with check (creator = auth.uid());
drop policy if exists "createur supprime son groupe" on public.group_chats;
create policy "createur supprime son groupe" on public.group_chats
  for delete using (creator = auth.uid());

-- group_members
drop policy if exists "membres voient les membres" on public.group_members;
create policy "membres voient les membres" on public.group_members
  for select using (public.is_group_member(group_id));
drop policy if exists "createur ajoute des mates connectes" on public.group_members;
create policy "createur ajoute des mates connectes" on public.group_members
  for insert with check (
    (select creator from group_chats where id = group_id) = auth.uid()
    and (
      user_id = auth.uid() -- le créateur s'ajoute lui-même
      or exists (
        select 1 from matches_connections
        where status = 'accepted'
          and ((user_a = auth.uid() and user_b = user_id)
            or (user_b = auth.uid() and user_a = user_id))
      )
    )
  );
drop policy if exists "quitter ou retirer" on public.group_members;
create policy "quitter ou retirer" on public.group_members
  for delete using (
    user_id = auth.uid() -- je quitte
    or (select creator from group_chats where id = group_id) = auth.uid() -- le créateur retire
  );

-- group_messages
drop policy if exists "membres lisent les messages" on public.group_messages;
create policy "membres lisent les messages" on public.group_messages
  for select using (public.is_group_member(group_id));
drop policy if exists "membres ecrivent" on public.group_messages;
create policy "membres ecrivent" on public.group_messages
  for insert with check (sender_id = auth.uid() and public.is_group_member(group_id));

-- Temps réel sur les messages de groupe (ignore si déjà fait)
do $$
begin
  alter publication supabase_realtime add table public.group_messages;
exception when duplicate_object then null;
end $$;
