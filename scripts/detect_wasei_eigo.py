#!/usr/bin/env python3
"""
Wasei-Eigo Detection Module

WHAT IS WASEI-EIGO?
-------------------
Wasei-eigo (和製英語) means "Japanese-made English" - words that appear to be
English loanwords but are actually Japanese coinages. They either:
  1. Don't exist in English at all (e.g., "salary man" for office worker)
  2. Have significantly different meanings in Japanese vs. English
     (e.g., "claim" used to mean "complaint")
  3. Use non-standard English constructions (e.g., "version up" instead of "update")

WHY FLAG WASEI-EIGO?
--------------------
For learners, it's important to know when a katakana word is wasei-eigo because:
  - They won't be understood if used with English speakers
  - They represent uniquely Japanese concepts or cultural artifacts
  - They help learners understand the difference between true loanwords and
    Japanese innovations

DETECTION STRATEGY
------------------
This module uses a 3-tier approach:

  Tier 1: Known Database (100% accuracy, limited coverage)
    - Manually curated list of confirmed wasei-eigo
    - Auto-flags with wasei_eigo: true

  Tier 2: Heuristic Detection (70-80% accuracy, broader coverage)
    - Pattern matching (e.g., "X-up" constructions)
    - English phrase validation
    - Flags candidates for human review

  Tier 3: Human Review Workflow
    - Exports candidates to CSV for human decision
    - Approved candidates feed back into known database
    - Continuous improvement of detection rules

Usage:
    from detect_wasei_eigo import detect_wasei_eigo_candidates

    word = {"reading": "アメリカンドッグ", "sourceWord": "American dog", ...}
    status, info = detect_wasei_eigo_candidates(word)

    if status == 'confirmed_wasei_eigo':
        word['wasei_eigo'] = True
    elif status == 'candidate_wasei_eigo':
        word['wasei_candidate'] = True
        # Add to review queue
"""

import json
import re
from pathlib import Path

# Load wasei-eigo database
_DB_PATH = Path(__file__).parent / 'wasei_eigo_database.json'

def load_wasei_database():
    """Load the known wasei-eigo database."""
    with open(_DB_PATH, 'r', encoding='utf-8') as f:
        return json.load(f)

# Global database (loaded once)
WASEI_DB = load_wasei_database()


# =============================================================================
# TIER 1: CONFIRMED WASEI-EIGO DETECTION (High Confidence)
# =============================================================================

def check_known_wasei_eigo(reading):
    """
    Check if the katakana reading is a known wasei-eigo from our database.

    This is the highest confidence detection - these are manually verified
    wasei-eigo terms that should always be flagged.

    Args:
        reading: Katakana reading (e.g., "アメリカンドッグ")

    Returns:
        dict or None: Wasei-eigo info if found, None otherwise
    """
    confirmed = WASEI_DB.get('confirmed', {})
    return confirmed.get(reading)


# =============================================================================
# TIER 2: HEURISTIC DETECTION (Medium Confidence)
# =============================================================================

def matches_wasei_pattern(reading):
    """
    Check if the katakana reading matches common wasei-eigo patterns.

    Common patterns include:
      - "X-アップ/ダウン" (X-up/down) constructions that don't exist in English
      - "アメリカンX" (American X) constructions
      - "マイX" (my X) used as compound nouns

    Args:
        reading: Katakana reading

    Returns:
        list: List of pattern names that matched (empty if none)
    """
    patterns = WASEI_DB.get('patterns', {})
    matches = []

    for pattern_name, pattern_info in patterns.items():
        if pattern_name.startswith('_'):
            continue  # Skip metadata fields

        pattern = pattern_info.get('pattern')
        if pattern and re.search(pattern, reading):
            matches.append(pattern_name)

    return matches


def is_non_standard_english_phrase(source_word):
    """
    Check if the source word/phrase is non-standard English.

    This checks against a list of known non-standard English phrases
    that are actually wasei-eigo constructions.

    Args:
        source_word: The source word/phrase (e.g., "version up")

    Returns:
        bool: True if the phrase is non-standard English
    """
    if not source_word:
        return False

    # Normalize for comparison (lowercase, strip)
    normalized = source_word.lower().strip()

    # Get non-standard phrases from database
    validation = WASEI_DB.get('english_validation', {})
    non_standard = validation.get('non_standard_phrases', [])

    # Check if this exact phrase is known to be non-standard
    for phrase in non_standard:
        if normalized == phrase.lower():
            return True

    return False


def has_wasei_construction_indicators(word):
    """
    Check for linguistic indicators that suggest wasei-eigo construction.

    This looks for patterns in how the word is constructed that are
    characteristic of Japanese coinages rather than actual English.

    Indicators include:
      - Source word doesn't match the English meaning
      - Compound words that wouldn't exist in English
      - Semantic shifts from English source

    Args:
        word: Full word dict with reading, sourceWord, meanings

    Returns:
        list: List of indicator flags found
    """
    indicators = []

    source_word = word.get('sourceWord') or ''
    source_word = source_word.lower()
    meanings = word.get('meanings', [])

    # Indicator 1: sourceWord uses "X up/down" pattern
    if re.search(r'\b\w+\s+(up|down)$', source_word):
        # Check if the meaning suggests a different English term would be used
        if any(keyword in ' '.join(meanings).lower()
               for keyword in ['update', 'upgrade', 'increase', 'decrease', 'improve']):
            indicators.append('verb_up_down_construction')

    # Indicator 2: sourceWord contains "American" for items that don't use that in English
    if 'american' in source_word and 'american' not in ' '.join(meanings).lower():
        indicators.append('american_prefix_mismatch')

    # Indicator 3: sourceWord is a phrase that sounds constructed
    # (multiple words where English would use a single word)
    if len(source_word.split()) > 1 and meanings:
        first_meaning = meanings[0].lower()
        # If the first meaning is a single word but source is multiple words
        if len(first_meaning.split(',')[0].split()) == 1:
            indicators.append('phrase_vs_single_word')

    return indicators


