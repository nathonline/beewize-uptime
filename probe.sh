#!/usr/bin/env bash
# Sonde chaque domaine depuis l'extérieur et écrit un rapport.
# Sortie 0 si tout va bien, 1 si au moins un domaine est en panne.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
down=()
report=""

while IFS= read -r domain; do
  case "$domain" in ''|\#*) continue ;; esac

  # 3 tentatives : on ne réveille pas l'astreinte pour un paquet perdu.
  code=000
  for _ in 1 2 3; do
    code=$(curl -s -o /dev/null -w '%{http_code}' -m 15 "https://${domain}" 2>/dev/null)
    case "$code" in 2??|3??|401) break ;; esac
    sleep 5
  done

  case "$code" in
    2??|3??|401)
      report+="| ✅ | \`${domain}\` | ${code} |"$'\n'
      ;;
    000)
      # Aucune réponse : machine morte, DNS cassé, ou certificat absent.
      report+="| ❌ | \`${domain}\` | injoignable |"$'\n'
      down+=("${domain} (injoignable)")
      ;;
    *)
      # Traefik répond mais ne route pas (404), ou le service renvoie une 5xx.
      # C'est exactement la panne du 2026-07-14 : proxy vivant, routes perdues.
      report+="| ❌ | \`${domain}\` | ${code} |"$'\n'
      down+=("${domain} (HTTP ${code})")
      ;;
  esac
done < "$DIR/domains.txt"

{
  echo "| État | Domaine | HTTP |"
  echo "|---|---|---|"
  printf '%s' "$report"
} > /tmp/report.md

if [ "${#down[@]}" -gt 0 ]; then
  printf '%s\n' "${down[@]}" > /tmp/down.txt
  echo "❌ ${#down[@]} domaine(s) en panne"
  cat /tmp/report.md
  exit 1
fi

: > /tmp/down.txt
echo "✅ tous les domaines répondent"
cat /tmp/report.md
