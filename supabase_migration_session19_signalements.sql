-- ============================================================
-- SunMates — Session 19 : SIGNALEMENTS antispam + AUTO-BLOCAGE
-- Un seul signalement par compte et par personne ; la personne signalée est
-- automatiquement bloquée pour l'auteur, tant que la modération n'a pas traité.
-- À lancer dans le SQL Editor de Supabase. Rejouable (idempotent).
-- ============================================================

-- Colonnes de suivi (au cas où absentes)
alter table reports add column if not exists handled boolean default false;
alter table reports add column if not exists status  text default 'pending';  -- pending | reviewed | dismissed

-- Antispam : un seul signalement par couple (auteur, personne signalée)
create unique index if not exists reports_unique_pair on reports (reporter, reported_user);

-- RPC : signale + auto-bloque, en une seule opération sécurisée.
create or replace function report_user(p_reported uuid, p_reason text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_exists boolean;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'message', 'Non connecté.');
  end if;
  if p_reported is null or p_reported = v_uid then
    return jsonb_build_object('ok', false, 'message', 'Signalement invalide.');
  end if;
  select exists(select 1 from reports where reporter = v_uid and reported_user = p_reported) into v_exists;
  if v_exists then
    -- Déjà signalé : on garantit juste que le blocage protecteur est en place.
    insert into blocks (blocker, blocked) values (v_uid, p_reported) on conflict do nothing;
    return jsonb_build_object('ok', true, 'already', true,
      'message', 'Tu as déjà signalé ce voyageur. Notre équipe examine la demande.');
  end if;
  insert into reports (reporter, reported_user, reason, status)
  values (v_uid, p_reported, p_reason, 'pending');
  -- Auto-blocage protecteur (l'auteur ne croise plus la personne en attendant la modération).
  insert into blocks (blocker, blocked) values (v_uid, p_reported) on conflict do nothing;
  return jsonb_build_object('ok', true, 'already', false,
    'message', 'Signalement envoyé. Le voyageur est automatiquement bloqué pour toi.');
end;
$$;
grant execute on function report_user(uuid, text) to authenticated;

-- Lecture de MES signalements (avec le pseudo de la personne) pour suivre leur statut.
create or replace function my_reports()
returns table (reported_user uuid, username text, reason text, status text, handled boolean, created_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select r.reported_user, p.username, r.reason, r.status, r.handled, r.created_at
  from reports r left join profiles p on p.id = r.reported_user
  where r.reporter = auth.uid()
  order by r.created_at desc;
$$;
grant execute on function my_reports() to authenticated;

-- Fin session 19.
