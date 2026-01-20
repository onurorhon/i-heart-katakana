import Foundation

struct Kana: Codable, Identifiable {
    var id: String { kana }
    let kana: String
    let romaji: String
    let pattern: String
}
