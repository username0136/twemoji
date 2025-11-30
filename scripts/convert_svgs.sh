#!/usr/bin/env bash
set -euo pipefail

SVG_DIR="${1:-assets/svg}"      # input directory of *.svg
NOTO_PNG_ROOT="${2:-noto-emoji/png}"  # target root inside noto-emoji

# sizes: 128 is commonly used for CBDT builds; add other sizes if needed.
SIZES=(128)

if [ ! -d "$SVG_DIR" ]; then
  echo "ERROR: SVG_DIR does not exist: $SVG_DIR" >&2
  exit 2
fi

# create target dirs
for s in "${SIZES[@]}"; do
  mkdir -p "${NOTO_PNG_ROOT}/${s}"
done

# convert each svg; keep filename base (you may need to rename to codepoint names)
shopt -s nullglob
count=0
for svg in "$SVG_DIR"/*.svg; do
  base="$(basename "$svg" .svg)"
  for s in "${SIZES[@]}"; do
    out="${NOTO_PNG_ROOT}/${s}/${base}.png"
    echo "Converting $svg -> $out (size ${s})"
    # convert with ImageMagick: preserve alpha, rasterize to square s x s
    convert -background none -resize "${s}x${s}" "$svg" "$out"
  done
  count=$((count+1))
done

echo "Converted $count SVG files."
