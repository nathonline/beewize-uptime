# beewize-uptime

Sonde externe de la production Beewize. Interroge les domaines publics toutes les
5 minutes depuis un runner **GitHub** — et non depuis le runner auto-hébergé, qui
tourne sur le serveur surveillé et serait donc muet précisément pendant une panne.

Ce dépôt est public **uniquement** pour bénéficier des minutes GitHub Actions
gratuites et illimitées. Il ne contient aucun secret, aucun code applicatif et
aucune adresse IP — seulement des noms de domaine, déjà publics via les journaux
de Certificate Transparency.

## Ce qui déclenche une alerte

Un domaine est considéré en panne si la sonde n'obtient **ni 2xx, ni 3xx, ni 401**,
après trois tentatives espacées de 5 secondes :

- **Injoignable** — machine morte, DNS cassé, ou certificat TLS absent.
- **404** — le proxy répond mais ne route plus. C'est la panne du 14 juillet 2026 :
  Traefik était vivant, mais avait perdu toutes ses routes, et la production
  renvoyait 404 pendant une heure sans que personne ne soit prévenu.
- **5xx** — le service répond mais est cassé.

## En cas de panne

Une issue **🔴 Production en panne** est ouverte (ou commentée si elle existe déjà),
le job échoue — ce qui déclenche l'e-mail de GitHub — et l'issue est **close
automatiquement** dès que tous les domaines répondent de nouveau.

## Ajouter ou retirer un domaine

Une ligne par domaine dans `domains.txt`. C'est tout.
