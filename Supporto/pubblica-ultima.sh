#!/bin/bash
# Pubblica la release «ultima» di Lucy dal Mac dell'utente (dal 26 novembre 2026, scelta dell'utente: build, prove e
# release sul Mac, GitHub tiene solo il codice). Da lanciare sul commit di main appena unito, nella cartella del progetto:
#   bash Supporto/pubblica-ultima.sh
# Compila per Apple Silicon con le prove (costruisci-mac.sh --prove), crea Lucy.zip con dentro Lucy.app e la carica
# come release «ultima» con gh (il login di GitHub del Mac). Dentro restano l'eseguibile Prisma e l'identificativo
# local.prisma (dati e Portachiavi uguali). Lucy.ipa per iPhone e iPad la fa ancora GitHub: workflow «Build Prisma»
# lanciato a mano (si scarica dall'artefatto «Prisma-iOS» della build).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main 2>/dev/null || echo x)" ]; then
  echo "✗ La release si fa solo dal commit di main appena scaricato (git fetch origin main, poi checkout di quel commit)"
  exit 1
fi
if ! command -v gh > /dev/null; then echo "✗ Manca gh (GitHub CLI): brew install gh, poi gh auth login"; exit 1; fi

bash Supporto/costruisci-mac.sh --prove

echo "▸ Preparo Lucy.zip…"
USCITA="$(mktemp -d)"
trap 'rm -rf "$USCITA"' EXIT
ditto Prisma.app "$USCITA/Lucy.app"
ditto -c -k --keepParent "$USCITA/Lucy.app" "$USCITA/Lucy.zip"

COMMIT="$(git rev-parse --short=7 HEAD)"
NOTE="Lucy al commit $COMMIT del $(date '+%d/%m/%Y %H:%M'), compilata e provata sul Mac.

- Lucy.zip: Lucy per Mac con Apple Silicon (M1 e successivi). Il modo più semplice: bash Supporto/installa-ultima.sh; a mano si apre lo zip e si trascina Lucy.app in Applicazioni (la prima volta clic destro → Apri)."

echo "▸ Pubblico la release «ultima»…"
gh release delete ultima --yes --cleanup-tag -R denisvicenzonilavoro/Lucy 2>/dev/null || true
gh release create ultima "$USCITA/Lucy.zip" -R denisvicenzonilavoro/Lucy --target "$(git rev-parse HEAD)" \
  --title "Lucy · ultima versione" --notes "$NOTE" --latest
echo "✓ Release «ultima» pubblicata (commit $COMMIT)"
