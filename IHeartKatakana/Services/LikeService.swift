import Foundation
import SwiftData

@MainActor
@Observable
class LikeService {
    private let modelContext: ModelContext
    private(set) var likedWordIds: Set<String> = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadLikedIds()
    }

    func isLiked(_ wordId: String) -> Bool {
        likedWordIds.contains(wordId)
    }

    func toggleLike(wordId: String) {
        if isLiked(wordId) {
            unlike(wordId: wordId)
        } else {
            like(wordId: wordId)
        }
    }

    func loadLikedIds() {
        let descriptor = FetchDescriptor<LikedWord>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        likedWordIds = Set(all.map(\.wordId))
    }

    private func like(wordId: String) {
        let liked = LikedWord(wordId: wordId)
        modelContext.insert(liked)
        try? modelContext.save()
        likedWordIds.insert(wordId)
    }

    private func unlike(wordId: String) {
        let descriptor = FetchDescriptor<LikedWord>(
            predicate: #Predicate { $0.wordId == wordId }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try? modelContext.save()
        }
        likedWordIds.remove(wordId)
    }
}
