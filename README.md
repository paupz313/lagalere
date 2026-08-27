# La Galère

Défouloir citoyen pour raconter (et voter pour) les absurdités administratives
françaises. Site statique (un seul `index.html`, pas de build) qui parle
directement à une base Supabase depuis le navigateur.

## État actuel

- Projet Supabase créé et configuré (`lagalere`, région `eu-west-3`). Les clés
  sont déjà renseignées dans `index.html` (section `CONFIGURATION`) — pas de
  mode démo.
- Un compte est requis pour déposer un dossier ou voter (connexion par **lien
  magique**, sans mot de passe, via Supabase Auth). La lecture reste publique.
- Schéma appliqué : voir [`supabase/schema.sql`](supabase/schema.sql) —
  `dossiers` et `votes` sont liés à `auth.users`, RLS impose `authenticated`
  pour toute écriture.

## Configurer l'authentification (à faire une fois le site déployé)

Une fois l'URL de déploiement connue (Netlify, etc.), dans le dashboard
Supabase du projet `lagalere` :

1. `Authentication > URL Configuration`
2. `Site URL` → l'URL de production (ex. `https://lagalere.netlify.app`)
3. `Additional Redirect URLs` → ajoutez aussi cette URL (et `http://localhost:*`
   pour les tests en local)

Sans ça, le lien magique redirigera vers l'URL par défaut de Supabase plutôt
que vers le site.

## Tester en local

```bash
python3 -m http.server 8000
```

## Déploiement (Netlify)

```bash
netlify deploy          # déploiement de test (preview)
netlify deploy --prod   # mise en production
```

## Avant d'annoncer le site publiquement

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
index.html            Le site (HTML + CSS + JS, un seul fichier, pas de build)
supabase/schema.sql    Schéma de base de données + policies RLS (déjà appliqué)
.gitignore
README.md              Ce fichier
```
