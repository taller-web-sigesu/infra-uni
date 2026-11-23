#!/usr/bin/env bash
# Convierte las fuentes Markdown de la entrega final a PDF.
# Requisitos: pandoc y Google Chrome (o Edge) instalados.
# Uso (Git Bash, desde infra-uni/docs/entregables):  ./tools/build-pdf.sh [DOC ...]
# Sin argumentos genera los 6 documentos Markdown; PRESENTACION se genera desde su HTML.
set -euo pipefail

cd "$(dirname "$0")/.."
OUT="pdf"
mkdir -p "$OUT"

CHROME="${CHROME:-}"
for c in "/c/Program Files/Google/Chrome/Application/chrome.exe" \
         "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
         "$(command -v google-chrome || true)" "$(command -v chromium || true)"; do
  if [[ -z "$CHROME" && -n "$c" && -x "$c" ]]; then CHROME="$c"; fi
done
[[ -n "$CHROME" ]] || { echo "No se encontró Chrome/Edge" >&2; exit 1; }

DOCS=("$@")
if [[ ${#DOCS[@]} -eq 0 ]]; then
  DOCS=(VERSION RELEASE-NOTES INFORME-FINAL-FASES-I-IV MANUAL-DE-USUARIO MANUAL-TECNICO GUIA-DEL-REPOSITORIO PRESENTACION)
fi

to_win() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else echo "$1"; fi; }

for doc in "${DOCS[@]}"; do
  if [[ "$doc" == "PRESENTACION" ]]; then
    html="PRESENTACION.html"
  else
    html="$OUT/$doc.html"
    toc=()
    case "$doc" in INFORME-FINAL-FASES-I-IV|MANUAL-DE-USUARIO|MANUAL-TECNICO|GUIA-DEL-REPOSITORIO) toc=(--toc --toc-depth=2);; esac
    pandoc "$doc.md" -f gfm+yaml_metadata_block -t html5 -s --embed-resources \
      --css tools/pdf.css "${toc[@]}" \
      --metadata title="$doc" --metadata pagetitle="$doc" \
      -V lang=es -o "$html"
    # pandoc agrega el título como <h1 class="title">; el documento ya trae su propio H1.
    sed -i 's#<header id="title-block-header">.*</header>##; /<header id="title-block-header">/,/<\/header>/d' "$html"
    # Si hay portada, el índice va después de ella.
    perl -0pi -e 's#(<nav id="TOC".*?</nav>)\s*(<div class="portada">.*?</div>)#$2
$1#s' "$html"
  fi
  pdf="$OUT/$doc.pdf"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --run-all-compositor-stages-before-draw \
    --virtual-time-budget=5000 --print-to-pdf="$(to_win "$PWD/$pdf")" "file:///$(to_win "$PWD/$html" | sed 's#\\#/#g')" 2>/dev/null
  echo "OK  $pdf"
done
