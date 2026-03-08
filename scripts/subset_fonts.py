#!/usr/bin/env python3
"""
Font Subsetting Script

Subsets Japanese fonts to katakana-only glyphs (U+30A0-30FF) using pyftsubset.
This dramatically reduces file sizes for app bundling.

Source fonts are read from the private assets repo (never modified).
Subsetted fonts are written to the Xcode project's Resources/Fonts/ directory.

Requirements:
    pip install fonttools brotli

Usage:
    python scripts/subset_fonts.py FontName.ttf [FontName2.otf ...]
"""

import sys
from pathlib import Path

try:
    from fontTools.subset import main as pyftsubset_main
except ImportError:
    print("Error: fonttools not installed. Run: pip install fonttools brotli")
    sys.exit(1)


# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
ASSETS_FONTS_DIR = PROJECT_ROOT.parent / 'i-heart-katakana-assets' / 'fonts'
OUTPUT_DIR = PROJECT_ROOT / 'IHeartKatakana' / 'Resources' / 'Fonts'

# Katakana Unicode block: U+30A0-30FF
# Covers all standard katakana, small kana, dakuon, handakuon, ヴ, ヵ, ヶ,
# long vowel mark ー, and middle dot ・ (nakaguro).
UNICODE_RANGE = 'U+30A0-30FF'


def subset_font(input_path, output_path):
    """Subset a single font file to katakana-only glyphs."""
    args = [
        str(input_path),
        f'--unicodes={UNICODE_RANGE}',
        f'--output-file={output_path}',
        '--layout-features=*',
        '--no-hinting',
        '--desubroutinize',
    ]
    pyftsubset_main(args)


def format_size(size_bytes):
    """Format file size for display."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    else:
        return f"{size_bytes / (1024 * 1024):.1f} MB"


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/subset_fonts.py FontName.ttf [FontName2.otf ...]")
        sys.exit(1)

    # Validate source directory
    if not ASSETS_FONTS_DIR.exists():
        print(f"Error: Assets font directory not found: {ASSETS_FONTS_DIR}")
        print("Make sure i-heart-katakana-assets repo is cloned alongside this repo.")
        sys.exit(1)

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Subsetting to {UNICODE_RANGE}")
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

        output_path = OUTPUT_DIR / font_path.name
        size_before = font_path.stat().st_size
        total_before += size_before

        try:
            subset_font(font_path, output_path)
            size_after = output_path.stat().st_size
            total_after += size_after
            reduction = (1 - size_after / size_before) * 100
            print(f"  {font_path.name}")
            print(f"    {format_size(size_before)} -> {format_size(size_after)} ({reduction:.0f}% reduction)")
        except Exception as e:
            print(f"  {font_path.name}: FAILED - {e}")

    if total_before > 0:
        print()
        print(f"Total: {format_size(total_before)} -> {format_size(total_after)} "
              f"({(1 - total_after / total_before) * 100:.0f}% reduction)")
    print(f"\nSubsetted fonts written to: {OUTPUT_DIR}")


if __name__ == '__main__':
    main()
