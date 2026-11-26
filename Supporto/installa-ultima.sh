#!/bin/bash
# Installa sul Mac l'ultima Lucy (prima Prisma) per Apple Silicon fatta da GitHub (release «ultima», build verde di main).
# Dal 20 novembre 2026 (scelta dell'utente) build e prove si fanno solo su GitHub: sul Mac si installa e basta.
# Dal 24 novembre 2026 l'app si chiama Lucy: si installa come /Applications/Lucy.app e la vecchia Prisma.app si toglie.
# Dal 26 novembre 2026 la release contiene Lucy.zip con Lucy.app (prima Prisma.zip con Prisma.app, ancora accettati).
# Dentro il pacchetto restano l'eseguibile Prisma e l'identificativo local.prisma (dati e Portachiavi non cambiano).
# Uso: bash Supporto/installa-ultima.sh   (chiudi Lucy prima; i dati in ~/Library/Application Support/Prisma non si toccano)
set -euo pipefail
BASE="https://github.com/denisvicenzonilavoro/Lucy/releases/download/ultima"
if pgrep -x Prisma > /dev/null; then echo "✗ Lucy è aperta: chiudila e rilancia"; exit 1; fi
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "▸ Scarico l'ultima Lucy…"
curl -fsL -o "$TMP/ultima.zip" "$BASE/Lucy.zip" || curl -fL --progress-bar -o "$TMP/ultima.zip" "$BASE/Prisma.zip"
ditto -x -k "$TMP/ultima.zip" "$TMP"
APP="$TMP/Lucy.app"; [ -d "$APP" ] || APP="$TMP/Prisma.app"
codesign --verify --deep --strict "$APP"
COMMIT=$(/usr/libexec/PlistBuddy -c 'Print :PrismaCommit' "$APP/Contents/Info.plist" 2>/dev/null || echo "?")
rm -rf /Applications/Lucy.app
ditto "$APP" /Applications/Lucy.app
# La vecchia Prisma.app (la stessa app con il nome di prima) si toglie: nel Launchpad resta solo Lucy
rm -rf /Applications/Prisma.app
echo "✓ Installata in /Applications/Lucy.app (commit $COMMIT)"
# Vera lavora con Ministral 3 (dal 20 novembre 2026): se Ollama c'è e il modello manca, lo scarica (solo il modello, nessun dato)
if command -v ollama > /dev/null && ! ollama list 2>/dev/null | grep -q "^ministral-3:3b"; then
  echo "▸ Scarico Ministral 3 per Vera (circa 3 GB)…"
  ollama pull ministral-3:3b || echo "✗ Ministral 3 non scaricato: riprova con «ollama pull ministral-3:3b»"
fi
