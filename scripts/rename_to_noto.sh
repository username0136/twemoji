#!/usr/bin/env bash
set -euo pipefail

SVG_DIR="${1:-assets/svg}"

if [ ! -d "$SVG_DIR" ]; then
  echo "ERROR: SVG_DIR does not exist: $SVG_DIR" >&2
  exit 2
fi

shopt -s nullglob
count=0

for f in "$SVG_DIR"/*.svg; do
  name="$(basename "$f")"
  base="${name%.*}"

  # Normalize separators: convert '-' or ' ' to '_' and lower-case hex
  # Examples:
  #   1f004.svg            -> emoji_u1f004.svg
  #   1f1e6-1f1e8.svg      -> emoji_u1f1e6_1f1e8.svg
  #   U+1F600.svg          -> emoji_u1f600.svg
  norm="$(echo "$base" \
           | tr '[:upper:]' '[:lower:]' \
           | sed -E 's/^u\+?//; s/^u//; s/^0x//; s/[- ]/_/g; s/,+/_/g; s/^emoji_?u?//')"

  # ensure only hex and underscores remain (drop any garbage)
  if ! echo "$norm" | grep -Eq '^[0-9a-f_]+$'; then
    echo "SKIP (unrecognized name): $name"
    continue
  fi

  new="emoji_u${norm}.svg"
  if [ "$new" != "$name" ]; then
    if [ -e "$SVG_DIR/$new" ]; then
      echo "NOTE: target exists, skipping rename: $new"
    else
      echo "Renaming: $name -> $new"
      mv "$SVG_DIR/$name" "$SVG_DIR/$new"
      count=$((count+1))
    fi
  fi
done

echo "Renamed $count files in $SVG_DIR"
