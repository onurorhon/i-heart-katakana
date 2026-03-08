#!/usr/bin/env python3
"""
Convert Maniackers .suit (suitcase) fonts to .otf

Uses FontForge to open legacy Mac suitcase files and export as OpenType.
Output goes to the assets fonts directory for processing by remap_maniackers.py.

After conversion, applies font-specific cmap fixes (e.g. Futaba-KT has an
unmapped hyphen glyph that needs to be added to the cmap for ホ to work).

Requirements:
    brew install fontforge
    pip install fonttools

Usage:
    fontforge -script scripts/convert_suitcases.py
"""

import fontforge
import os

FONTS_DIR = os.path.expanduser('~/Library/Fonts')
OUTPUT_DIR = os.path.expanduser('~/_git/i-heart-katakana-assets/fonts')

suitcases = [
    'Coppepan-ChocoKt.suit',
    'Futaba-KT.suit',
    'Hachipochi-EightKt.suit',
    'Nihonbashi-KT.suit',
]

for name in suitcases:
    src = os.path.join(FONTS_DIR, name)
    out = os.path.join(OUTPUT_DIR, name.replace('.suit', '.otf'))

    if not os.path.exists(src):
        print(f"  {name}: NOT FOUND")
        continue

    print(f"  {name} -> {os.path.basename(out)}")
    font = fontforge.open(src)
    font.generate(out)
    font.close()

# Post-conversion cmap fixes
# FontForge maps the hyphen glyph to U+00AD (soft hyphen) instead of U+002D
# (hyphen-minus). The glyph exists but is unmapped at 0x2D, which breaks the
# Maniackers remapping (0x2D -> ホ). Fix by adding the cmap entry.
from fontTools.ttLib import TTFont

for name in suitcases:
    otf_path = os.path.join(OUTPUT_DIR, name.replace('.suit', '.otf'))
    if not os.path.exists(otf_path):
        continue
    font = TTFont(otf_path)
    if 'hyphen' in font.getGlyphOrder():
        cmap = font.getBestCmap()
        if 0x2D not in cmap:
            for table in font['cmap'].tables:
                table.cmap[0x2D] = 'hyphen'
            font.save(otf_path)
            print(f"  {os.path.basename(otf_path)}: fixed unmapped hyphen glyph")
    font.close()

print(f"\nExported to: {OUTPUT_DIR}")
