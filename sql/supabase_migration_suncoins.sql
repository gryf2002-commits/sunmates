-- ============================================================================
-- SunMates — SunCoins 🪙 : la monnaie DÉPENSABLE (P2.17), distincte de l'XP.
--   • XP ⭐ = progression PERMANENTE (niveau + classement), jamais dépensée (inchangé).
--   • SunCoins 🪙 = gagnés en parallèle, DÉPENSÉS en boutique (cosmétiques) + boosts.
-- Modèle « deux monnaies » choisi par Maxime → aucune régression de niveau.
--
-- Anti-triche : les coins ne se gagnent QUE via des événements serveur légitimes
-- (trigger sur quête accomplie + bonus quotidien borné), et se dépensent via une
-- RPC ATOMIQUE qui refuse un solde négatif. (Cohérent avec l'anti-triche « light » existant.)
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================================

-- 1) Colonnes : solde, cosmétiques possédés (achat persistant), date du dernier bonus quotidien.
alter table profiles add column if not exists coins int not null default 0;
alter table profiles add column if not exists cosmetics_owned jsonb not null default '[]'::jsonb;
alter table profiles add column if not exists last_coins_day date;

-- 2) GAIN à chaque quête accomplie : +15 🪙 (la complétion est déjà anti-triche-gated par complete_quest).
--    Trigger sur user_quests quand le statut passe à 'completed' (insert direct OU update).
create or replace function sm_grant_quest_coins()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'completed' and (tg_op = 'INSERT' or coalesce(old.status,'') <> 'completed') then
    update profiles set coins = coins + 15 where id = new.user_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_quest_coins on user_quests;
create trigger trg_quest_coins
  after insert or update on user_quests
  for each row execute function sm_grant_quest_coins();

-- 3) BONUS QUOTIDIEN : +10 🪙 une fois par jour (récompense le retour). Renvoie le montant gagné (0 si déjà pris).
create or replace function sm_claim_daily_coins()
returns table (granted int, balance int)
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); g int := 0; bal int;
begin
  if uid is null then return query select 0, 0; return; end if;
  update profiles
     set coins = coins + 10,
         last_coins_day = current_date
   where id = uid
     and (last_coins_day is null or last_coins_day < current_date);
  if found then g := 10; end if;
  select coins into bal from profiles where id = uid;
  return query select g, coalesce(bal, 0);
end;
$$;

-- 4) DÉPENSE atomique : refuse si solde insuffisant ; marque le cosmétique comme possédé (si fourni).
--    Renvoie ok + le nouveau solde. p_item = id du cosmétique acheté (ou NULL pour un boost consommable).
create or replace function sm_spend_coins(p_amount int, p_item text default null)
returns table (ok boolean, balance int, message text)
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); bal int;
begin
  if uid is null then return query select false, 0, 'Non connecté'; return; end if;
  if p_amount is null or p_amount < 0 then return query select false, 0, 'Montant invalide'; return; end if;
  select coins into bal from profiles where id = uid for update;
  if bal is null then return query select false, 0, 'Profil introuvable'; return; end if;
  if bal < p_amount then
    return query select false, bal, 'Pas assez de SunCoins'; return;
  end if;
  update profiles
     set coins = coins - p_amount,
         cosmetics_owned = case
           when p_item is null or cosmetics_owned ? p_item then cosmetics_owned
           else cosmetics_owned || to_jsonb(p_item) end
   where id = uid;
  select coins into bal from profiles where id = uid;
  return query select true, bal, 'ok';
end;
$$;

grant execute on function sm_claim_daily_coins() to authenticated;
grant execute on function sm_spend_coins(int, text) to authenticated;

-- Note : le SELECT de profiles (lecture du solde + cosmetics_owned côté app) passe par les
-- policies RLS existantes (chacun lit son profil). Les coins ne sont JAMAIS modifiés par un
-- UPDATE client direct : uniquement par le trigger et les RPC security-definer ci-dessus.
