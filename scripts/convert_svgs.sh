#!/usr/bin/env bash
set -euo pipefail


SVG_DIR="$1" # e.g. assets/svg
NOTO_PNG_DIR="$2" # e.g. noto-emoji/png


# create target sizes (128px commonly used for CBDT builds). Add other sizes if needed.
mkdir -p "$NOTO_PNG_DIR/128"


shopt -s nullglob


for svg in "$SVG_DIR"/*.svg; do
base=$(basename "$svg" .svg)
# Attempt to keep the filename as-is (naming must match codepoints for full accuracy).
out="$NOTO_PNG_DIR/128/${base}.png"
echo "Converting $svg -> $out"
convert -background none -resize 128x128 "$svg" "$out"
done


# Simple sanity check
count=$(ls -1 "$NOTO_PNG_DIR/128"/*.png 2>/dev/null | wc -l || true)
echo "Created $count PNGs in $NOTO_PNG_DIR/128"
