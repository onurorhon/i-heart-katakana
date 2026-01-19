#!/usr/bin/env python3
"""
Extract katakana words from JMdict XML and output as JSON.

Usage:
    python extract_katakana.py <input_jmdict> <output_json>

Example:
    python extract_katakana.py ../design-assets/katakana-data/JMdict_e words_raw.json
"""

import xml.etree.ElementTree as ET
import json
import sys
import re
from collections import defaultdict

# Katakana character classifications
GOJUON = set('アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンー')
DAKUON = set('ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ')
HANDAKUON = set('パピプペポ')
SMALL_YOUON = set('ャュョ')  # Small versions used in combinations
SMALL_OTHER = set('ァィゥェォッ')  # Other small kana
EXTENDED_COMBOS = {
    # These are detected as pairs: base + small kana
    'ティ', 'ディ', 'トゥ', 'ドゥ',
    'ファ', 'フィ', 'フェ', 'フォ',
    'ヴァ', 'ヴィ', 'ヴ', 'ヴェ', 'ヴォ',
    'ツァ', 'ツィ', 'ツェ', 'ツォ',
    'チェ', 'シェ', 'ジェ',
    'イェ', 'ウィ', 'ウェ', 'ウォ',
    'クァ', 'クィ', 'クェ', 'クォ',
    'グァ', 'グィ', 'グェ', 'グォ',
    'デュ', 'テュ',
}

def is_katakana_only(text):
    """Check if text contains only katakana characters (including long vowel mark and middle dot)."""
    allowed = GOJUON | DAKUON | HANDAKUON | SMALL_YOUON | SMALL_OTHER | set('・')
    return all(c in allowed for c in text)

def analyze_patterns(word):
    """Analyze a katakana word and return the phonetic patterns it contains."""
    patterns = set()

    i = 0
    while i < len(word):
        char = word[i]

        # Check for extended combinations (two-character sequences)
        if i + 1 < len(word):
            pair = word[i:i+2]
            if pair in EXTENDED_COMBOS:
                patterns.add('extended')
                i += 2
                continue

        # Check for youon (consonant + small ya/yu/yo)
        if i + 1 < len(word) and word[i+1] in SMALL_YOUON:
            patterns.add('youon')
            # The base character also contributes its pattern
            if char in GOJUON:
                patterns.add('gojuon')
            elif char in DAKUON:
                patterns.add('dakuon')
            elif char in HANDAKUON:
                patterns.add('handakuon')
            i += 2
            continue

        # Single character classification
        if char in GOJUON:
            patterns.add('gojuon')
        elif char in DAKUON:
            patterns.add('dakuon')
        elif char in HANDAKUON:
            patterns.add('handakuon')
        elif char in SMALL_OTHER:
            # Small tsu (っ) and small vowels are considered gojuon variants
            patterns.add('gojuon')
        elif char == '・':
            # Middle dot separator, skip
            pass

        i += 1

    return sorted(patterns)

