# Quelle Galère !

A satirical civic website where French users file, read and upvote their most absurd administrative experiences, through a fake "public counter" complete with a Windows 98 ticket machine.

Independent project, not affiliated with any administration.

## What it does

- **File a case** at the virtual counter, browse others and vote for the worst
- **Passwordless sign-in** by magic link; reading stays public, writing requires an account
- **Built-in moderation**: automatic filter that blocks personal details (names of officials, phone numbers) before publication, plus anti-bot protection
- **GDPR basics**: legal notice, privacy page, data deletion on request

## Stack

Static HTML/CSS/JS, no build step · Supabase (Postgres, Auth, Row-Level Security) · Netlify

Security model: the browser only holds Supabase's public key; all write rules are enforced in the database with row-level security (see `supabase/schema.sql`).

## Run locally

```bash
python3 -m http.server 8000
```

## Deploy

```bash
netlify deploy --prod
```

After deploying, set the production URL in Supabase under Authentication > URL Configuration so magic links redirect to the site.
