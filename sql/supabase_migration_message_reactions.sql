-- ============================================================
-- SunMates — Réactions aux messages (cœur ❤️ sur un message), façon Insta/iMessage
-- ============================================================
-- Double-tap sur une bulle = ❤️. Une réaction par (message, utilisateur).
-- RLS : on ne peut réagir qu'aux messages d'une conversation dont on fait partie,
-- et lire les réactions de ces mêmes messages. Idempotent (rejouable).
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================

create table if not exists message_reactions (
  message_id bigint not null references messages(id) on delete cascade,
  user_id    uuid   not null references auth.users(id) on delete cascade,
  emoji      text   not null default '❤️',
  created_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

create index if not exists message_reactions_msg_idx on message_reactions (message_id);

alter table message_reactions enable row level security;

-- On vérifie que le message appartient à une conversation où je suis impliqué.
drop policy if exists message_reactions_select on message_reactions;
create policy message_reactions_select on message_reactions
  for select using (
    exists (select 1 from messages m where m.id = message_reactions.message_id
            and (m.sender_id = auth.uid() or m.recipient_id = auth.uid()))
  );

drop policy if exists message_reactions_insert on message_reactions;
create policy message_reactions_insert on message_reactions
  for insert with check (
    user_id = auth.uid()
    and exists (select 1 from messages m where m.id = message_reactions.message_id
                and (m.sender_id = auth.uid() or m.recipient_id = auth.uid()))
  );

drop policy if exists message_reactions_delete on message_reactions;
create policy message_reactions_delete on message_reactions
  for delete using (user_id = auth.uid());

-- ============================================================
-- Fin. Une ligne par (message, utilisateur). ❤️ par défaut.
-- ============================================================
