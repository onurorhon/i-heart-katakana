import Foundation
import SwiftUI

@MainActor
@Observable
class PracticeSettings {
    enum ContentType: String, CaseIterable {
        case word = "Word"
        case kana = "Kana"
    }

    enum PeekHintType: String, CaseIterable {
        case romaji = "Romaji"
        case originalWord = "Original Word"
        case playAudio = "Audio"
    }

    private let defaults = UserDefaults.standard

    var contentType: ContentType {
        didSet { defaults.set(contentType.rawValue, forKey: "contentType") }
    }

    var peekHintType: PeekHintType {
        didSet { defaults.set(peekHintType.rawValue, forKey: "peekHintType") }
    }

    // Level selections (phonetic patterns)
    var gojuonEnabled: Bool {
        didSet { defaults.set(gojuonEnabled, forKey: "gojuonEnabled") }
    }

    var dakuonEnabled: Bool {
        didSet { defaults.set(dakuonEnabled, forKey: "dakuonEnabled") }
    }

    var handakuonEnabled: Bool {
        didSet { defaults.set(handakuonEnabled, forKey: "handakuonEnabled") }
    }

    var youonEnabled: Bool {
        didSet { defaults.set(youonEnabled, forKey: "youonEnabled") }
    }

    var extendedEnabled: Bool {
        didSet { defaults.set(extendedEnabled, forKey: "extendedEnabled") }
    }

    var selectedCategory: String? {
        didSet { defaults.set(selectedCategory, forKey: "selectedCategory") }
    }

    var enabledPatterns: [String] {
        var patterns: [String] = []
        if gojuonEnabled { patterns.append("gojuon") }
        if dakuonEnabled { patterns.append("dakuon") }
        if handakuonEnabled { patterns.append("handakuon") }
        if youonEnabled { patterns.append("youon") }
        if extendedEnabled { patterns.append("extended") }
        return patterns
    }

    init() {
        // Load saved values or use defaults
        let savedContentType = defaults.string(forKey: "contentType") ?? ContentType.word.rawValue
        self.contentType = ContentType(rawValue: savedContentType) ?? .word

        let savedPeekHintType = defaults.string(forKey: "peekHintType") ?? PeekHintType.romaji.rawValue
        self.peekHintType = PeekHintType(rawValue: savedPeekHintType) ?? .romaji

        // For booleans, check if key exists to distinguish "never set" from "set to false"
        if defaults.object(forKey: "gojuonEnabled") != nil {
            self.gojuonEnabled = defaults.bool(forKey: "gojuonEnabled")
        } else {
            self.gojuonEnabled = true // Default: enabled
        }

        self.dakuonEnabled = defaults.bool(forKey: "dakuonEnabled")
        self.handakuonEnabled = defaults.bool(forKey: "handakuonEnabled")
        self.youonEnabled = defaults.bool(forKey: "youonEnabled")
        self.extendedEnabled = defaults.bool(forKey: "extendedEnabled")

        self.selectedCategory = defaults.string(forKey: "selectedCategory")
    }
}
