#!/usr/bin/env python3
"""
Wasei-Eigo Detection Module

Wasei-eigo (和製英語) means "Japanese-made English" - words that appear to be
English loanwords but are actually Japanese coinages. They either:
  1. Don't exist in English at all (e.g., "salary man" for office worker)
  2. Have significantly different meanings in Japanese vs. English
  3. Use non-standard English constructions (e.g., "version up" instead of "update")

This module checks words against a curated database of confirmed wasei-eigo.
No heuristic detection - only database lookup for high accuracy.

Usage:
    from detect_wasei_eigo import detect_wasei_eigo

    info = detect_wasei_eigo("アメリカンドッグ")
    if info:
        word['wasei_eigo'] = True
        word['wasei_info'] = info
"""

import json
from pathlib import Path

# Load wasei-eigo database
_DB_PATH = Path(__file__).parent / 'wasei_eigo_database.json'

def load_wasei_database():
    """Load the known wasei-eigo database."""
    with open(_DB_PATH, 'r', encoding='utf-8') as f:
        return json.load(f)

# Global database (loaded once)
WASEI_DB = load_wasei_database()


def detect_wasei_eigo(word_text):
    """
    Check if a katakana word is a confirmed wasei-eigo.

    Args:
        word_text: Katakana word (e.g., "アメリカンドッグ")

    Returns:
        dict or None: Wasei-eigo info if found, None otherwise
            Contains: english_equivalent, wasei_meaning, notes
    """
    confirmed = WASEI_DB.get('confirmed', {})
    return confirmed.get(word_text)


if __name__ == '__main__':
    # Test the detection system
    print("=== Wasei-Eigo Detection Module Test ===\n")

    test_words = [
        "アメリカンドッグ",  # Known wasei-eigo
        "バージョンアップ",  # Known wasei-eigo
        "コーヒー",          # Not wasei-eigo
        "アイスクリーム",    # Not wasei-eigo
    ]

    for word in test_words:
        info = detect_wasei_eigo(word)
        print(f"Word: {word}")
        if info:
            print(f"  ✓ Confirmed wasei-eigo")
            print(f"  English: {info.get('english_equivalent', 'N/A')}")
        else:
            print(f"  Not in wasei-eigo database")
        print()
