#!/bin/bash
# Install Yellow On Black as a user Omarchy theme (no root needed).
#
# The install is a set of SYMLINKS into this working tree, not a copy. Omarchy
# applies a theme from ~/.config/omarchy/themes/<slug>/, so a copy silently goes
# stale the moment this repo changes: a file added here (icons.theme, say) never
# reaches the desktop until install.sh is re-run. Symlinks make `omarchy theme set
# "Yellow On Black"` always stage the current repo — omarchy-theme-set copies the
# staged theme with `cp -r`, which preserves links, so the staged theme reads here.
set -euo pipefail

HERE="$(dirname "${BASH_SOURCE[0]}")"
SRC="$(cd "$HERE" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes/yellow-on-black"

# Refuse to half-install. A file this theme ships but cannot link renders the
# boot fallback for whatever is missing — far harder to notice than a failure.
for name in colors.toml icons.theme preview.png unlock.png; do
  if [[ ! -f "$SRC/$name" ]]; then
    echo "yellow-on-black: missing $name in $SRC" >&2
    exit 1
  fi
done

# Rebuild the managed directory so a file dropped from the repo cannot linger.
rm -rf "$DEST"
mkdir -p "$DEST/backgrounds"

for name in colors.toml icons.theme preview.png unlock.png; do
  ln -s "$SRC/$name" "$DEST/$name"
done
for background in "$SRC"/backgrounds/*; do
  ln -s "$background" "$DEST/backgrounds/$(basename "$background")"
done

echo "Installed to $DEST (symlinked to $SRC)"
echo "Apply with:  omarchy theme set \"Yellow On Black\""
