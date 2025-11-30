#!/usr/bin/env bash
set -euo pipefail

SVG_DIR="${1:-assets/svg}"
NOTO_PNG_ROOT="${2:-noto-emoji/png}"

# ONLY 128px requested
SIZE=128

if [ ! -d "$SVG_DIR" ]; then
  echo "ERROR: SVG_DIR does not exist: $SVG_DIR" >&2
  exit 2
fi

mkdir -p "${NOTO_PNG_ROOT}/${SIZE}"

shopt -s nullglob
count=0

for svg in "$SVG_DIR"/*.svg; do
  base="$(basename "$svg" .svg)"
  out="${NOTO_PNG_ROOT}/${SIZE}/${base}.png"
  echo "Converting $svg -> $out"
  convert -background none -resize "${SIZE}x${SIZE}" "$svg" "$out"
  count=$((count + 1))
done

echo "Converted $count SVG files into ${NOTO_PNG_ROOT}/${SIZE}"
