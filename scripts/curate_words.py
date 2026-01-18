#!/usr/bin/env python3
"""
Curate extracted katakana words into final words.json.

Combines gold set + category-only batch, applies exclusions, infers source languages,
and detects wasei-eigo (Japanese-coined pseudo-English).

Usage:
    python curate_words.py

Outputs:
    ../data/words.json - Final curated dataset
    ../data/words_excluded.json - Excluded entries for future review
    ../data/wasei_candidates_for_review.json - Wasei-eigo candidates needing human review
"""

import json
from collections import defaultdict
from detect_wasei_eigo import detect_wasei_eigo_candidates, format_for_review

# Exclusion patterns based on curation reports
EXCLUDE_CATEGORIES = {
    'philosophy',  # Too academic
    'psychoanalysis',  # Too specialized
}

EXCLUDE_READINGS = {
    # League names (proper nouns)
    'アメリカンリーグ', 'ナショナルリーグ', 'イースタンリーグ', 'ウエスタンリーグ',

    # Overly technical baseball
    'アイシングザパック', 'インターフェア', 'コールドゲーム', 'ドロンゲーム',
    'エキストライニング', 'オーバースライド', 'スクイズバント',

    # Overly technical golf
    'アテスト', 'アンプレアブル', 'オーバードライブ', 'エージシューター',

    # Wrestling/boxing jargon
    'コブラツイスト', 'グレコローマンスタイル', 'インファイト',

    # Niche sports
    'エッジング', 'ドルフィンキック', 'コンパルソリー', 'コンパルソリーフィギュア',
    'エイト', 'コックス', 'エッジボール',

    # Redundant long compounds
    'オーバーハンドスロー', 'オーバーハンドパス', 'オーバーヘッドパス',

    # Finance/business jargon
    'スムージングオペレーション', 'ルンペンプロレタリアート',

    # Technical computing (save for later)
    'カスケードスタイルシート', 'アプリケーションフォーマット',
    'ダウンロードオンリーメンバー', 'マイナーバージョンアップ', 'メジャーバージョンアップ',

    # Medical
    'ロコモティブシンドローム',

    # Philosophy terms (explicit)
    'アウフヘーベン', 'アポステリオリ', 'アンチノミー', 'ジンテーゼ',
    'デュナミス', 'エネルゲイア', 'ノマドロジー', 'ヌーメノン', 'アナムネーシス',
}

# Patterns that suggest English source (for entries missing sourceLanguage)
ENGLISH_INDICATORS = {
    # Common English suffixes in katakana
    'ション', 'ティー', 'リー', 'ター', 'ナー', 'カー', 'ング', 'メント',
    'ネス', 'フル', 'レス', 'アブル', 'イブ',
}

def should_exclude(word):
    """Check if word should be excluded."""
    reading = word['reading']
    categories = word.get('categories', [])

    # Exclude by reading
    if reading in EXCLUDE_READINGS:
        return True, 'explicit_exclusion'

    # Exclude by category
    for cat in categories:
        if cat.lower() in EXCLUDE_CATEGORIES:
            return True, f'category:{cat}'

    # Exclude very long words (15+ chars) that are technical
    if len(reading) >= 15:
        return True, 'too_long'

    return False, None

def infer_source_language(word):
    """Infer source language for entries missing it."""
    if word.get('sourceLanguage'):
        return word['sourceLanguage']

    reading = word['reading']
    meanings = word.get('meanings', [])

    # Most katakana loanwords in food/sports/music are English
    categories = word.get('categories', [])
    english_categories = {'sports', 'baseball', 'golf', 'music', 'computing',
                          'Internet', 'video games', 'business'}

    if any(cat in english_categories for cat in categories):
        return 'eng'

    # Check for English-like patterns
    for indicator in ENGLISH_INDICATORS:
        if indicator in reading:
            return 'eng'

    # Food category - mostly English but some exceptions
    if 'food, cooking' in categories:
        # Could be French, Italian, etc. but default to English
        return 'eng'

    return None  # Keep as unknown

