"""Regression tests for the Yellow On Black theme.

Each test names an invariant whose violation ships a visibly broken theme: a
colour slot the loader silently falls back for, a Hyprland style the desktop
needs, and a shipped asset the installer forgets to copy.
"""

import pathlib
import tomllib
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent
INSTALL = ROOT / "install.sh"
COLORS = ROOT / "colors.toml"

# The slots a stock Omarchy theme declares. Dropping one makes the loader fall
# back to the boot default for that slot — the classic silent theme regression.
STOCK_SLOTS = [
    "mode", "accent", "selection", "muted",
    "background", "dark_background", "darker_background", "lighter_background",
    "foreground", "dark_foreground", "light_foreground", "bright_foreground",
    "red", "yellow", "orange", "green", "cyan", "blue", "magenta", "brown",
    "bright_red", "bright_yellow", "bright_green", "bright_cyan",
    "bright_blue", "bright_magenta",
]


def colours():
    with COLORS.open("rb") as fh:
        return tomllib.load(fh)


class SlotParityTests(unittest.TestCase):
    def test_no_stock_slot_was_dropped(self):
        data = colours()
        missing = [slot for slot in STOCK_SLOTS if slot not in data]
        self.assertEqual(missing, [], "the theme dropped slot(s): %s" % missing)

    def test_icons_theme_names_a_matching_yaru_variant(self):
        # Every stock theme ships icons.theme and omarchy-theme-set-gnome reads it,
        # falling back to a hardcoded Yaru-blue when absent. The value must be a real
        # installed Yaru variant, not an invented name.
        value = (ROOT / "icons.theme").read_text().strip()
        self.assertTrue(value.startswith("Yaru"), "icons.theme must name a Yaru variant")
        self.assertTrue(pathlib.Path("/usr/share/icons", value).is_dir(),
                        "%s is not an installed icon theme" % value)

    def test_the_active_border_is_styled(self):
        # a Hyprland theme that leaves this out shows the default focused-window
        # frame, which is how an off-brand border ships unnoticed
        self.assertIn("hyprland_active_border", colours())


class InstallerCoverageTests(unittest.TestCase):
    def test_the_installer_copies_every_shipped_asset(self):
        # a shipped-but-not-installed file renders the fallback, so catch the case
        # where an asset is added to the repo but install.sh never copies it
        script = INSTALL.read_text()
        for asset in ("colors.toml", "icons.theme", "backgrounds", "preview.png", "unlock.png"):
            self.assertIn(asset, script, "%s is shipped but the installer ignores it" % asset)

    def test_every_promised_asset_exists(self):
        for asset in ("colors.toml", "icons.theme", "install.sh", "preview.png", "unlock.png"):
            self.assertTrue((ROOT / asset).is_file(), asset)


if __name__ == "__main__":
    unittest.main()
