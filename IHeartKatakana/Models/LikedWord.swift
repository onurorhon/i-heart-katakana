import Foundation
import SwiftData

@Model
class LikedWord {
    var wordId: String
    var likedAt: Date

    init(wordId: String, likedAt: Date = .now) {
        self.wordId = wordId
        self.likedAt = likedAt
    }
}
