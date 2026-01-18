#!/usr/bin/env python3
"""
Analyze katakana gold set for content curation.
"""

import json
from collections import Counter, defaultdict
import re

# Load the data
with open('/Users/onurorhon/_git/i-heart-katakana/scripts/words_gold.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total entries: {len(data)}\n")

# Category analysis
categories = []
for entry in data:
    categories.extend(entry.get('categories', []))

category_counts = Counter(categories)
print("=== CATEGORY DISTRIBUTION ===")
for cat, count in category_counts.most_common():
    print(f"{cat:30s} {count:5d}")

# Source language distribution
source_langs = Counter(entry.get('sourceLanguage', 'unknown') for entry in data)
print("\n=== SOURCE LANGUAGE DISTRIBUTION ===")
for lang, count in source_langs.most_common():
    print(f"{lang:10s} {count:5d}")

# Pattern distribution
patterns = []
for entry in data:
    patterns.extend(entry.get('patterns', []))
pattern_counts = Counter(patterns)
print("\n=== PHONETIC PATTERN DISTRIBUTION ===")
for pat, count in pattern_counts.most_common():
    print(f"{pat:15s} {count:5d}")

# Flag potentially problematic entries
print("\n=== POTENTIALLY PROBLEMATIC ENTRIES ===")

# Offensive/vulgar terms
offensive_keywords = ['bitch', 'bastard', 'damn', 'hell', 'ass', 'fuck', 'shit', 'cock', 'dick', 'slut', 'whore']
flagged_offensive = []
for entry in data:
    meanings = entry.get('meanings', [])
    for meaning in meanings:
        if any(keyword in meaning.lower() for keyword in offensive_keywords):
            flagged_offensive.append({
                'id': entry['id'],
                'reading': entry['reading'],
                'meanings': meanings,
                'reason': 'Potentially offensive/vulgar content'
            })
            break

print(f"\nOffensive/vulgar content: {len(flagged_offensive)}")
for item in flagged_offensive[:10]:  # Show first 10
    print(f"  {item['reading']:20s} - {', '.join(item['meanings'][:2])}")

# Very technical/specialized terms
technical_categories = ['philosophy', 'Christianity', 'Buddhism', 'anatomy', 'physics', 'chemistry', 'medicine']
technical_entries = [e for e in data if any(cat in technical_categories for cat in e.get('categories', []))]
print(f"\nHighly technical/specialized: {len(technical_entries)}")
tech_by_cat = defaultdict(list)
for entry in technical_entries:
    for cat in entry.get('categories', []):
        if cat in technical_categories:
            tech_by_cat[cat].append(entry['reading'])

for cat, words in sorted(tech_by_cat.items()):
    print(f"  {cat:20s} {len(words):4d} - Examples: {', '.join(words[:3])}")

# Very long words (may have display issues)
long_words = [e for e in data if len(e['reading']) > 10]
print(f"\nVery long words (>10 chars): {len(long_words)}")
for entry in sorted(long_words, key=lambda x: len(x['reading']), reverse=True)[:10]:
    print(f"  {entry['reading']:30s} ({len(entry['reading'])} chars) - {entry['meanings'][0]}")

# Extended katakana usage
extended_chars = ['ティ', 'ディ', 'トゥ', 'ドゥ', 'ファ', 'フィ', 'フェ', 'フォ', 'ヴ', 'ウィ', 'ウェ', 'ウォ', 'ツァ', 'ツィ', 'ツェ', 'ツォ']
extended_usage = defaultdict(list)
for entry in data:
    reading = entry['reading']
    for char in extended_chars:
        if char in reading:
            extended_usage[char].append(reading)

print(f"\n=== EXTENDED KATAKANA USAGE ===")
for char, words in sorted(extended_usage.items(), key=lambda x: len(x[1]), reverse=True):
    print(f"{char:5s} {len(words):4d} - Examples: {', '.join(words[:3])}")

# Identify potential wasei-eigo
print("\n=== POTENTIAL WASEI-EIGO CANDIDATES ===")
# Words from English that might be Japanese coinages
wasei_candidates = []
for entry in data:
    if entry.get('sourceLanguage') == 'eng':
        meanings = entry.get('meanings', [])
        reading = entry['reading']
        # Check for compound words that might be wasei-eigo
        if 'アップ' in reading or 'ダウン' in reading or 'インフレ' in reading or 'デフレ' in reading:
            wasei_candidates.append({
                'reading': reading,
                'meanings': meanings[:2],
                'reason': 'Compound pattern'
            })

print(f"Found {len(wasei_candidates)} potential wasei-eigo")
for item in wasei_candidates[:15]:
    print(f"  {item['reading']:25s} - {', '.join(item['meanings'])}")

# Rare/archaic categories
rare_categories = {cat: count for cat, count in category_counts.items() if count < 5}
print(f"\n=== RARE CATEGORIES (<5 entries) ===")
for cat, count in sorted(rare_categories.items(), key=lambda x: x[1]):
    examples = [e['reading'] for e in data if cat in e.get('categories', [])][:3]
    print(f"{cat:30s} {count:2d} - {', '.join(examples)}")

# Check for duplicates or near-duplicates
print(f"\n=== CHECKING FOR DUPLICATES ===")
reading_groups = defaultdict(list)
for entry in data:
    reading_groups[entry['reading']].append(entry)

duplicates = {k: v for k, v in reading_groups.items() if len(v) > 1}
print(f"Exact duplicate readings: {len(duplicates)}")
for reading, entries in list(duplicates.items())[:5]:
    print(f"  {reading}: {len(entries)} entries")
    for e in entries:
        print(f"    ID {e['id']}: {', '.join(e['meanings'][:2])}")

# Category coverage gaps
print("\n=== CATEGORY BALANCE ASSESSMENT ===")
top_5_cats = [cat for cat, _ in category_counts.most_common(5)]
bottom_5_cats = [cat for cat, _ in category_counts.most_common()[-5:] if count > 0]
print(f"Top 5 categories: {', '.join(f'{c} ({category_counts[c]})' for c in top_5_cats)}")
print(f"Bottom 5 categories: {', '.join(f'{c} ({category_counts[c]})' for c in bottom_5_cats)}")

# Everyday vs specialized ratio
everyday_cats = ['food and drink', 'clothing', 'business', 'sports', 'music']
specialized_cats = technical_categories
everyday_count = sum(1 for e in data if any(cat in everyday_cats for cat in e.get('categories', [])))
specialized_count = len(technical_entries)
print(f"\nEveryday terms: {everyday_count}")
print(f"Specialized terms: {specialized_count}")
print(f"Ratio: {everyday_count/specialized_count:.2f}:1" if specialized_count > 0 else "No specialized terms")
