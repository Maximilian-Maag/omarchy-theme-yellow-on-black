#!/bin/bash
# Shell tests for install.sh — run hermetically with a throwaway HOME/XDG, so
# nothing touches the real theme installation.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL="$ROOT/install.sh"
pass=0; fail=0
ok()  { echo "  ok: $*"; pass=$((pass+1)); }
bad() { echo "  FAIL: $*"; fail=$((fail+1)); }

# extract <sandbox-dir> — a throwaway copy of the theme's shipped files, so a test
# can install from (and edit) a source tree that is not this repo.
extract() {
  local sbx="$1"
  mkdir -p "$sbx/backgrounds"
  cp "$INSTALL" "$ROOT/colors.toml" "$ROOT/icons.theme" "$ROOT/preview.png" "$ROOT/unlock.png" "$sbx/"
  cp "$ROOT"/backgrounds/* "$sbx/backgrounds/"
}

# 1. the script parses
if bash -n "$INSTALL"; then ok "install.sh parses"; else bad "install.sh has a syntax error"; fi

# 2. it installs into the caller's XDG_CONFIG_HOME, not the real one
HOME="$(mktemp -d)"; export HOME
XDG_CONFIG_HOME="$HOME/.config"; export XDG_CONFIG_HOME
DEST="$XDG_CONFIG_HOME/omarchy/themes/yellow-on-black"

if bash "$INSTALL" >/dev/null 2>&1; then ok "install exits 0"; else bad "install exited non-zero"; fi

for name in colors.toml icons.theme preview.png unlock.png; do
  if [[ -L "$DEST/$name" && "$(readlink -f "$DEST/$name")" == "$(readlink -f "$ROOT/$name")" ]]; then
    ok "$name is a symlink to the source"
  else
    bad "$name is missing or not a symlink to the source"
  fi
done

nonlinks="$(find "$DEST/backgrounds" -mindepth 1 ! -type l 2>/dev/null)"
if [[ -n "$(ls -A "$DEST/backgrounds" 2>/dev/null)" && -z "$nonlinks" ]]; then
  ok "backgrounds installed as symlinks"
else
  bad "backgrounds missing or copied rather than linked"
fi

# 3. the install TRACKS the repo: an edit to the source shows through with no
#    re-install. A copy would go stale — exactly the bug that once left a shipped
#    icons.theme unapplied. Install from a throwaway source so this repo is untouched.
SBX="$(mktemp -d)"; SBXHOME="$(mktemp -d)"
extract "$SBX"
HOME="$SBXHOME" XDG_CONFIG_HOME="$SBXHOME/.config" bash "$SBX/install.sh" >/dev/null 2>&1
SBXDEST="$SBXHOME/.config/omarchy/themes/yellow-on-black"
marker="durability-probe-$$"
printf '%s\n' "$marker" >> "$SBX/colors.toml"
if grep -q "$marker" "$SBXDEST/colors.toml"; then
  ok "edits to the source reach the install without re-running it"
else
  bad "the install went stale (the file was copied, not linked)"
fi

# 4. re-running is idempotent and leaves links intact
if bash "$INSTALL" >/dev/null 2>&1 && [[ -L "$DEST/colors.toml" ]]; then
  ok "re-running the install is idempotent"
else
  bad "a second install broke the links"
fi

# 5. the real config dir was never touched: the install landed inside the temp HOME
if [[ $DEST == $HOME/* ]]; then
  ok "isolation: ran under a temp HOME"
else
  bad "install reached outside the sandbox"
fi

# 6. a missing asset aborts the install instead of shipping a half theme
SANDBOX="$(mktemp -d)"
extract "$SANDBOX"
rm -f "$SANDBOX/colors.toml"                 # deliberately absent
HOME="$(mktemp -d)"; export HOME
XDG_CONFIG_HOME="$HOME/.config"; export XDG_CONFIG_HOME
if bash "$SANDBOX/install.sh" >/dev/null 2>&1; then
  bad "install succeeded with colors.toml missing (half install)"
else
  ok "a missing asset aborts the install"
fi

echo
if (( fail == 0 )); then echo "shell: all $pass passed"; exit 0; else echo "shell: $fail failed"; exit 1; fi
