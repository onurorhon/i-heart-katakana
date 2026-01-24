import Foundation

@MainActor
@Observable
class ContentService {
    private(set) var words: [Word] = []
    private(set) var kana: [Kana] = []
    private(set) var isLoaded = false
    private(set) var loadError: Error?

    var availableCategories: [String] {
        let allCategories = words.flatMap { $0.categories }
        return Array(Set(allCategories)).sorted()
    }

    var availableParentCategories: [String] {
        let parentCategories = words.map { $0.parentCategory }
        let unique = Array(Set(parentCategories)).sorted()

        #if DEBUG
        // Put Typography Test at the top for easy access during development
        if let testIndex = unique.firstIndex(of: "Typography Test") {
            var reordered = unique
            reordered.remove(at: testIndex)
            reordered.insert("Typography Test", at: 0)
            return reordered
        }
        return unique
        #else
        // Filter out test category in release builds (should never exist, but safety check)
        return unique.filter { $0 != "Typography Test" }
        #endif
    }

    func load() {
        guard !isLoaded else { return }

        do {
            words = try loadBundledJSON("words")
            kana = try loadBundledJSON("kana")

            #if DEBUG
            // Add typography test words for UI testing (never in release builds)
            words.append(contentsOf: TypographyTestData.words)
            #endif

            isLoaded = true
        } catch {
            loadError = error
        }
    }

    private func loadBundledJSON<T: Decodable>(_ name: String) throws -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw ContentError.fileNotFound(name)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([T].self, from: data)
    }
}

enum ContentError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Could not find \(name).json in app bundle"
        }
    }
}
