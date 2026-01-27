#!/usr/bin/env python3
"""
Convert katakana strings to romaji.

Handles:
- Basic katakana (gojūon)
- Voiced consonants (dakuon)
- P-sounds (handakuon)
- Combination sounds (yōon)
- Extended katakana for foreign sounds
- Small kana (っ, ー, etc.)
"""

# Basic katakana mapping
KATAKANA_TO_ROMAJI = {
    # Vowels
    'ア': 'a', 'イ': 'i', 'ウ': 'u', 'エ': 'e', 'オ': 'o',

    # K-row
    'カ': 'ka', 'キ': 'ki', 'ク': 'ku', 'ケ': 'ke', 'コ': 'ko',

    # S-row
    'サ': 'sa', 'シ': 'shi', 'ス': 'su', 'セ': 'se', 'ソ': 'so',

    # T-row
    'タ': 'ta', 'チ': 'chi', 'ツ': 'tsu', 'テ': 'te', 'ト': 'to',

    # N-row
    'ナ': 'na', 'ニ': 'ni', 'ヌ': 'nu', 'ネ': 'ne', 'ノ': 'no',

    # H-row
    'ハ': 'ha', 'ヒ': 'hi', 'フ': 'fu', 'ヘ': 'he', 'ホ': 'ho',

    # M-row
    'マ': 'ma', 'ミ': 'mi', 'ム': 'mu', 'メ': 'me', 'モ': 'mo',

    # Y-row
    'ヤ': 'ya', 'ユ': 'yu', 'ヨ': 'yo',

    # R-row
    'ラ': 'ra', 'リ': 'ri', 'ル': 'ru', 'レ': 're', 'ロ': 'ro',

    # W-row
    'ワ': 'wa', 'ヲ': 'wo',

    # N
    'ン': 'n',

    # Dakuon (voiced)
    'ガ': 'ga', 'ギ': 'gi', 'グ': 'gu', 'ゲ': 'ge', 'ゴ': 'go',
    'ザ': 'za', 'ジ': 'ji', 'ズ': 'zu', 'ゼ': 'ze', 'ゾ': 'zo',
    'ダ': 'da', 'ヂ': 'ji', 'ヅ': 'zu', 'デ': 'de', 'ド': 'do',
    'バ': 'ba', 'ビ': 'bi', 'ブ': 'bu', 'ベ': 'be', 'ボ': 'bo',

    # Handakuon (p-sounds)
    'パ': 'pa', 'ピ': 'pi', 'プ': 'pu', 'ペ': 'pe', 'ポ': 'po',

    # Yōon (combination sounds)
    'キャ': 'kya', 'キュ': 'kyu', 'キョ': 'kyo',
    'シャ': 'sha', 'シュ': 'shu', 'ショ': 'sho',
    'チャ': 'cha', 'チュ': 'chu', 'チョ': 'cho',
    'ニャ': 'nya', 'ニュ': 'nyu', 'ニョ': 'nyo',
    'ヒャ': 'hya', 'ヒュ': 'hyu', 'ヒョ': 'hyo',
    'ミャ': 'mya', 'ミュ': 'myu', 'ミョ': 'myo',
    'リャ': 'rya', 'リュ': 'ryu', 'リョ': 'ryo',
    'ギャ': 'gya', 'ギュ': 'gyu', 'ギョ': 'gyo',
    'ジャ': 'ja', 'ジュ': 'ju', 'ジョ': 'jo',
    'ビャ': 'bya', 'ビュ': 'byu', 'ビョ': 'byo',
    'ピャ': 'pya', 'ピュ': 'pyu', 'ピョ': 'pyo',

    # Extended katakana (foreign sounds)
    'ティ': 'ti', 'ディ': 'di',
    'トゥ': 'tu', 'ドゥ': 'du',
    'ファ': 'fa', 'フィ': 'fi', 'フェ': 'fe', 'フォ': 'fo',
    'ヴァ': 'va', 'ヴィ': 'vi', 'ヴ': 'vu', 'ヴェ': 've', 'ヴォ': 'vo',
    'ウィ': 'wi', 'ウェ': 'we', 'ウォ': 'wo',
    'ツァ': 'tsa', 'ツィ': 'tsi', 'ツェ': 'tse', 'ツォ': 'tso',
    'チェ': 'che',
    'シェ': 'she',
    'ジェ': 'je',
    'イェ': 'ye',
    'クァ': 'kwa', 'クィ': 'kwi', 'クェ': 'kwe', 'クォ': 'kwo',
    'グァ': 'gwa',
    'テュ': 'tyu', 'デュ': 'dyu',
    'フュ': 'fyu',

    # Small kana (used in combinations)
    'ァ': 'a', 'ィ': 'i', 'ゥ': 'u', 'ェ': 'e', 'ォ': 'o',
    'ャ': 'ya', 'ュ': 'yu', 'ョ': 'yo',

    # Special
    'ー': '-',  # Long vowel mark (handled specially below)
}