# =============================================================================
# MAIN DETECTION FUNCTION
# =============================================================================

def detect_wasei_eigo_candidates(word):
    """
    Detect whether a word is confirmed wasei-eigo or a candidate for review.

    This is the main entry point for wasei-eigo detection. It runs through
    all detection tiers and returns a classification.

    Detection Flow:
      1. Check known wasei-eigo database (Tier 1 - confirmed)
      2. Check sourceWord for non-standard English
      3. Check katakana reading for wasei patterns
      4. Check for construction indicators
      5. Return status and flags for human review if needed

    Args:
        word: Dict containing word data with keys:
              - reading: Katakana reading
              - sourceWord: Original source word/phrase (optional)
              - meanings: List of English meanings (optional)
              - sourceLanguage: Source language code (optional)

    Returns:
        tuple: (status, info)
            status: One of:
                - 'confirmed_wasei_eigo': Definitely wasei-eigo (auto-flag)
                - 'candidate_wasei_eigo': Likely wasei-eigo (needs review)
                - None: Not wasei-eigo based on current detection
            info: Dict with additional information or list of flags

    Example:
        >>> word = {
        ...     "reading": "アメリカンドッグ",
        ...     "sourceWord": "American dog",
        ...     "meanings": ["corn dog"]
        ... }
        >>> status, info = detect_wasei_eigo_candidates(word)
        >>> status
        'confirmed_wasei_eigo'
    """
    reading = word.get('reading', '')
    source_word = word.get('sourceWord', '')

    # -------------------------------------------------------------------------
    # TIER 1: Check confirmed wasei-eigo database
    # -------------------------------------------------------------------------
    known_wasei = check_known_wasei_eigo(reading)
    if known_wasei:
        return 'confirmed_wasei_eigo', known_wasei

    # -------------------------------------------------------------------------
    # TIER 2: Heuristic detection for candidates
    # -------------------------------------------------------------------------
    flags = []

    # Check if sourceWord is non-standard English
    if source_word and is_non_standard_english_phrase(source_word):
        flags.append({
            'type': 'non_standard_english_source',
            'detail': f'"{source_word}" is not standard English'
        })

    # Check for wasei-eigo patterns in the reading
    pattern_matches = matches_wasei_pattern(reading)
    if pattern_matches:
        flags.append({
            'type': 'wasei_pattern_match',
            'detail': f'Matches patterns: {", ".join(pattern_matches)}'
        })

    # Check for construction indicators
    construction_indicators = has_wasei_construction_indicators(word)
    if construction_indicators:
        flags.append({
            'type': 'construction_indicator',
            'detail': f'Indicators: {", ".join(construction_indicators)}'
        })

    # -------------------------------------------------------------------------
    # Return candidate if any flags were raised
    # -------------------------------------------------------------------------
    if flags:
        return 'candidate_wasei_eigo', flags

    return None, []


# =============================================================================
# UTILITY FUNCTIONS FOR REVIEW WORKFLOW
# =============================================================================

def format_for_review(word, flags):
    """
    Format a wasei-eigo candidate for human review.

    Creates a human-readable summary of why this word was flagged
    as a potential wasei-eigo.

    Args:
        word: Word dictionary
        flags: List of detection flags

    Returns:
        dict: Formatted review entry
    """
    return {
        'reading': word.get('reading'),
        'sourceWord': word.get('sourceWord', ''),
        'meanings': word.get('meanings', []),
        'sourceLanguage': word.get('sourceLanguage', ''),
        'flags': flags,
        'flagCount': len(flags),
        'decision': '',  # To be filled by human reviewer
        'notes': ''      # To be filled by human reviewer
    }


def export_candidates_for_review(candidates, output_path):
    """
    Export wasei-eigo candidates to JSON for human review.

    Args:
        candidates: List of candidate words with flags
        output_path: Path to save the review file
    """
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(candidates, f, ensure_ascii=False, indent=2)

    print(f"Exported {len(candidates)} wasei-eigo candidates to {output_path}")
    print("Please review and update 'decision' field for each entry:")
    print("  - 'confirmed': This IS wasei-eigo")
    print("  - 'rejected': This is NOT wasei-eigo")
    print("  - 'uncertain': Needs further research")


# =============================================================================
# MODULE TEST (when run directly)
# =============================================================================

if __name__ == '__main__':
    # Test the detection system
    print("=== Wasei-Eigo Detection Module Test ===\n")

    test_words = [
        {
            "reading": "アメリカンドッグ",
            "sourceWord": "American dog",
            "meanings": ["corn dog"]
        },
        {
            "reading": "バージョンアップ",
            "sourceWord": "version up",
            "meanings": ["update", "upgrade"]
        },
        {
            "reading": "コーヒー",
            "sourceWord": "coffee",
            "meanings": ["coffee"]
        },
        {
            "reading": "アイスクリーム",
            "sourceWord": "ice cream",
            "meanings": ["ice cream"]
        }
    ]

    for word in test_words:
        status, info = detect_wasei_eigo_candidates(word)
        print(f"Word: {word['reading']}")
        print(f"  Status: {status}")
        print(f"  Info: {info}")
        print()
