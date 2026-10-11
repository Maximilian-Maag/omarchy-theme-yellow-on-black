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
backgrounds/0-amber-glow.png
preview.png                 # theme-switcher thumbnail
unlock.png                  # lock screen
```

## Notes

- Switching is `omarchy theme set "<name>"` (or the switcher); it is reversible.
- Thunderbird's chrome is themed by the separate `omarchy-thunderbird` plugin; a
  theme the plugin's renderer does not know will fall back to its base colours until
  that renderer is made palette-agnostic.

## Licence

MIT.
