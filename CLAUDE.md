# Projet bootcamp

## Objectif
Projet d'apprentissage (bootcamp). Le but est de pratiquer la création d'un site
web simple, connecté à une base de données, et publié gratuitement sur internet.

L'auteur est débutant : préférer des explications simples, sans jargon, et une
seule action/question à la fois.

## Stack imposée
- **Front-end** : un seul fichier `index.html`, en HTML / CSS / JavaScript "vanilla".
  Aucun framework (pas de React, Vue, etc.), pas d'outil de build.
- **Base de données** : Supabase (accès via le client JavaScript chargé par CDN
  directement dans `index.html`).
- **Hébergement** : GitHub Pages, sur la branche principale (`main`), dossier racine.

## Structure du projet
- `index.html` — toute l'application (HTML + CSS + JS dans ce seul fichier).
- `.gitignore` — fichiers à ne jamais publier.
- `CLAUDE.md` — ce fichier (contexte du projet).

## Règles de sécurité importantes
- **Ne jamais** committer de mot de passe, de token GitHub, ni de clé privée
  dans le dépôt.
- La clé Supabase **`anon`** est publique par conception : elle peut figurer dans
  `index.html`. La sécurité des données repose sur les règles RLS (Row Level
  Security) côté Supabase, jamais sur le secret de cette clé.
- La clé Supabase **`service_role`** (secrète) ne doit JAMAIS apparaître dans ce
  dépôt ni dans `index.html`.

## Base de données — table de test
Table `events` :
- `id` — identifiant unique (généré automatiquement)
- `type` — texte (le type d'événement)
- `created_at` — date/heure de création (générée automatiquement)

## Déploiement
Le site est publié automatiquement par GitHub Pages à chaque `git push` sur la
branche `main`. L'URL publique est de la forme :
`https://<utilisateur>.github.io/bootcamp-projet/`
