#!/usr/bin/env python3
"""
Remap & Subset Maniackers 1-byte Katakana Fonts

Maniackers Design katakana fonts (KtA/KT variants) store katakana glyphs
at ASCII codepoints based on the JIS kana keyboard layout. This script:
  1. Remaps glyphs to correct Unicode katakana codepoints (U+30A0-30FF)
  2. Subsets to katakana-only glyphs

This is a separate pipeline from subset_fonts.py, which handles standard
Unicode fonts. Do not mix the two.

Mapping source: martijnkoch.com/katakanaconverter.php (Set 1)
Note: "the character layout varies slightly between fonts" per Maniackers README.
If a font doesn't match, the script reports unmapped glyphs for manual review.

Requirements:
    pip install fonttools brotli

Usage:
    python scripts/remap_maniackers.py AstroZ-KtA.otf [ShotaroV-KT.otf ...]
"""

import sys
import tempfile
from pathlib import Path

try:
    from fontTools.ttLib import TTFont
    from fontTools.subset import main as pyftsubset_main
except ImportError:
    print("Error: fonttools not installed. Run: pip install fonttools brotli")
    sys.exit(1)


# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
ASSETS_FONTS_DIR = PROJECT_ROOT.parent / 'i-heart-katakana-assets' / 'fonts'
OUTPUT_DIR = PROJECT_ROOT / 'IHeartKatakana' / 'Resources' / 'Fonts'

# Katakana Unicode block (same range as subset_fonts.py)
UNICODE_RANGE = 'U+30A0-30FF'

# Maniackers Set 1 mapping: ASCII char -> katakana Unicode codepoint
# Source: martijnkoch.com/katakanaconverter.php, confirmed bidirectionally
ASCII_TO_KATAKANA = {
    '!': 'ヲ', '"': 'ブ', '#': 'ァ', '$': 'ゥ', '%': 'ェ',
    '&': 'ォ', "'": 'ャ', '(': 'ュ', ')': 'ョ', '*': 'ゲ',
    ',': 'ネ', '-': 'ホ', '.': 'ル', '/': 'メ', '0': 'ワ',
    '1': 'ヌ', '2': 'フ', '3': 'ア', '4': 'ウ', '5': 'エ',
    '6': 'オ', '7': 'ヤ', '8': 'ユ', '9': 'ヨ', ':': 'ケ',
    ';': 'レ', '=': 'ボ',
    'A': 'ヂ', 'B': 'ゴ', 'C': 'ゾ', 'D': 'ジ', 'E': 'ィ',
    'F': 'バ', 'G': 'ギ', 'H': 'グ', 'I': 'パ', 'J': 'ピ',
    'K': 'プ', 'L': 'ペ', 'M': 'ポ', 'N': 'ヰ', 'O': 'ヱ', 'P': 'ゼ',
    'Q': 'ダ', 'R': 'ズ', 'S': 'ド', 'T': 'ガ', 'V': 'ビ',
    'W': 'デ', 'X': 'ザ', 'Y': 'ヅ', 'Z': 'ッ',
    '\\': 'ー', ']': 'ム', '^': 'ヘ', '_': 'ロ', '`': 'ヴ',
    'a': 'チ', 'b': 'コ', 'c': 'ソ', 'd': 'シ', 'e': 'イ',
    'f': 'ハ', 'g': 'キ', 'h': 'ク', 'i': 'ニ', 'j': 'マ',
    'k': 'ノ', 'l': 'リ', 'm': 'モ', 'n': 'ミ', 'o': 'ラ',
    'p': 'セ', 'q': 'タ', 'r': 'ス', 's': 'ト', 't': 'カ',
    'u': 'ナ', 'v': 'ヒ', 'w': 'テ', 'x': 'サ', 'y': 'ン',
    'z': 'ツ', '|': 'ヮ', '~': 'ベ',
}


