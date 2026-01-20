import Foundation

@Observable
class PracticeSettings {
    enum ContentType: String, CaseIterable {
        case word = "Word"
        case kana = "Kana"
    }

    var contentType: ContentType = .word

    // Level selections (phonetic patterns)
    var gojuonEnabled = true
    var dakuonEnabled = false
    var handakuonEnabled = false
    var youonEnabled = false
    var extendedEnabled = false

    var selectedCategory: String? = nil

    var enabledPatterns: [String] {
        var patterns: [String] = []
        if gojuonEnabled { patterns.append("gojuon") }
        if dakuonEnabled { patterns.append("dakuon") }
        if handakuonEnabled { patterns.append("handakuon") }
        if youonEnabled { patterns.append("youon") }
        if extendedEnabled { patterns.append("extended") }
        return patterns
    }
}
