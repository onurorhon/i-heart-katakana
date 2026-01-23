import Foundation

struct Word: Codable, Identifiable {
    let id: String
    let word: String
    let romaji: String
    let meanings: [String]
    let originLanguage: String?
    let originalWord: String?          // From JMdict (authoritative)
    let originalWordInferred: String?  // Our inference (first meaning for English)
    let categories: [String]
    let parentCategory: String         // Broad category for filtering (e.g., "Everyday Life")
    let patterns: [String]

    // Wasei-eigo fields (optional, from curated database)
    let waseiEigo: Bool?
    let waseiInfo: WaseiInfo?

    enum CodingKeys: String, CodingKey {
        case id, word, romaji, meanings, originLanguage, originalWord, originalWordInferred
        case categories, parentCategory, patterns
        case waseiEigo = "wasei_eigo"
        case waseiInfo = "wasei_info"
    }
}

struct WaseiInfo: Codable {
    let englishEquivalent: String
    let waseiMeaning: String
    let notes: String

    enum CodingKeys: String, CodingKey {
        case englishEquivalent = "english_equivalent"
        case waseiMeaning = "wasei_meaning"
        case notes
    }
}