def main():
    # Load raw data
    with open('words_raw.json', 'r') as f:
        all_words = json.load(f)

    print(f"Loaded {len(all_words)} total entries")

    # Build gold set (category + source)
    gold = [w for w in all_words if w['categories'] and w['sourceLanguage']]
    print(f"Gold set: {len(gold)}")

    # Build category-only set (food/sports/music without source)
    target_cats = {'food, cooking', 'sports', 'music', 'baseball', 'golf',
                   'skiing', 'boxing', 'professional wrestling', 'figure skating',
                   'motorsport', 'clothing', 'trademark'}

    cat_only = [w for w in all_words
                if w['categories']
                and not w['sourceLanguage']
                and any(cat in target_cats for cat in w['categories'])]
    print(f"Category-only batch: {len(cat_only)}")

    # Combine and deduplicate by ID
    combined = {}
    for w in gold + cat_only:
        combined[w['id']] = w

    print(f"Combined (deduplicated): {len(combined)}")

    # Apply exclusions, infer source languages, and detect wasei-eigo
    curated = []
    excluded = []
    wasei_candidates = []  # For human review

    # Counters for wasei-eigo detection statistics
    wasei_confirmed_count = 0
    wasei_candidate_count = 0

    for word in combined.values():
        exclude, reason = should_exclude(word)

        if exclude:
            word['exclusion_reason'] = reason
            excluded.append(word)
        else:
            # Infer source language if missing
            if not word.get('sourceLanguage'):
                word['sourceLanguage'] = infer_source_language(word)

            # ===================================================================
            # WASEI-EIGO DETECTION
            # ===================================================================
            # Wasei-eigo (和製英語) are Japanese-coined "English" words that
            # either don't exist in English or have different meanings.
            # Examples: "salary man", "version up", "American dog"
            #
            # We detect these to flag them for learners, since they won't be
            # understood by English speakers despite being written in katakana.
            # ===================================================================

            wasei_status, wasei_info = detect_wasei_eigo_candidates(word)

            if wasei_status == 'confirmed_wasei_eigo':
                # This is a known wasei-eigo from our database
                # Auto-flag it for learners
                word['wasei_eigo'] = True
                word['wasei_info'] = wasei_info
                wasei_confirmed_count += 1

            elif wasei_status == 'candidate_wasei_eigo':
                # This MIGHT be wasei-eigo based on heuristics
                # Flag for human review
                word['wasei_candidate'] = True
                word['wasei_flags'] = wasei_info
                wasei_candidate_count += 1

                # Add to review queue
                wasei_candidates.append(format_for_review(word, wasei_info))

            # Add to curated list regardless of wasei-eigo status
            curated.append(word)

    print(f"\nCurated: {len(curated)}")
    print(f"Excluded: {len(excluded)}")

    # Print wasei-eigo detection statistics
    print(f"\n=== Wasei-Eigo Detection ===")
    print(f"Confirmed wasei-eigo: {wasei_confirmed_count}")
    print(f"Candidates for review: {wasei_candidate_count}")
    if wasei_candidate_count > 0:
        print(f"  → See ../data/wasei_candidates_for_review.json for human review")

    # Sort by reading for consistent output
    curated.sort(key=lambda w: w['reading'])
    excluded.sort(key=lambda w: w['reading'])

    # Print category distribution
    print("\n=== Category Distribution ===")
    cat_counts = defaultdict(int)
    for w in curated:
        for cat in w.get('categories', []):
            cat_counts[cat] += 1

    for cat, count in sorted(cat_counts.items(), key=lambda x: -x[1])[:15]:
        print(f"  {cat}: {count}")

    # Print source language distribution
    print("\n=== Source Language Distribution ===")
    lang_counts = defaultdict(int)
    for w in curated:
        lang = w.get('sourceLanguage') or 'unknown'
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

    # Write output files
    with open('../data/words.json', 'w') as f:
        json.dump(curated, f, ensure_ascii=False, indent=2)
    print(f"\nWritten {len(curated)} entries to ../data/words.json")

    with open('../data/words_excluded.json', 'w') as f:
        json.dump(excluded, f, ensure_ascii=False, indent=2)
    print(f"Written {len(excluded)} excluded entries to ../data/words_excluded.json")

    # ===================================================================
    # WASEI-EIGO CANDIDATES FOR REVIEW
    # ===================================================================
    # Export wasei-eigo candidates to a review file for human curation.
    # Human reviewers should:
    #   1. Review each candidate and its detection flags
    #   2. Set "decision" to: "confirmed", "rejected", or "uncertain"
    #   3. Add any notes about why it is/isn't wasei-eigo
    #   4. Feed confirmed decisions back into wasei_eigo_database.json
    # ===================================================================
    if wasei_candidates:
        # Sort candidates by flag count (most suspicious first)
        wasei_candidates.sort(key=lambda c: c['flagCount'], reverse=True)

        with open('../data/wasei_candidates_for_review.json', 'w') as f:
            json.dump(wasei_candidates, f, ensure_ascii=False, indent=2)
        print(f"Written {len(wasei_candidates)} wasei-eigo candidates to ../data/wasei_candidates_for_review.json")

    # Show some samples
    print("\n=== Sample Curated Entries ===")
    for w in curated[:5]:
        print(f"{w['reading']} ({w.get('sourceLanguage', '?')}) → {w['meanings'][0]} [{', '.join(w['categories'])}]")

    # Show confirmed wasei-eigo samples
    if wasei_confirmed_count > 0:
        print("\n=== Confirmed Wasei-Eigo (auto-flagged) ===")
        wasei_confirmed = [w for w in curated if w.get('wasei_eigo')]
        for w in wasei_confirmed[:5]:
            wasei_note = w.get('wasei_info', {}).get('notes', '')
            print(f"{w['reading']} → {w['meanings'][0]}")
            if wasei_note:
                print(f"  Note: {wasei_note}")

if __name__ == '__main__':
    main()
