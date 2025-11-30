#!/usr/bin/env bash
set -euo pipefail

SVG_DIR="${1:-assets/svg}"
NOTO_PNG_ROOT="${2:-noto-emoji/png}"

# sizes: keep 72 + 128 (noto often uses 72)
SIZES=(72 128)

if [ ! -d "$SVG_DIR" ]; then
  echo "ERROR: SVG_DIR does not exist: $SVG_DIR" >&2
  exit 2
fi

for s in "${SIZES[@]}"; do
  mkdir -p "${NOTO_PNG_ROOT}/${s}"
done

shopt -s nullglob
count=0

# Accept original names like 1f004.svg or already normalized emoji_uXXXX.svg
for svg in "$SVG_DIR"/*.svg; do
  name="$(basename "$svg")"
  base="${name%.*}"

  # If already in form emoji_u..., use as-is; otherwise normalize like rename script
  if echo "$base" | grep -qE '^emoji_u[0-9a-f_]+$'; then
    target_base="$base"
  else
    norm="$(echo "$base" | tr '[:upper:]' '[:lower:]' | sed -E 's/^u\+?//; s/^u//; s/^0x//; s/[- ]/_/g; s/,+/_/g; s/^emoji_?u?//')"
    # if invalid, skip
    if ! echo "$norm" | grep -Eq '^[0-9a-f_]+$'; then
      echo "SKIP (bad name): $name"
      continue
    fi
    target_base="emoji_u${norm}"
  fi

  for s in "${SIZES[@]}"; do
    out="${NOTO_PNG_ROOT}/${s}/${target_base}.png"
    echo "Converting: $svg -> $out (size ${s})"
    convert -background none -resize "${s}x${s}" "$svg" "$out"
  done
  count=$((count+1))
done

echo "Converted $count SVG files into ${NOTO_PNG_ROOT} (sizes: ${SIZES[*]})"
