#!/bin/bash
# Install Yellow On Black as a user Omarchy theme (no root needed).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes/yellow-on-black"

mkdir -p "$DEST/backgrounds"
cp "$SRC/colors.toml" "$DEST/"
cp "$SRC"/backgrounds/* "$DEST/backgrounds/"
cp "$SRC/preview.png" "$SRC/unlock.png" "$DEST/"

echo "Installed to $DEST"
echo "Apply with:  omarchy theme set \"Yellow On Black\""
