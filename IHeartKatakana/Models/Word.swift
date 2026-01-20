import Foundation

struct Word: Codable, Identifiable {
    let id: String
    let reading: String
    let romaji: String
    let meanings: [String]
    let sourceLanguage: String?
    let sourceWord: String?
    let categories: [String]
    let patterns: [String]

    // Wasei-eigo fields (optional)
    let waseiEigo: Bool?
    let waseiInfo: WaseiInfo?
    let waseiCandidate: Bool?
    let waseiFlags: [WaseiFlag]?

    enum CodingKeys: String, CodingKey {
        case id, reading, romaji, meanings, sourceLanguage, sourceWord, categories, patterns
        case waseiEigo = "wasei_eigo"
        case waseiInfo = "wasei_info"
        case waseiCandidate = "wasei_candidate"
        case waseiFlags = "wasei_flags"
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

struct WaseiFlag: Codable {
    let type: String
    let detail: String
}
