#!/usr/bin/env python3
"""
Curate extracted katakana words into final words.json.

Combines gold set + category-only batch, applies exclusions, infers source languages,
backfills original words, and detects wasei-eigo.

Exclusion sources:
    1. Pattern rules (baked into code):
       - Categories (philosophy, psychoanalysis)
       - Length (15+ katakana characters)
       - Multi-word (3+ words in original), except:
         * food, cooking category
         * Culinary languages (French, Italian, Spanish, Portuguese, German)
    2. Specific IDs (from ../data/words_excluded.json): persistent, never overwritten

Usage:
    python curate_words.py

Outputs:
    ../data/words.json - Final curated dataset
"""

import json
import re
from collections import defaultdict
from detect_wasei_eigo import detect_wasei_eigo
from katakana_to_romaji import katakana_to_romaji

# Exclusion patterns based on curation reports
EXCLUDE_CATEGORIES = {
    'philosophy',  # Too academic
    'psychoanalysis',  # Too specialized
    'mahjong',  # Niche gambling game jargon
    'hanafuda',  # Niche card game jargon
}

# Exclusion list loaded from persistent file (never overwritten by this script)
EXCLUSION_FILE = '../data/words_excluded.json'

def load_exclusion_list():
    """Load persistent exclusion list. Returns empty list if file doesn't exist."""
    try:
        with open(EXCLUSION_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

EXCLUDE_WORDS = load_exclusion_list()
EXCLUDE_WORD_IDS = {entry["id"] for entry in EXCLUDE_WORDS}

# Patterns that suggest English source (for entries missing originLanguage)
ENGLISH_INDICATORS = {
    # Common English suffixes in katakana
    'ション', 'ティー', 'リー', 'ター', 'ナー', 'カー', 'ング', 'メント',
    'ネス', 'フル', 'レス', 'アブル', 'イブ',
}

# Parent category mapping: fine-grained → broad category
PARENT_CATEGORY_MAP = {
    # Food
    'food, cooking': 'Food',

    # Brands
    'trademark': 'Brands',

    # Everyday Life
    'clothing': 'Everyday Life',
    'onomatopoeia': 'Onomatopoeia',

    # Sports & Recreation
    'sports': 'Sports & Recreation',
    'baseball': 'Sports & Recreation',
    'golf': 'Sports & Recreation',
    'boxing': 'Sports & Recreation',
    'skiing': 'Sports & Recreation',
    'martial arts': 'Sports & Recreation',
    'professional wrestling': 'Sports & Recreation',
    'card games': 'Sports & Recreation',
    'mahjong': 'Sports & Recreation',
    'hanafuda': 'Sports & Recreation',
    'motorsport': 'Sports & Recreation',
    'horse racing': 'Sports & Recreation',
    'fishing': 'Sports & Recreation',

    # Science & Nature
    'chemistry': 'Science & Nature',
    'biology': 'Science & Nature',
    'geology': 'Science & Nature',
    'physics': 'Science & Nature',
    'astronomy': 'Science & Nature',
    'botany': 'Science & Nature',
    'zoology': 'Science & Nature',
    'meteorology': 'Science & Nature',
    'agriculture': 'Science & Nature',

    # Technology
    'computing': 'Technology',
    'video games': 'Technology',
    'Internet': 'Technology',
    'electronics': 'Technology',
    'telecommunications': 'Technology',
    'electricity, elec. eng.': 'Technology',
    'engineering': 'Technology',
    'civil engineering': 'Technology',
    'railway': 'Technology',
    'mining': 'Technology',

    # Health & Medicine
    'medicine': 'Health & Medicine',
    'pharmacology': 'Health & Medicine',
    'anatomy': 'Health & Medicine',
    'surgery': 'Health & Medicine',
    'dentistry': 'Health & Medicine',
    'genetics': 'Health & Medicine',
    'biochemistry': 'Health & Medicine',
    'psychology': 'Health & Medicine',

    # Business & Finance
    'business': 'Business & Finance',
    'finance': 'Business & Finance',
    'economics': 'Business & Finance',
    'stock market': 'Business & Finance',
    'law': 'Business & Finance',
    'politics': 'Business & Finance',

    # Arts & Entertainment
    'music': 'Arts & Entertainment',
    'film': 'Arts & Entertainment',
    'photography': 'Arts & Entertainment',
    'art, aesthetics': 'Arts & Entertainment',
    'architecture': 'Arts & Entertainment',
    'printing': 'Arts & Entertainment',
    'television': 'Arts & Entertainment',

    # Academic & Humanities
    'linguistics': 'Academic & Humanities',
    'Greek mythology': 'Academic & Humanities',
    'Roman mythology': 'Academic & Humanities',
    'Christianity': 'Academic & Humanities',
    'Buddhism': 'Academic & Humanities',
    'archeology': 'Academic & Humanities',
    'statistics': 'Academic & Humanities',
    'mathematics': 'Academic & Humanities',

    # Military & Aviation
    'military': 'Military & Aviation',
    'aviation': 'Military & Aviation',
}


def get_parent_category(word):
    """
    Determine the parent category for a word.

    Wasei-eigo words get their own category. Otherwise uses the first
    matching category from PARENT_CATEGORY_MAP. Falls back to 'Other'
    if no categories match.
    """
    # Wasei-eigo words get their own parent category
    if word.get('wasei_eigo'):
        return 'Wasei-eigo'

    for cat in word.get('categories', []):
        if cat in PARENT_CATEGORY_MAP:
            return PARENT_CATEGORY_MAP[cat]
    return 'Other'


def should_exclude(word):
    """Check if word should be excluded."""
    word_id = word['id']
    word_text = word['word']
    categories = word.get('categories', [])

    # Exclude by ID (from curated exclusion list)
    if word_id in EXCLUDE_WORD_IDS:
        return True, 'explicit_exclusion'

    # Exclude by category
    for cat in categories:
        if cat.lower() in EXCLUDE_CATEGORIES:
            return True, f'category:{cat}'

    # Exclude very long words (15+ chars) that are technical
    if len(word_text) >= 15:
        return True, 'too_long'

    # Exclude multi-word entries (3+ words) with exceptions
    original = word.get('originalWord') or word.get('originalWordInferred') or ''
    word_count = len(original.split())
    if word_count >= 3:
        # Exception: food/cooking category
        if 'food, cooking' in categories:
            pass  # Keep it
        # Exception: culinary/cultural languages (French, Italian, Spanish, Portuguese, German)
        elif word.get('originLanguage') in {'fre', 'ita', 'spa', 'por', 'ger'}:
            pass  # Keep it
        else:
            return True, 'multi_word'

    return False, None


def infer_origin_language(word):
    """Infer origin language for entries missing it."""
    if word.get('originLanguage'):
        return word['originLanguage']

    word_text = word['word']

    # Most katakana loanwords in food/sports/music are English
    categories = word.get('categories', [])
    english_categories = {'sports', 'baseball', 'golf', 'music', 'computing',
                          'Internet', 'video games', 'business'}

    if any(cat in english_categories for cat in categories):
        return 'eng'

    # Check for English-like patterns
    for indicator in ENGLISH_INDICATORS:
        if indicator in word_text:
            return 'eng'

    # Food category - mostly English but some exceptions
    if 'food, cooking' in categories:
        return 'eng'

    return None  # Keep as unknown


def clean_inferred_original(meaning):
    """
    Clean a meaning to extract just the source word.

    JMdict meanings often include parenthetical context like:
    - "away (game, goal, etc.)" → "away"
    - "(ship's) anchor" → "anchor"
    - "Sachertorte (chocolate cake...)" → "Sachertorte"

    Returns cleaned string or None if result seems like a definition.
    """
    # Remove all parenthetical content (including leading parentheticals)
    cleaned = re.sub(r'\s*\([^)]+\)\s*', ' ', meaning)

    # Clean up whitespace
    cleaned = ' '.join(cleaned.split()).strip()

    # If result is suspiciously long, it's probably a definition
    # Most source words are under 35 chars (e.g., "Sachertorte", "acqua pazza")
    if len(cleaned) > 35:
        return None

    # Flag if contains definition markers (these are descriptions, not source words)
    definition_markers = [
        'type of', 'kind of', 'used for', 'consisting of',
        'made with', 'containing', 'mixture of', 'style of',
        'form of', 'piece of', 'game of', 'method of'
    ]
    if any(marker in cleaned.lower() for marker in definition_markers):
        return None

    return cleaned if cleaned else None


def infer_original_word(word):
    """
    Infer originalWord for entries missing it.

    If originalWord is not set, use the first meaning as our best guess.
    The first meaning in JMdict is typically the source word (for any language).

    Returns the cleaned/inferred value or None.
    """
    # Skip if already has originalWord from JMdict
    if word.get('originalWord'):
        return None

    meanings = word.get('meanings', [])
    if not meanings:
        return None

    # Clean the first meaning to extract just the source word
    return clean_inferred_original(meanings[0])


def build_output_entry(word):
    """
    Build the final output entry with proper field ordering.

    Order: id, word, romaji, originalWord, originalWordInferred, originLanguage,
           wasei_eigo, meanings, categories, parentCategory, patterns, [wasei_info]
    """
    entry = {
        'id': word['id'],
        'word': word['word'],
        'romaji': word['romaji'],
        'originalWord': word.get('originalWord'),
        'originalWordInferred': word.get('originalWordInferred'),
        'originLanguage': word.get('originLanguage'),
        'wasei_eigo': word.get('wasei_eigo', False),
        'meanings': word['meanings'],
        'categories': word['categories'],
        'parentCategory': get_parent_category(word),
        'patterns': word['patterns'],
    }

    # Add wasei_info if present
    if word.get('wasei_info'):
        entry['wasei_info'] = word['wasei_info']

    return entry


def main():
    # Load raw data
    with open('words_raw.json', 'r') as f:
        all_words = json.load(f)

    print(f"Loaded {len(all_words)} total entries")

    # Build gold set (category + source)
    gold = [w for w in all_words if w['categories'] and w['originLanguage']]
    print(f"Gold set: {len(gold)}")

    # Build category-only set (categories to include even without originLanguage)
    # Note: Niche categories (baseball, golf, computing, etc.) come via gold set only
    target_cats = {'food, cooking', 'sports', 'music', 'clothing', 'trademark',
                   'business', 'medicine', 'film', 'photography', 'onomatopoeia'}

    cat_only = [w for w in all_words
                if w['categories']
                and not w['originLanguage']
                and any(cat in target_cats for cat in w['categories'])]
    print(f"Category-only batch: {len(cat_only)}")

    # Combine and deduplicate by ID
    combined = {}
    for w in gold + cat_only:
        combined[w['id']] = w

    print(f"Combined (deduplicated): {len(combined)}")

    # Process words
    curated = []
    excluded = []

    # Counters
    wasei_count = 0
    inferred_count = 0

    for word in combined.values():
        exclude, reason = should_exclude(word)

        if exclude:
            word['exclusion_reason'] = reason
            excluded.append(word)
        else:
            # Infer origin language if missing
            if not word.get('originLanguage'):
                word['originLanguage'] = infer_origin_language(word)

            # Generate romaji from katakana
            word['romaji'] = katakana_to_romaji(word['word'])

            # Infer originalWord for entries missing it
            # Onomatopoeia are native Japanese - use placeholder instead of inferring
            if 'onomatopoeia' in word.get('categories', []):
                word['originalWordInferred'] = '(onomatopoeia)'
                inferred_count += 1
            else:
                inferred = infer_original_word(word)
                if inferred:
                    word['originalWordInferred'] = inferred
                    inferred_count += 1

            # Check for wasei-eigo: use JMdict source data first, then database for extra info
            if word.get('wasei_eigo'):
                wasei_count += 1
                # Try to get additional info from our curated database
                wasei_info = detect_wasei_eigo(word['word'])
                if wasei_info:
                    word['wasei_info'] = wasei_info
            else:
                # Fallback: check our curated database for entries JMdict missed
                wasei_info = detect_wasei_eigo(word['word'])
                if wasei_info:
                    word['wasei_eigo'] = True
                    word['wasei_info'] = wasei_info
                    wasei_count += 1

            # Exclude words without any original word (can't show learners the source)
            if not word.get('originalWord') and not word.get('originalWordInferred'):
                word['exclusion_reason'] = 'no_original_word'
                excluded.append(word)
            else:
                curated.append(word)

    print(f"\nCurated: {len(curated)}")
    print(f"Excluded: {len(excluded)}")

    # Print processing statistics
    print(f"\n=== Processing Statistics ===")
    print(f"Wasei-eigo flagged: {wasei_count}")
    print(f"Original words inferred: {inferred_count}")

    # Count originalWord coverage
    has_original = sum(1 for w in curated if w.get('originalWord'))
    has_inferred = sum(1 for w in curated if w.get('originalWordInferred'))
    print(f"With originalWord (from JMdict): {has_original}")
    print(f"With originalWordInferred: {has_inferred}")

    # Sort by word for consistent output
    curated.sort(key=lambda w: w['word'])
    excluded.sort(key=lambda w: w['word'])

    # Print category distribution
    print("\n=== Category Distribution ===")
    cat_counts = defaultdict(int)
    for w in curated:
        for cat in w.get('categories', []):
            cat_counts[cat] += 1

    for cat, count in sorted(cat_counts.items(), key=lambda x: -x[1])[:15]:
        print(f"  {cat}: {count}")

    # Print parent category distribution
    print("\n=== Parent Category Distribution ===")
    parent_counts = defaultdict(int)
    for w in curated:
        parent_counts[get_parent_category(w)] += 1

    for parent, count in sorted(parent_counts.items(), key=lambda x: -x[1]):
        print(f"  {parent}: {count}")

    # Print source language distribution
    print("\n=== Origin Language Distribution ===")
    lang_counts = defaultdict(int)
    for w in curated:
        lang = w.get('originLanguage') or 'unknown'
        lang_counts[lang] += 1

    for lang, count in sorted(lang_counts.items(), key=lambda x: -x[1])[:10]:
        print(f"  {lang}: {count}")

    # Print pattern distribution
    print("\n=== Pattern Distribution ===")
    pattern_counts = defaultdict(int)
    for w in curated:
        for p in w.get('patterns', []):
            pattern_counts[p] += 1

    for pattern, count in sorted(pattern_counts.items()):
        print(f"  {pattern}: {count}")

    # Build output with proper field ordering
    output = [build_output_entry(w) for w in curated]

    # Write output
    with open('../data/words.json', 'w') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    print(f"\nWritten {len(output)} entries to ../data/words.json")
    print(f"Excluded {len(excluded)} entries (pattern rules + {len(EXCLUDE_WORDS)} from exclusion list)")

    # Show some samples
    print("\n=== Sample Curated Entries ===")
    for w in output[:5]:
        orig = w.get('originalWord') or '?'
        print(f"{w['word']} ({orig}) → {w['meanings'][0]}")

    # Show wasei-eigo samples
    if wasei_count > 0:
        print("\n=== Wasei-Eigo Entries ===")
        wasei_entries = [w for w in output if w.get('wasei_eigo')]
        for w in wasei_entries[:5]:
            print(f"{w['word']} → {w['meanings'][0]}")
            if w.get('wasei_info', {}).get('notes'):
                print(f"  Note: {w['wasei_info']['notes']}")


if __name__ == '__main__':
    main()
