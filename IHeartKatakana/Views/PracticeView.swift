import SwiftUI

struct PracticeView: View {
    let settings: PracticeSettings
    let contentService: ContentService
    let settingsVersion: Int
    let onExit: () -> Void

    @State private var isAnswerRevealed = false

    // History-based navigation (random order, unlimited back)
    @State private var history: [Int] = []
    @State private var currentPage: Int? = 0
    @State private var pendingNextIndex: Int? = nil

    // Cached filter criteria - only updates on refresh
    @State private var activeContentType: PracticeSettings.ContentType = .word
    @State private var activePatterns: [String] = ["gojuon"]
    @State private var activePeekHintType: PracticeSettings.PeekHintType = .romaji

    // Cached filtered content - avoids recomputing on every access
    @State private var cachedFilteredWords: [Word] = []
    @State private var cachedFilteredKana: [Kana] = []

    // Pull to peek state
    @State private var peekDragOffset: CGFloat = 0
    @State private var isPeeking = false

    private let peekThreshold: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width

            VStack(spacing: 32) {
                // Paging ScrollView carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<pageCount, id: \.self) { pageIndex in
                            cardView(for: itemForPage(pageIndex))
                                .frame(width: screenWidth)
                                .id(pageIndex)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentPage)
                .frame(maxHeight: .infinity)
                .onTapGesture {
                    isAnswerRevealed.toggle()
                }
                .onChange(of: currentPage) { oldValue, newValue in
                    if let newValue = newValue {
                        handlePageChange(from: oldValue ?? 0, to: newValue)
                    }
                }

                // Progress indicator
                Text("\((currentPage ?? 0) + 1) seen")
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
        .onAppear {
            refreshFromSettings()
        }
        .onChange(of: settingsVersion) { _, _ in
            refreshFromSettings()
        }
        .simultaneousGesture(peekGesture)
    }

    // MARK: - Page Management

    private var pageCount: Int {
        // Always have one more page available for "next"
        max(history.count + 1, 1)
    }

    private func itemForPage(_ page: Int) -> (question: String, answer: String)? {
        if page < history.count {
            return itemAt(index: history[page])
        }
        // This is the "next" page - use pre-generated pending index
        if page == history.count, let pending = pendingNextIndex {
            return itemAt(index: pending)
        }
        return nil
    }

    private func handlePageChange(from oldValue: Int, to newValue: Int) {
        isAnswerRevealed = false

        // If swiped forward past current history, commit pending and generate new
        if newValue >= history.count, let pending = pendingNextIndex {
            history.append(pending)
            generatePendingNext()
        }
    }

    private func generatePendingNext() {
        guard totalItems > 0 else {
            pendingNextIndex = nil
            return
        }
        pendingNextIndex = Int.random(in: 0..<totalItems)
    }

    // MARK: - Card View

    @ViewBuilder
    private func cardView(for item: (question: String, answer: String)?) -> some View {
        if let item = item {
            VStack(spacing: 16) {
                // Peek hint area (words only)
                if activeContentType == .word {
                    peekHintView
                }

                // Question (the katakana)
                Text(item.question)
                    .font(.system(size: 72))

                // Answer
                Text(item.answer)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .opacity(isAnswerRevealed ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Color.clear
        }
    }

    // MARK: - Peek Gesture

    private var peekGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let vertical = value.translation.height
                if vertical > 0 && activeContentType == .word {
                    isPeeking = true
                    peekDragOffset = vertical
                }
            }
            .onEnded { _ in
                if isPeeking {
                    withAnimation(.easeOut(duration: 0.3)) {
                        peekDragOffset = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPeeking = false
                    }
                }
            }
    }

    // MARK: - Refresh

    func refreshFromSettings() {
        let oldContentType = activeContentType
        let oldPatterns = activePatterns

        activeContentType = settings.contentType
        activePatterns = settings.enabledPatterns
        activePeekHintType = settings.peekHintType

        // Rebuild filtered caches when criteria change
        if oldContentType != activeContentType || oldPatterns != activePatterns || history.isEmpty {
            rebuildFilteredCache()
            resetHistory()
        }
    }

    private func rebuildFilteredCache() {
        let enabledSet = Set(activePatterns)
        cachedFilteredWords = contentService.words.filter { word in
            word.patterns.contains { enabledSet.contains($0) }
        }
        cachedFilteredKana = contentService.kana.filter { kana in
            enabledSet.contains(kana.pattern)
        }
    }

    private func resetHistory() {
        history = []
        pendingNextIndex = nil
        isAnswerRevealed = false

        // Start with first random item
        guard totalItems > 0 else { return }
        let firstIndex = Int.random(in: 0..<totalItems)
        history.append(firstIndex)
        currentPage = 0
        generatePendingNext()
    }

    // MARK: - Peek Hint View

    @ViewBuilder
    private var peekHintView: some View {
        let hintText = currentPeekHint ?? "—"
        let revealProgress = min(1.0, max(0.0, peekDragOffset / peekThreshold))
        let promptOpacity = max(0.0, 1.0 - (revealProgress * 4.0))

        ZStack {
            Text("Pull down to peek")
                .font(.title2)
                .foregroundColor(.secondary)
                .opacity(promptOpacity)

            LetterRevealText(text: hintText, revealProgress: revealProgress)
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(height: 34)
    }

    private var currentPeekHint: String? {
        guard activeContentType == .word,
              let page = currentPage,
              page >= 0,
              page < history.count else { return nil }

        let index = history[page]
        guard index < filteredWords.count else { return nil }
        let word = filteredWords[index]

        switch activePeekHintType {
        case .romaji:
            return word.romaji
        case .originalWord:
            return word.originalWord ?? word.originalWordInferred
        }
    }

    // MARK: - Data

    private func itemAt(index: Int) -> (question: String, answer: String)? {
        switch activeContentType {
        case .word:
            guard index < filteredWords.count else { return nil }
            let word = filteredWords[index]
            return (word.word, word.meanings.joined(separator: ", "))
        case .kana:
            guard index < filteredKana.count else { return nil }
            let kana = filteredKana[index]
            return (kana.kana, kana.romaji)
        }
    }

    private var filteredWords: [Word] {
        cachedFilteredWords
    }

    private var filteredKana: [Kana] {
        cachedFilteredKana
    }

    private var totalItems: Int {
        activeContentType == .word ? cachedFilteredWords.count : cachedFilteredKana.count
    }
}

// MARK: - Letter Reveal Text

struct LetterRevealText: View {
    let text: String
    let revealProgress: Double

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .opacity(characterOpacity(at: index))
            }
        }
    }

    private func characterOpacity(at index: Int) -> Double {
        let charCount = Double(text.count)
        guard charCount > 0 else { return 0 }

        let charPosition = Double(index) / charCount
        let revealWindow = 0.3

        let startReveal = charPosition * (1.0 - revealWindow)
        let endReveal = startReveal + revealWindow

        if revealProgress <= startReveal {
            return 0
        } else if revealProgress >= endReveal {
            return 1
        } else {
            return (revealProgress - startReveal) / revealWindow
        }
    }
}

#Preview {
    PracticeView(
        settings: PracticeSettings(),
        contentService: ContentService(),
        settingsVersion: 0,
        onExit: {}
    )
}
