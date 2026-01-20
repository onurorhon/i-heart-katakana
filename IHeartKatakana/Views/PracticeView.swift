import SwiftUI

struct PracticeView: View {
    let settings: PracticeSettings
    let contentService: ContentService
    let onExit: () -> Void

    @State private var currentIndex = 0
    @State private var isAnswerRevealed = false

    var body: some View {
        VStack(spacing: 32) {
            // Current item display
            if let currentItem = currentItem {
                VStack(spacing: 16) {
                    // Question (the katakana)
                    Text(currentItem.question)
                        .font(.system(size: 72))

                    // Answer (revealed on tap)
                    if isAnswerRevealed {
                        Text(currentItem.answer)
                            .font(.title)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap to reveal")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isAnswerRevealed {
                        nextItem()
                    } else {
                        isAnswerRevealed = true
                    }
                }
            } else {
                Text("No content available")
                    .foregroundColor(.secondary)
            }

            // Navigation
            HStack(spacing: 32) {
                Button("Previous") {
                    previousItem()
                }
                .disabled(currentIndex == 0)

                Text("\(currentIndex + 1) / \(totalItems)")
                    .foregroundColor(.secondary)

                Button("Next") {
                    nextItem()
                }
                .disabled(currentIndex >= totalItems - 1)
            }
        }
        .padding()
    }

    // MARK: - Computed Properties

    private var filteredWords: [Word] {
        let enabledSet = Set(settings.enabledPatterns)
        return contentService.words.filter { word in
            // Show words that contain ANY of the enabled patterns
            !Set(word.patterns).isDisjoint(with: enabledSet)
        }
    }

    private var filteredKana: [Kana] {
        contentService.kana.filter { kana in
            settings.enabledPatterns.contains(kana.pattern)
        }
    }

    private var totalItems: Int {
        settings.contentType == .word ? filteredWords.count : filteredKana.count
    }

    private var currentItem: (question: String, answer: String)? {
        switch settings.contentType {
        case .word:
            guard currentIndex < filteredWords.count else { return nil }
            let word = filteredWords[currentIndex]
            return (word.word, word.meanings.joined(separator: ", "))
        case .kana:
            guard currentIndex < filteredKana.count else { return nil }
            let kana = filteredKana[currentIndex]
            return (kana.kana, kana.romaji)
        }
    }

    // MARK: - Actions

    private func nextItem() {
        if currentIndex < totalItems - 1 {
            currentIndex += 1
            isAnswerRevealed = false
        }
    }

    private func previousItem() {
        if currentIndex > 0 {
            currentIndex -= 1
            isAnswerRevealed = false
        }
    }
}

#Preview {
    PracticeView(
        settings: PracticeSettings(),
        contentService: ContentService(),
        onExit: {}
    )
}
