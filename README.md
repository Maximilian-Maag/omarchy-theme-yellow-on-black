# Yellow On Black

A black-and-gold theme for [Omarchy](https://omarchy.org/): pure-black background,
gold text, amber accents. Monochrome-amber in spirit, but the ANSI colours keep just
enough hue separation that a terminal stays readable.

Because Omarchy regenerates every themed app from `colors.toml`, the theme applies
system-wide — Hyprland window borders, the shell/bar, notifications, terminals
(alacritty, foot, ghostty, kitty), btop, chromium, neovim, VS Code, helix — with no
per-app code.

## Palette

| role | colour |
|------|--------|
| background | `#000000` |
| foreground | `#ffd700` |
| accent | `#ffcc00` |
| selection | `#33301a` |
| active border | `rgba(ffcc00ff) rgba(ffaa00ff) 45deg` |
| red / yellow / green / cyan / blue / magenta | amber–gold ramp |

## Install

```bash
omarchy theme install https://github.com/Maximilian-Maag/omarchy-theme-yellow-on-black.git
omarchy theme set "Yellow On Black"
```

Or by hand: copy this directory to `~/.config/omarchy/themes/yellow-on-black/`, then
`omarchy theme set "Yellow On Black"`.

The theme is a *user* theme (written by hand, not cloned by `omarchy theme install`),
so its `colors.toml`, background and lock-screen art are all kept as-is.

## Contents

```
colors.toml                 # the palette every templated app is rendered from
icons.theme                 # Yaru-yellow — the GNOME icon theme omarchy-theme-set-gnome reads
backgrounds/0-amber-glow.png
preview.png                 # theme-switcher thumbnail
unlock.png                  # lock screen
tests/                      # unit, regression and shell checks for the palette + installer
tools/                      # policy-as-code, test runner and mutation runner
```

## Notes

- Switching is `omarchy theme set "<name>"` (or the switcher); it is reversible.
- `icons.theme` names `Yaru-yellow`, matching the theme accent, so the GNOME icon theme follows
  the theme (every stock Omarchy theme ships one; without it `omarchy-theme-set-gnome` falls back
  to `Yaru-blue`).
- Thunderbird's chrome is themed by the separate `omarchy-thunderbird` plugin; a
  theme the plugin's renderer does not know will fall back to its base colours until
  that renderer is made palette-agnostic.

## Testing

A theme is data, so the harness pins the data contract rather than mutating code.

```bash
make test      # policy -> unit -> regression -> shell -> mutation
make check     # the same without the mutation pass
```

- **unit** — every colour slot a stock theme declares is present, every value is a
  well-formed colour, the background really is black, and the palette meets WCAG
  AA/AAA contrast ratios on it.
- **regression** — slot parity (no slot silently dropped), the Hyprland active-border
  style, and that the installer copies every shipped asset.
- **shell** + **mutation** — `install.sh` installs into a throwaway `XDG_CONFIG_HOME`,
  refuses a half-install when an asset is missing, and is the single mutation target
  (the only code a theme ships).

## Licence

MIT.
