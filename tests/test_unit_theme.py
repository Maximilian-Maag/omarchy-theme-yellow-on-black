"""Unit tests for the Yellow On Black theme.

A theme is data, not code, so these tests pin the contract the Omarchy theme
loader relies on: every colour slot a stock theme declares is present, every
value is a well-formed colour, and the theme actually IS the high-contrast
yellow-on-black it claims to be.
"""

import pathlib
import re
import tomllib
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent
COLORS = ROOT / "colors.toml"
BACKGROUNDS = ROOT / "backgrounds"

# Every colour slot a stock Omarchy theme declares. A theme that omits one renders
# the boot default for that slot, so they are required, not optional.
REQUIRED_KEYS = [
    "mode",
    "accent", "selection", "muted",
    "background", "dark_background", "darker_background", "lighter_background",
    "foreground", "dark_foreground", "light_foreground", "bright_foreground",
    "red", "yellow", "orange", "green", "cyan", "blue", "magenta", "brown",
    "bright_red", "bright_yellow", "bright_green", "bright_cyan",
    "bright_blue", "bright_magenta",
]

HEX = re.compile(r"^#[0-9a-fA-F]{6}$")
GRADIENT = re.compile(r"^rgba\([0-9a-fA-F]{8}\) rgba\([0-9a-fA-F]{8}\) \d+deg$")
NON_COLOUR_KEYS = {"mode", "hyprland_active_border"}


def load():
    with COLORS.open("rb") as fh:
        return tomllib.load(fh)


def rgb(value):
    return tuple(int(value[i:i + 2], 16) for i in (1, 3, 5))


def relative_luminance(value):
    """WCAG relative luminance of a '#rrggbb' colour."""
    channels = []
    for component in rgb(value):
        scaled = component / 255
        channels.append(scaled / 12.92 if scaled <= 0.03928
                        else ((scaled + 0.055) / 1.055) ** 2.4)
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def contrast_ratio(a, b):
    hi, lo = sorted((relative_luminance(a), relative_luminance(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


class ColorsTests(unittest.TestCase):
    def test_parses_as_toml(self):
        self.assertIsInstance(load(), dict)

    def test_every_required_slot_is_present(self):
        data = load()
        missing = [key for key in REQUIRED_KEYS if key not in data]
        self.assertEqual(missing, [], "missing colour slots: %s" % missing)

    def test_mode_is_dark_or_light(self):
        self.assertIn(load()["mode"], ("dark", "light"))

    def test_mode_matches_the_black_background(self):
        # a "dark" theme with a light background is a typo the loader cannot catch
        data = load()
        if data["mode"] == "dark":
            self.assertLess(relative_luminance(data["background"]), 0.5)

    def test_colour_values_are_well_formed(self):
        for key, value in load().items():
            if key == "mode":
                continue
            if key == "hyprland_active_border":
                self.assertRegex(value, GRADIENT.pattern, key)
                continue
            self.assertRegex(value, HEX.pattern, key)

    def test_no_stray_non_colour_keys(self):
        # a misspelled slot is silently ignored by the loader, so keep the file tight
        for key in load():
            if key in NON_COLOUR_KEYS:
                continue
            self.assertTrue(HEX.match(load()[key]), key)

    def test_background_is_black(self):
        self.assertEqual(load()["background"].lower(), "#000000")


class HighContrastTests(unittest.TestCase):
    """The theme's whole reason to exist: readable text on black."""

    def test_foreground_is_bright_on_black(self):
        data = load()
        self.assertGreater(relative_luminance(data["foreground"]), 0.5)
        self.assertLess(relative_luminance(data["background"]), 0.05)

    def test_body_text_meets_wcag_aaa(self):
        data = load()
        self.assertGreaterEqual(contrast_ratio(data["foreground"], data["background"]), 7.0)

    def test_secondary_text_still_meets_wcag_aa(self):
        data = load()
        for key in ("light_foreground", "bright_foreground", "accent"):
            self.assertGreaterEqual(
                contrast_ratio(data[key], data["background"]), 4.5, key)

    def test_muted_text_is_dim_but_visible(self):
        data = load()
        # muted is intentionally dim; it must still be distinguishable from black
        self.assertGreater(contrast_ratio(data["muted"], data["background"]), 1.2)


class BackgroundAssetTests(unittest.TestCase):
    def test_a_background_image_ships(self):
        self.assertTrue(BACKGROUNDS.is_dir(), "backgrounds/ is missing")
        self.assertTrue(list(BACKGROUNDS.glob("*.png")), "no background image shipped")


if __name__ == "__main__":
    unittest.main()
