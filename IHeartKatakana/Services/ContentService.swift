import Foundation

@Observable
class ContentService {
    private(set) var words: [Word] = []
    private(set) var kana: [Kana] = []
    private(set) var isLoaded = false
    private(set) var loadError: Error?

    func load() {
        guard !isLoaded else { return }

        do {
            words = try loadBundledJSON("words")
            kana = try loadBundledJSON("kana")
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
