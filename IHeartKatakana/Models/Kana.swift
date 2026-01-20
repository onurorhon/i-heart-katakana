import Foundation

struct Kana: Codable, Identifiable {
    var id: String { character }
    let character: String
    let romaji: String
    let pattern: String
}
