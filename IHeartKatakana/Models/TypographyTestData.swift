#if DEBUG
import Foundation

/// Test data for typography edge cases.
/// Only available in debug builds - never shown to users.
enum TypographyTestData {
    static let parentCategory = "Typography Test"

    static let words: [Word] = [
        // Very short (1-2 chars) - test minimum sizing
        Word(
            id: "test-1char-a",
            word: "ア",
            romaji: "a",
            meanings: ["letter A"],
            originLanguage: nil,
            originalWord: nil,
            originalWordInferred: "a",
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-2char",
            word: "パン",
            romaji: "pa-n",
            meanings: ["bread"],
            originLanguage: "por",
            originalWord: "pão",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["handakuon", "gojuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),

        // Short with long vowels (3-4 chars)
        Word(
            id: "test-4char-coffee",
            word: "コーヒー",
            romaji: "ko-o-hi-i",
            meanings: ["coffee"],
            originLanguage: "eng",
            originalWord: "coffee",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-3char-beer",
            word: "ビール",
            romaji: "bi-i-ru",
            meanings: ["beer"],
            originLanguage: "dut",
            originalWord: "bier",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "dakuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),

        // Medium compounds (6-8 chars)
        Word(
            id: "test-6char-hotdog",
            word: "ホットドッグ",
            romaji: "ho-t-to-do-g-gu",
            meanings: ["hot dog"],
            originLanguage: "eng",
            originalWord: "hot dog",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "dakuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-7char-icecream",
            word: "アイスクリーム",
            romaji: "a-i-su-ku-ri-i-mu",
            meanings: ["ice cream"],
            originLanguage: "eng",
            originalWord: "ice cream",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "dakuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),

        // Long compounds (10-12 chars)
        Word(
            id: "test-10char",
            word: "アディショナルタイム",
            romaji: "a-di-sho-na-ru-ta-i-mu",
            meanings: ["additional time", "injury time"],
            originLanguage: "eng",
            originalWord: "additional time",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "youon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-12char",
            word: "メタボリックシンドローム",
            romaji: "me-ta-bo-ri-k-ku-shi-n-do-ro-o-mu",
            meanings: ["metabolic syndrome"],
            originLanguage: "eng",
            originalWord: "metabolic syndrome",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "dakuon", "youon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),

        // Very long - stress test (13-14 chars)
        Word(
            id: "test-13char",
            word: "チャンピオンシップポイント",
            romaji: "cha-n-pi-o-n-shi-p-pu-po-i-n-to",
            meanings: ["championship point"],
            originLanguage: "eng",
            originalWord: "championship point",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "youon", "handakuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-14char",
            word: "ビデオアシスタントレフェリー",
            romaji: "bi-de-o-a-shi-su-ta-n-to-re-fe-ri-i",
            meanings: ["video assistant referee", "VAR"],
            originLanguage: "eng",
            originalWord: "video assistant referee",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "dakuon"],
            waseiEigo: nil,
            waseiInfo: nil
        ),

        // Extended katakana tests
        Word(
            id: "test-extended-ti",
            word: "ティラミス",
            romaji: "ti-ra-mi-su",
            meanings: ["tiramisu"],
            originLanguage: "ita",
            originalWord: "tiramisù",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "extended"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
        Word(
            id: "test-extended-fa",
            word: "ファッション",
            romaji: "fa-s-sho-n",
            meanings: ["fashion"],
            originLanguage: "eng",
            originalWord: "fashion",
            originalWordInferred: nil,
            categories: ["test"],
            parentCategory: parentCategory,
            patterns: ["gojuon", "youon", "extended"],
            waseiEigo: nil,
            waseiInfo: nil
        ),
    ]
}
#endif
