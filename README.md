# La Galère

Défouloir citoyen pour raconter (et voter pour) les absurdités administratives
françaises. Site statique (un seul `index.html`, pas de build) qui parle
directement à une base Supabase depuis le navigateur.

Ce dossier est prêt à devenir un dépôt Git et à être déployé. Ce README est
écrit pour être suivi pas à pas — par vous ou par Claude Code en CLI.

## 1. Créer le projet Supabase

1. Sur [supabase.com](https://supabase.com), créez un nouveau projet (ou utilisez
   un projet existant).
2. Ouvrez l'éditeur SQL du projet (`SQL Editor` dans le menu de gauche) et
   collez tout le contenu de [`supabase/schema.sql`](supabase/schema.sql), puis
   exécutez-le. Ça crée les tables `dossiers` et `votes`, active les policies
   RLS (lecture publique, écriture publique encadrée), et la vue
   `dossier_votes`.
   - Si vous utilisez la Supabase CLI et un projet lié : `supabase db push`
     fonctionne aussi avec ce fichier.
3. Dans `Project Settings > API`, notez :
   - `Project URL`
   - la clé publique `anon` `public` (**pas** la clé `service_role`, qui ne
     doit jamais apparaître dans du code côté navigateur)

## 2. Brancher le site sur Supabase

Ouvrez `index.html`, cherchez la section `CONFIGURATION` tout en haut du
`<script>` (vers la fin du fichier) et remplacez :

```js
var SUPABASE_URL = "REPLACE_WITH_YOUR_SUPABASE_URL";
var SUPABASE_ANON_KEY = "REPLACE_WITH_YOUR_SUPABASE_ANON_KEY";
```

par vos propres valeurs. La clé `anon` est faite pour être publique et visible
côté client — la vraie protection vient des règles RLS définies dans
`schema.sql`, pas du secret de cette clé.

Tant que ces deux valeurs ne sont pas renseignées, le site tourne en **mode
démo local** : il affiche 8 témoignages fictifs (écrits pendant le
prototypage) uniquement dans votre navigateur, sans rien partager. Dès que
Supabase est configuré, ce mode démo disparaît et le site charge les vrais
dossiers depuis la base.

Vous pouvez tester en local en ouvrant simplement `index.html` dans un
navigateur, ou avec un petit serveur local :

```bash
npx serve .
# ou
python3 -m http.server 8000
```

## 3. Retirer le contenu de démo avant le vrai lancement

Les 8 témoignages dans `supabase/schema.sql` (section commentée en bas) et
dans le tableau `SEED` d'`index.html` sont **inventés**, écrits comme
exemples. Ne les insérez jamais dans la vraie base publique — ça se
présenterait comme de vrais témoignages de citoyens alors que ce n'en est
pas. Une fois Supabase configuré, ils ne s'affichent de toute façon plus.

## 4. Créer le dépôt GitHub

```bash
cd lagalere-site
git init
git add .
git commit -m "Première version : La Galère"
gh repo create lagalere --public --source=. --push
# (ou --private si vous préférez ne pas le rendre public tout de suite)
```

`gh` doit être authentifié (`gh auth status` pour vérifier, `gh auth login`
sinon).

## 5. Déployer (Vercel, ou tout hébergeur de site statique)

Le site n'a aucune étape de build : Vercel, Netlify, Cloudflare Pages ou
GitHub Pages fonctionnent tous sans configuration particulière (dossier de
sortie = racine du dépôt).

Avec Vercel (le plus simple si vous avez déjà GitHub) :

1. Sur [vercel.com](https://vercel.com), "Add New… > Project", importez le
   dépôt `lagalere` créé à l'étape précédente.
2. Aucune commande de build à renseigner — Vercel détecte un site statique.
3. Déployez. Vous obtenez une URL `*.vercel.app` immédiatement, et un domaine
   personnalisé peut être ajouté ensuite dans les réglages du projet.

Avec la CLI Vercel, si elle est installée et authentifiée :

```bash
npx vercel --prod
```

## 6. Avant d'annoncer le site publiquement

Voir le doc `checklist-mise-en-ligne` du projet Claude ("lagalere") pour la
liste complète (mentions légales, RGPD, modération, anti-bot renforcé...).
En résumé, ce qui manque encore après le déploiement technique :

- Mentions légales (obligation LCEN)
- Politique de confidentialité (RGPD — pas de déclaration CNIL nécessaire,
  mais informer les visiteurs et sécuriser les données)
- Un vrai système de modération / signalement de contenu
- Une protection anti-bot plus robuste que le honeypot actuel si le site
  prend du volume (le honeypot + délai minimum dans `index.html` freinent
  les bots basiques, pas plus)

## Structure du projet

```
index.html          Le site (HTML + CSS + JS, un seul fichier, pas de build)
supabase/schema.sql  Schéma de base de données + policies RLS à exécuter dans Supabase
.gitignore
README.md            Ce fichier
```
