# Web Coran Forum

Application de suivi d'apprentissage/récitation du Coran — refonte en Angular +
Supabase (serverless) d'une ancienne application PHP (2005).

## Stack

- **Frontend** : Angular 22 (standalone, routing), hébergé gratuitement sur
  Cloudflare Pages / Netlify / Firebase Hosting.
- **Backend** : [Supabase](https://supabase.com) (PostgreSQL + Auth + Row Level
  Security), plan gratuit.

## Démarrage (développement local)

1. Créer un projet gratuit sur [supabase.com](https://supabase.com).
2. Dans l'onglet **SQL Editor** du projet Supabase, exécuter dans l'ordre les
   fichiers de `supabase/migrations/` :
   - `0001_schema.sql` (tables, sécurité RLS)
   - `0002_seed_referentiel.sql` (114 sourates, 60 hizbs, 480 tomons)
3. Copier l'URL du projet et la clé **anon** (Project Settings → API) dans
   `public/config.json` :
   ```json
   {
     "supabaseUrl": "https://xxxx.supabase.co",
     "supabaseAnonKey": "xxxxx"
   }
   ```
4. Installer les dépendances et lancer le serveur de dev :
   ```bash
   npm install
   npm start
   ```

## Build et déploiement

```bash
npm run build
```

Le résultat est généré dans `dist/web-coran-forum/browser`. Ce dossier peut
être déployé directement sur Cloudflare Pages, Netlify ou Firebase Hosting
(hébergement statique gratuit, HTTPS inclus).

Important : avant de déployer, mettre à jour `public/config.json` avec les
vraies valeurs du projet Supabase de production (la clé *anon* est conçue
pour être publique côté client — la sécurité réelle est assurée par les
règles Row Level Security côté base de données, pas par le secret de cette
clé).

## Sécurité

- Authentification géré par Supabase Auth (hash des mots de passe, sessions
  JWT, confirmation email).
- Row Level Security activée sur toutes les tables : chaque requête SQL est
  filtrée par PostgreSQL selon l'utilisateur connecté (pas de logique de
  sécurité uniquement côté client).
- HTTPS fourni nativement par Supabase et par l'hébergeur statique.
- Les règles RLS actuelles sont un point de départ (lecture/écriture de ses
  propres données, visibilité du groupe pour le professeur, accès complet
  pour le rôle `admin`) — à affiner à mesure que les règles de gestion sont
  précisées.

## Modèle de données

- `profiles` — profil utilisateur (lié à `auth.users`), rôle (`admin`,
  `professeur`, `membre`).
- `groupes` — groupes de récitation, professeur optionnel.
- `groupe_membres` — appartenance many-to-many membre ↔ groupe.
- `sourates` (114), `hizbs` (60), `tomons` (480 = 60 × 8) — référentiel
  coranique fixe.
- `tomon_sourate` — correspondance tomon → sourate(s), avec une fraction de
  0.5 quand un tomon est partagé entre deux sourates. **À peupler avec les
  données exactes de l'ancienne application** (ce découpage en 1/8 de hizb
  n'est pas un découpage standard documenté publiquement).
- `recitations` — saisie d'une récitation par un membre : type `ancienne`
  (date facultative) ou `nouvelle` (date obligatoire), sur un tomon donné.

## Règles de gestion déjà implémentées

1. Connexion via authentification (Supabase Auth).
2. Création de groupes de récitation.
3. Un groupe peut avoir un professeur, ou aucun.
4. Un membre peut appartenir à plusieurs groupes simultanément.
5. Un membre saisit une récitation : ancienne (sans date) ou nouvelle (date
   obligatoire) — contrainte vérifiée en base de données.
6. Unité de base : le tomon (1/8 de hizb).
7. Un tomon partagé entre deux sourates compte pour une demi-part dans
   chacune (table `tomon_sourate`).
8. 114 sourates, 60 hizbs au total.

D'autres règles de gestion seront ajoutées au fur et à mesure.
