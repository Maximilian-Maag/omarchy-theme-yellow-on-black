#!/bin/bash
# Install Yellow On Black as a user Omarchy theme (no root needed).
set -euo pipefail

HERE="$(dirname "${BASH_SOURCE[0]}")"
SRC="$(cd "$HERE" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes/yellow-on-black"

# Refuse to half-install. A file this theme ships but fails to copy renders the
# boot fallback for whatever is missing — far harder to notice than a failure.
for name in colors.toml preview.png unlock.png; do
  if [[ ! -f "$SRC/$name" ]]; then
    echo "yellow-on-black: missing $name in $SRC" >&2
    exit 1
  fi
done

mkdir -p "$DEST/backgrounds"
cp "$SRC/colors.toml" "$DEST/"
cp "$SRC"/backgrounds/* "$DEST/backgrounds/"
cp "$SRC/preview.png" "$SRC/unlock.png" "$DEST/"

echo "Installed to $DEST"
echo "Apply with:  omarchy theme set \"Yellow On Black\""