# Small tsu (っ) doubles the following consonant
SMALL_TSU = 'ッ'

# Long vowel mark
LONG_VOWEL = 'ー'

def katakana_to_romaji(text, use_dashes=True):
    """Convert katakana string to romaji.

    Args:
        text: Katakana string to convert
        use_dashes: If True, separate syllables with dashes (e.g., 'pa-su-waa-do')
    """
    syllables = []  # List of syllable strings
    pending_double = False  # Track if next syllable needs doubled consonant
    i = 0

    while i < len(text):
        # Check for small tsu (doubles next consonant)
        if text[i] == SMALL_TSU:
            pending_double = True
            i += 1
            continue

        # Check for long vowel mark
        if text[i] == LONG_VOWEL:
            # Extend previous syllable's vowel
            if syllables:
                last = syllables[-1]
                if last and last[-1] in 'aeiou':
                    syllables[-1] = last + last[-1]  # Extend the vowel
            i += 1
            continue

        # Try two-character combinations first (yōon, extended)
        romaji, consumed = get_romaji_at(text, i)
        if romaji:
            # Apply doubled consonant if pending
            if pending_double and romaji[0].isalpha():
                romaji = romaji[0] + romaji
                pending_double = False
            syllables.append(romaji)
            i += consumed
        else:
            # Unknown character, keep as-is
            syllables.append(text[i])
            i += 1

    if use_dashes:
        return '-'.join(syllables)
    else:
        return ''.join(syllables)

def get_romaji_at(text, i):
    """Get romaji for character(s) at position i. Returns (romaji, chars_consumed)."""
    # Try two-character combination first
    if i + 1 < len(text):
        two_char = text[i:i+2]
        if two_char in KATAKANA_TO_ROMAJI:
            return KATAKANA_TO_ROMAJI[two_char], 2

    # Try single character
    one_char = text[i]
    if one_char in KATAKANA_TO_ROMAJI:
        return KATAKANA_TO_ROMAJI[one_char], 1

    return None, 0


if __name__ == '__main__':
    # Test cases with dashes
    tests_dashed = [
        ('コーヒー', 'koo-hii'),
        ('アイスクリーム', 'a-i-su-ku-rii-mu'),
        ('コンピューター', 'ko-n-pyuu-taa'),
        ('ファイル', 'fa-i-ru'),
        ('ティッシュ', 'ti-sshu'),
        ('カタカナ', 'ka-ta-ka-na'),
        ('ジュース', 'juu-su'),
        ('チョコレート', 'cho-ko-ree-to'),
        ('パスワード', 'pa-su-waa-do'),
    ]

    print("Testing katakana to romaji conversion (with dashes):")
    for katakana, expected in tests_dashed:
        result = katakana_to_romaji(katakana, use_dashes=True)
        status = '✓' if result == expected else '✗'
        print(f"  {status} {katakana} → {result} (expected: {expected})")

    # Test without dashes
    print("\nTesting without dashes:")
    result = katakana_to_romaji('パスワード', use_dashes=False)
    print(f"  パスワード → {result} (expected: pasuwaado)")