def format_size(size_bytes):
    """Format file size for display."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    else:
        return f"{size_bytes / (1024 * 1024):.1f} MB"


def remap_font(input_path, output_path):
    """Remap a Maniackers 1-byte font to Unicode katakana codepoints."""
    font = TTFont(str(input_path))
    cmap = font.getBestCmap()

    if not cmap:
        print(f"    ERROR: No cmap table found")
        return False

    # Build the new mapping: katakana Unicode codepoint -> glyph name
    new_entries = {}
    mapped_count = 0
    missing_count = 0

    for ascii_char, katakana_char in ASCII_TO_KATAKANA.items():
        ascii_cp = ord(ascii_char)
        katakana_cp = ord(katakana_char)

        if ascii_cp in cmap:
            glyph_name = cmap[ascii_cp]
            new_entries[katakana_cp] = glyph_name
            mapped_count += 1
        else:
            missing_count += 1
            print(f"    WARNING: No glyph at ASCII '{ascii_char}' (U+{ascii_cp:04X}) for {katakana_char}")

    if mapped_count == 0:
        print(f"    ERROR: No mappings found — font may not use the Maniackers layout")
        return False

    # Update Unicode-capable cmap subtables
    for table in font['cmap'].tables:
        # Skip platform 1 (Mac Roman) — only supports 0-255
        if table.platformID == 1:
            continue

        # Clear old ASCII mappings that we're remapping
        for ascii_char in ASCII_TO_KATAKANA:
            ascii_cp = ord(ascii_char)
            if ascii_cp in table.cmap:
                del table.cmap[ascii_cp]

        # Add katakana Unicode mappings
        table.cmap.update(new_entries)

    # Remove platform 1 table (incompatible with katakana codepoints)
    font['cmap'].tables = [t for t in font['cmap'].tables if t.platformID != 1]

    font.save(str(output_path))

    print(f"    Remapped: {mapped_count} glyphs")
    if missing_count:
        print(f"    Missing: {missing_count} expected glyphs")

    return True


def subset_font(input_path, output_path):
    """Subset a font to katakana-only glyphs."""
    args = [
        str(input_path),
        f'--unicodes={UNICODE_RANGE}',
        f'--output-file={output_path}',
        '--layout-features=*',
        '--no-hinting',
        '--desubroutinize',
    ]
    pyftsubset_main(args)


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/remap_maniackers.py FontName.otf [FontName2.otf ...]")
        sys.exit(1)

    # Validate source directory
    if not ASSETS_FONTS_DIR.exists():
        print(f"Error: Assets font directory not found: {ASSETS_FONTS_DIR}")
        print("Make sure i-heart-katakana-assets repo is cloned alongside this repo.")
        sys.exit(1)

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)

        print(f"Source: {ASSETS_FONTS_DIR}")
        print(f"Output: {OUTPUT_DIR}")
        print()

        total_before = 0
        total_after = 0

        for filename in sys.argv[1:]:
            font_path = ASSETS_FONTS_DIR / filename
            if not font_path.exists():
                print(f"  {filename}: NOT FOUND")
                continue

            size_before = font_path.stat().st_size
            total_before += size_before

            print(f"  {font_path.name}")

            # Step 1: Remap to temp file
            remapped_path = tmp_path / font_path.name
            if not remap_font(font_path, remapped_path):
                print(f"    SKIPPED")
                continue

            # Step 2: Subset the remapped font
            output_path = OUTPUT_DIR / font_path.name
            try:
                subset_font(remapped_path, output_path)
                size_after = output_path.stat().st_size
                total_after += size_after
                reduction = (1 - size_after / size_before) * 100
                print(f"    {format_size(size_before)} -> {format_size(size_after)} ({reduction:.0f}% reduction)")
            except Exception as e:
                print(f"    SUBSET FAILED: {e}")

            print()

        if total_before > 0:
            print(f"Total: {format_size(total_before)} -> {format_size(total_after)} "
                  f"({(1 - total_after / total_before) * 100:.0f}% reduction)")
        print(f"\nProcessed fonts written to: {OUTPUT_DIR}")


if __name__ == '__main__':
    main()
