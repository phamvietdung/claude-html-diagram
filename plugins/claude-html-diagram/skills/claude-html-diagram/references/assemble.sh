#!/bin/sh
# Assemble the final self-contained diagram: inline cf-style.css, diagram.js and
# logo.svg (all live next to this script) into an authored file.
#   usage: sh assemble.sh <authored.html> <out.html>
# Prints four verify counts; they must read 1 / >=1 / >=1 / 0.

IN=$1
OUT=$2
REF=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -z "$IN" ] || [ -z "$OUT" ]; then
  echo "usage: sh assemble.sh <authored.html> <out.html>" >&2; exit 2
fi
if [ ! -f "$IN" ]; then
  echo "ERROR: input not found: $IN" >&2; exit 2
fi
if [ "$IN" = "$OUT" ]; then
  echo "ERROR: output must differ from input (the redirect would truncate it)" >&2; exit 2
fi
if ! grep -q 'rel="stylesheet"' "$IN" || ! grep -q 'src="diagram.js"' "$IN"; then
  echo "ERROR: no <link rel=\"stylesheet\"> / <script src=\"diagram.js\"> markers in $IN." >&2
  echo "This is probably an already-assembled file. Run this on the AUTHORED file." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")" || exit 2

awk -v css="$REF/cf-style.css" -v js="$REF/diagram.js" -v logo="$REF/logo.svg" '
  /rel="stylesheet"/          { print "<style>"; while ((getline y < css) > 0) print y; close(css); print "</style>"; next }
  /<script src="diagram.js">/ { print "<script>"; while ((getline z < js) > 0) print z; close(js); print "</script>"; next }
  /src="logo.svg"/            { while ((getline g < logo) > 0) print g; close(logo); next }
  { print }
' "$IN" > "$OUT" || exit 2

echo "verify (want 1 / >=1 / >=1 / 0):"
grep -c '</style>' "$OUT"
grep -c 'setFlow' "$OUT"
grep -c 'class="brand-logo"' "$OUT"
grep -c 'rel="stylesheet"\|src="diagram.js"\|src="logo.svg"' "$OUT"
exit 0
