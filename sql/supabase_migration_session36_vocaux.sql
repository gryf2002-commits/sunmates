-- ============================================================
-- SunMates — Session 36 : NOTES VOCALES (messages audio)
-- ============================================================
-- Ajoute l'audio aux messages + un bucket de stockage privé.
-- ⚠️ FREE TIER Supabase : Storage 1 Go, egress 5 Go/mois. On garde les vocaux LÉGERS :
--   • durée plafonnée à 30 s côté app
--   • encodage Opus basse débit (~16–24 kbps) → ~40–70 Ko par note
--   → ~15 000 notes possibles dans 1 Go. Largement suffisant au lancement (à surveiller ensuite).
-- Rejouable. À exécuter dans le SQL Editor de Supabase.
-- ============================================================

alter table messages add column if not exists audio_path text;

-- Bucket privé pour les notes vocales (chemin non devinable = uid/timestamp.webm)
insert into storage.buckets (id, name, public) values ('voicenotes', 'voicenotes', false)
on conflict (id) do nothing;

-- Upload : chacun dépose dans SON dossier (uid/…)
drop policy if exists "voice upload" on storage.objects;
create policy "voice upload" on storage.objects for insert to authenticated
  with check (bucket_id = 'voicenotes' and (storage.foldername(name))[1] = auth.uid()::text);

-- Lecture : tout membre connecté (le chemin aléatoire fait office de secret ; lecture via URL signée)
drop policy if exists "voice read" on storage.objects;
create policy "voice read" on storage.objects for select to authenticated
  using (bucket_id = 'voicenotes');

-- Suppression : seulement ses propres fichiers
drop policy if exists "voice delete" on storage.objects;
create policy "voice delete" on storage.objects for delete to authenticated
  using (bucket_id = 'voicenotes' and (storage.foldername(name))[1] = auth.uid()::text);

-- ============================================================
-- Fin. Les messages peuvent porter une note vocale (audio_path). Lecture via URL signée.
-- ============================================================
