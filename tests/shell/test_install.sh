#!/bin/bash
# Shell tests for install.sh — run hermetically with a throwaway HOME/XDG, so
# nothing touches the real theme installation.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL="$ROOT/install.sh"
pass=0; fail=0
ok()  { echo "  ok: $*"; pass=$((pass+1)); }
bad() { echo "  FAIL: $*"; fail=$((fail+1)); }

# 1. the script parses
if bash -n "$INSTALL"; then ok "install.sh parses"; else bad "install.sh has a syntax error"; fi

# 2. it installs into the caller's XDG_CONFIG_HOME, not the real one
HOME="$(mktemp -d)"; export HOME
XDG_CONFIG_HOME="$HOME/.config"; export XDG_CONFIG_HOME
DEST="$XDG_CONFIG_HOME/omarchy/themes/yellow-on-black"

if bash "$INSTALL" >/dev/null 2>&1; then
  ok "install exits 0"
else
  bad "install exited non-zero"
fi

if [[ -f "$DEST/colors.toml" ]]; then
  ok "colors.toml installed"
else
  bad "colors.toml not installed to $DEST"
fi

if [[ "$(cat "$DEST/colors.toml" 2>/dev/null)" == "$(cat "$ROOT/colors.toml")" ]]; then
  ok "installed colors.toml matches the source"
else
  bad "installed colors.toml differs from the source"
fi

if [[ -n "$(ls -A "$DEST/backgrounds" 2>/dev/null)" ]]; then
  ok "backgrounds installed"
else
  bad "backgrounds were not copied"
fi

if [[ -f "$DEST/preview.png" && -f "$DEST/unlock.png" ]]; then
  ok "preview + unlock images installed"
else
  bad "preview/unlock images missing"
fi

if [[ -f "$ROOT/icons.theme" && "$(cat "$DEST/icons.theme" 2>/dev/null)" == "$(cat "$ROOT/icons.theme")" ]]; then
  ok "icons.theme installed and matches the source"
else
  bad "icons.theme missing or differing"
fi

# 3. the real config dir was never touched: the install landed inside the temp HOME
if [[ $DEST == $HOME/* ]]; then
  ok "isolation: ran under a temp HOME"
else
  bad "install reached outside the sandbox"
fi

# 4. a missing asset aborts the install instead of shipping a half theme
SANDBOX="$(mktemp -d)"
mkdir -p "$SANDBOX/backgrounds"
cp "$ROOT/preview.png" "$ROOT/unlock.png" "$SANDBOX/"
cp "$ROOT"/backgrounds/* "$SANDBOX/backgrounds/"
# colors.toml is deliberately absent
HOME="$(mktemp -d)"; export HOME
XDG_CONFIG_HOME="$HOME/.config"; export XDG_CONFIG_HOME
if bash "$SANDBOX/install.sh" >/dev/null 2>&1; then
  bad "install succeeded with colors.toml missing (half install)"
else
  ok "a missing asset aborts the install"
fi

echo
if (( fail == 0 )); then echo "shell: all $pass passed"; exit 0; else echo "shell: $fail failed"; exit 1; fi
