-- ============================================================
--  SunMates — session 41 : CONTENU « CANAPÉ » (rituel quotidien sans IRL)
--  Déjà appliqué en LIVE le 21/06/2026 (3 migrations MCP :
--    daily_questions_system, travel_quizzes_system, mate_of_day_wishlist_words).
--  Ce fichier documente la structure pour le repo. Rejouable (idempotent).
--  Le SEED complet (36 questions, 18 quiz, 25 mots) est dans ces migrations.
-- ============================================================

-- ---------- Question du jour ----------
create table if not exists public.daily_questions (
  id bigint generated always as identity primary key,
  question text not null, emoji text default '🌍',
  active boolean not null default true, created_at timestamptz default now()
);
create table if not exists public.daily_question_answers (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id bigint not null references public.daily_questions(id) on delete cascade,
  answer text not null check (char_length(answer) between 1 and 500),
  created_at timestamptz default now(), unique (user_id, question_id)
);

-- ---------- Quiz culture & sécurité ----------
create table if not exists public.travel_quizzes (
  id bigint generated always as identity primary key,
  category text not null check (category in ('culture','securite')),
  question text not null, choices jsonb not null, answer_index integer not null,
  explanation text, emoji text default '🧠', active boolean not null default true
);
create table if not exists public.user_quiz_log (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  quiz_id bigint not null references public.travel_quizzes(id) on delete cascade,
  correct boolean, created_at timestamptz default now(), unique (user_id, quiz_id)
);

-- ---------- Wishlist (destinations rêvées) ----------
create table if not exists public.wishlist (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  destination text not null check (char_length(destination) between 1 and 120),
  country text check (char_length(coalesce(country,'')) <= 80),
  note text check (char_length(coalesce(note,'')) <= 280),
  created_at timestamptz default now()
);

-- ---------- Mot du jour (multi-langues) ----------
create table if not exists public.daily_words (
  id bigint generated always as identity primary key,
  lang text not null, word text not null, translation text not null,
  example text, emoji text default '💬', active boolean not null default true
);

-- ---------- RLS (toutes les tables) ----------
-- contenus (questions/quiz/mots) : lecture par 'authenticated'.
-- données user (answers/quiz_log/wishlist) : strictement owner (auth.uid()=user_id).
-- Détail des policies + index : voir les migrations live.
alter table public.daily_questions       enable row level security;
alter table public.daily_question_answers enable row level security;
alter table public.travel_quizzes         enable row level security;
alter table public.user_quiz_log          enable row level security;
alter table public.wishlist               enable row level security;
alter table public.daily_words            enable row level security;

-- ---------- RPC (SECURITY DEFINER, search_path=public, durcies authenticated) ----------
--   dq_today()                         -> question du jour + ma réponse + total
--   dq_answer(p_question_id, p_answer) -> upsert ma réponse
--   dq_feed(p_question_id, p_limit)    -> réponses commu (bloqués exclus)
--   quiz_today()                       -> quiz du jour (SANS la réponse) + statut
--   quiz_answer(p_quiz_id, p_choice)   -> vérif serveur -> {correct, answer_index, explanation}
--   mate_of_the_day()                  -> profil compatible du jour (mondial, async)
--   word_today(p_lang)                 -> mot du jour pour une langue
--   sm_shared_count(a,b)               -> helper intersection (interne)
-- Définitions complètes dans l'historique des migrations Supabase.

-- ✅ Terminé. Câblage front : docs/BRIEF_CODE_CONTENU_CANAPE.md
