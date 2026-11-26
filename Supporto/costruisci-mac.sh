#!/bin/bash
# Costruisce Lucy (pacchetto tecnico Prisma.app) sul Mac, solo per Apple Silicon. Dal 25 novembre 2026 è la via delle
# prove sul Mac dell'utente, e dal 26 novembre 2026 l'unica (CLAUDE.md › Regole di sviluppo): GitHub tiene solo il codice.
# Si compila file per file (-no-whole-module-optimization) sugli 8 core: la prima volta circa 16 minuti, poi solo i file
# cambiati, e se il comando viene fermato la volta dopo riparte da dove era arrivato.
# --prove fa anche i controlli che stanno nel workflow di GitHub (Supporto/controlli-locali.sh).
# Uso, dalla cartella del progetto:
#   bash Supporto/costruisci-mac.sh            → compila e crea Prisma.app
#   bash Supporto/costruisci-mac.sh --prove    → in più esegue le prove principali
#   bash Supporto/costruisci-mac.sh --installa → in più la installa come /Applications/Lucy.app (via la vecchia Prisma.app)
#   bash Supporto/costruisci-mac.sh --demo     → in più crea «Lucy Demo.app» (con --installa anche in Applicazioni)
set -euo pipefail
cd "$(dirname "$0")/.."

PROVE=0; INSTALLA=0; DEMO=0
for a in "$@"; do
  case "$a" in
    --prove) PROVE=1 ;;
    --installa) INSTALLA=1 ;;
    --demo) DEMO=1 ;;
    *) echo "Opzione sconosciuta: $a"; exit 2 ;;
  esac
done

echo "▸ Compilo (release, arm64, file per file)…"
OPZIONI=(-c release --arch arm64 -Xswiftc -no-whole-module-optimization)
swift build "${OPZIONI[@]}"
BIN_DIR="$(swift build "${OPZIONI[@]}" --show-bin-path)"

APP=Prisma.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Prisma" "$APP/Contents/MacOS/Prisma"
cp Info.plist "$APP/Contents/Info.plist"
COMMIT="$(git rev-parse --short=7 HEAD 2>/dev/null || echo locale)"
/usr/libexec/PlistBuddy -c "Add :PrismaCommit string $COMMIT" "$APP/Contents/Info.plist"

if [ -f Design/Icone/AppIcon.png ]; then
  echo "▸ Icona…"
  ICONSET="$(mktemp -d)/AppIcon.iconset"
  mkdir -p "$ICONSET"
  for s in 16 32 128 256 512; do
    sips -z $s $s Design/Icone/AppIcon.png --out "$ICONSET/icon_${s}x${s}.png" > /dev/null
    d=$((s * 2))
    sips -z $d $d Design/Icone/AppIcon.png --out "$ICONSET/icon_${s}x${s}@2x.png" > /dev/null
  done
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
  /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP/Contents/Info.plist"
fi

# Bundle delle risorse SwiftPM in Contents/Resources (non nella radice del .app)
for b in "$BIN_DIR"/*.bundle; do
  [ -e "$b" ] || continue
  ditto "$b" "$APP/Contents/Resources/$(basename "$b")"
done
# Istruzioni, schemi, esempi e addestramento di Vera
for cartella in Istruzioni Schemi Esempi Addestramento Valutazione; do
  if [ -d "Vera/$cartella" ]; then
    mkdir -p "$APP/Contents/Resources/Vera"
    ditto "Vera/$cartella" "$APP/Contents/Resources/Vera/$cartella"
  fi
done
codesign --force --deep --sign - "$APP"
echo "✓ Creata $(pwd)/$APP"

if [ "$PROVE" = 1 ]; then
  echo "▸ Prove…"
  "$APP/Contents/MacOS/Prisma" --verifica-risorse
  "$APP/Contents/MacOS/Prisma" --prova-backup
  "$APP/Contents/MacOS/Prisma" --prova-calcoli
  "$APP/Contents/MacOS/Prisma" --prova-vera
  "$APP/Contents/MacOS/Prisma" --prova-ovunque
  "$APP/Contents/MacOS/Prisma" --prova-film
  bash Supporto/controlli-locali.sh
  echo "✓ Prove superate"
fi

if [ "$INSTALLA" = 1 ]; then
  # Lucy (dal 24 novembre 2026): il pacchetto si chiama Lucy.app in Applicazioni; la vecchia Prisma.app si toglie
  rm -rf /Applications/Lucy.app
  ditto "$APP" /Applications/Lucy.app
  rm -rf /Applications/Prisma.app
  echo "✓ Installata in /Applications/Lucy.app (commit $COMMIT)"
fi

# Lucy Demo (25 novembre 2026): lo stesso eseguibile con un Info.plist diverso (EdizioneLucy): identificativo
# local.prisma.demo, nome «Lucy Demo», chiave LucyDemo. Dati, backup e Portachiavi suoi: nasce già piena di clienti di
# prova e non tocca mai l'archivio vero. Con --installa va in /Applications/Lucy Demo.app.
if [ "$DEMO" = 1 ]; then
  DEMO_APP="Lucy Demo.app"
  rm -rf "$DEMO_APP"
  ditto "$APP" "$DEMO_APP"
  PL="$DEMO_APP/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier local.prisma.demo" "$PL"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName Lucy Demo" "$PL"
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Lucy Demo" "$PL"
  /usr/libexec/PlistBuddy -c "Add :LucyDemo bool true" "$PL"
  codesign --force --deep --sign - "$DEMO_APP"
  echo "✓ Creata $(pwd)/$DEMO_APP"
  if [ "$INSTALLA" = 1 ]; then
    rm -rf "/Applications/$DEMO_APP"
    ditto "$DEMO_APP" "/Applications/$DEMO_APP"
    echo "✓ Installata in /Applications/$DEMO_APP (commit $COMMIT)"
  fi
fi
