-- Entonnoir « Moi Président·e ».
-- À coller dans le SQL editor Supabase. Une visite = un chargement de page
-- (un rechargement compte pour une nouvelle visite, il n'y a rien de persistant).
--
-- Les étapes, dans l'ordre :
--   mandat_view         la page s'est ouverte sur le formulaire
--   mandat_start        première lettre tapée dans une priorité
--   mandat_complete     les cinq priorités sont remplies
--   mandat_step2        la validation est passée, l'étape 2 s'affiche
--   mandat_sent         le quinquennat est parti
-- Et à côté de l'entonnoir :
--   mandat_missing      bloqué parce qu'il manquait une priorité
--   mandat_verb_blocked bloqué par la règle du verbe (compté à chaque fois)
--   mandat_back         retour de l'étape 2 vers les priorités
--   mandat_already      visiteur déjà passé, formulaire non affiché

with etapes(rang, nom) as (
  values (1, 'mandat_view'), (2, 'mandat_start'), (3, 'mandat_complete'),
         (4, 'mandat_step2'), (5, 'mandat_sent')
),
visites as (
  select e.nom, count(distinct ev.visit) as n
  from etapes e
  left join public.events ev
    on ev.name = e.nom
   and ev.created_at > now() - interval '30 days'
  group by e.nom
)
select
  e.rang,
  e.nom as etape,
  v.n as visites,
  round(100.0 * v.n / nullif(max(v.n) over (), 0), 1) as pct_du_depart,
  round(100.0 * v.n / nullif(lag(v.n) over (order by e.rang), 0), 1) as pct_de_l_etape_avant
from etapes e
join visites v on v.nom = e.nom
order by e.rang;

-- Les blocages, qui expliquent une partie des abandons :
select name, count(*) as occurrences, count(distinct visit) as visites
from public.events
where name in ('mandat_missing', 'mandat_verb_blocked', 'mandat_back', 'mandat_already')
  and created_at > now() - interval '30 days'
group by name
order by occurrences desc;