def parse_jmdict(filepath):
    """Parse JMdict XML and extract katakana-only entries."""
    print(f"Parsing {filepath}...")

    # JMdict uses entities extensively, we need to handle them
    # Read file and replace entity references with placeholders
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract entity definitions and create a mapping
    # Entity names can contain hyphens, values are double-quoted
    entity_pattern = re.compile(r'<!ENTITY\s+(\S+)\s+"([^"]*)">')
    entities = dict(entity_pattern.findall(content))
    print(f"Found {len(entities)} entity definitions")

    # Remove DOCTYPE declaration (causes parsing issues)
    content = re.sub(r'<!DOCTYPE[^>]+\[.*?\]>', '', content, flags=re.DOTALL)

    # Replace entity references with their values
    for entity_name, entity_value in entities.items():
        content = content.replace(f'&{entity_name};', entity_value)

    # Handle any remaining undefined entities by removing them
    content = re.sub(r'&\w+;', '', content)

    # Parse the cleaned XML
    root = ET.fromstring(content)

    words = []
    entry_count = 0
    katakana_count = 0

    for entry in root.findall('entry'):
        entry_count += 1

        # Get entry ID
        ent_seq = entry.find('ent_seq').text

        # Check if this entry has kanji - if so, skip (we want katakana-only words)
        if entry.find('k_ele') is not None:
            continue

        # Get reading elements
        r_eles = entry.findall('r_ele')
        if not r_eles:
            continue

        # Get the primary reading (first one without middle dots)
        reading = None
        for r_ele in r_eles:
            reb = r_ele.find('reb').text
            if '・' not in reb:  # Prefer readings without middle dots
                reading = reb
                break
        if reading is None:
            reading = r_eles[0].find('reb').text.replace('・', '')

        # Check if it's katakana-only
        if not is_katakana_only(reading):
            continue

        katakana_count += 1

        # Get sense information
        senses = entry.findall('sense')
        meanings = []
        source_language = None
        source_word = None
        categories = set()

        for sense in senses:
            # Get glosses (English meanings)
            for gloss in sense.findall('gloss'):
                if gloss.text:
                    meanings.append(gloss.text)

            # Get loanword source info
            for lsource in sense.findall('lsource'):
                lang = lsource.get('{http://www.w3.org/XML/1998/namespace}lang', 'eng')
                if source_language is None:
                    source_language = lang
                    source_word = lsource.text

            # Get field/category info
            for field in sense.findall('field'):
                if field.text:
                    categories.add(field.text)

        # Analyze phonetic patterns
        patterns = analyze_patterns(reading)

        # Skip if no patterns detected (shouldn't happen, but safety check)
        if not patterns:
            continue

        word_entry = {
            'id': ent_seq,
            'reading': reading,
            'meanings': meanings[:5],  # Limit to 5 meanings
            'sourceLanguage': source_language,
            'sourceWord': source_word,
            'categories': sorted(categories),
            'patterns': patterns
        }

        words.append(word_entry)

    print(f"Processed {entry_count} entries")
    print(f"Found {katakana_count} katakana-only entries")
    print(f"Output {len(words)} valid words")

    return words

def print_stats(words):
    """Print statistics about the extracted words."""
    print("\n=== Statistics ===")

    # Pattern distribution
    pattern_counts = defaultdict(int)
    for word in words:
        for pattern in word['patterns']:
            pattern_counts[pattern] += 1

    print("\nPattern counts:")
    for pattern, count in sorted(pattern_counts.items()):
        print(f"  {pattern}: {count}")

    # Source language distribution
    lang_counts = defaultdict(int)
    for word in words:
        lang = word['sourceLanguage'] or 'unknown'
        lang_counts[lang] += 1

    print("\nTop source languages:")
    for lang, count in sorted(lang_counts.items(), key=lambda x: -x[1])[:10]:
        print(f"  {lang}: {count}")

    # Word length distribution
    length_counts = defaultdict(int)
    for word in words:
        length_counts[len(word['reading'])] += 1

    print("\nWord length distribution:")
    for length, count in sorted(length_counts.items()):
        print(f"  {length} chars: {count}")

    # Category distribution
    cat_counts = defaultdict(int)
    words_with_cats = 0
    for word in words:
        if word['categories']:
            words_with_cats += 1
        for cat in word['categories']:
            cat_counts[cat] += 1

    print(f"\nWords with categories: {words_with_cats} / {len(words)}")
    print("\nTop categories:")
    for cat, count in sorted(cat_counts.items(), key=lambda x: -x[1])[:15]:
        print(f"  {cat}: {count}")

def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    words = parse_jmdict(input_file)
    print_stats(words)

    # Write output
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

    print(f"\nWritten to {output_file}")

    # Show a few examples
    print("\n=== Sample entries ===")
    for word in words[:5]:
        print(f"\n{word['reading']}")
        print(f"  meanings: {word['meanings'][:2]}")
        print(f"  patterns: {word['patterns']}")
        if word['sourceLanguage']:
            print(f"  source: {word['sourceLanguage']} ({word['sourceWord']})")

if __name__ == '__main__':
    main()
