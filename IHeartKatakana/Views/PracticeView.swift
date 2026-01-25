import SwiftUI

// MARK: - Session State Persistence

private struct SessionState: Codable {
    let history: [Int]
    let shuffledDeck: [Int]
    let deckPosition: Int
    let currentPage: Int

    // Filter criteria when session was created (to detect changes)
    let contentType: String
    let patterns: [String]
    let selectedCategory: String?

    private static let key = "practiceSessionState"

    static func load() -> SessionState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SessionState.self, from: data)
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Self.key)
    }
}

struct PracticeView: View {
    let settings: PracticeSettings
    let contentService: ContentService
    let settingsVersion: Int
    let onExit: () -> Void

    @State private var isAnswerRevealed = false

    // History-based navigation (shuffled order, unlimited back)
    // Items are shown in random order without repeats until all have been seen
    @State private var history: [Int] = []
    @State private var currentPage: Int? = 0
    @State private var pendingNextIndex: Int? = nil

    // Shuffled deck: indices drawn in order, reshuffled when exhausted
    @State private var shuffledDeck: [Int] = []
    @State private var deckPosition: Int = 0

    // Cached filter criteria - only updates on refresh
    @State private var activeContentType: PracticeSettings.ContentType = .word
    @State private var activePatterns: [String] = ["gojuon"]
    @State private var activePeekHintType: PracticeSettings.PeekHintType = .romaji
    @State private var activeSelectedCategory: String? = nil

    // Cached filtered content - avoids recomputing on every access
    @State private var cachedFilteredWords: [Word] = []
    @State private var cachedFilteredKana: [Kana] = []

    // Pull to peek state
    @State private var peekDragOffset: CGFloat = 0
    @State private var isPeeking = false

    private let peekThreshold: CGFloat = 100

    var body: some View {
        // Capture safe area insets before ignoring them
        GeometryReader { outerGeometry in
            let safeInsets = outerGeometry.safeAreaInsets

            ZStack {
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(0..<pageCount, id: \.self) { pageIndex in
                                    cardView(for: itemForPage(pageIndex), pageIndex: pageIndex, safeAreaInsets: safeInsets)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(pageIndex)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $currentPage)
                        .onTapGesture {
                            isAnswerRevealed.toggle()
                        }
                        .onChange(of: currentPage) { oldValue, newValue in
                            if let newValue = newValue, let oldValue = oldValue {
                                handlePageChange(from: oldValue, to: newValue)
                            }
                        }
                        .onChange(of: geometry.size) { _, _ in
                            // Re-center on current page after orientation change
                            if let page = currentPage {
                                proxy.scrollTo(page, anchor: .center)
                            }
                        }
                        .simultaneousGesture(peekGesture)
                    }
                }
                .ignoresSafeArea()

                // Progress indicator (floating, fades out on end card)
                VStack {
                    Spacer()
                    Text("\(min((currentPage ?? 0) + 1, totalItems)) of \(totalItems)")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .safeAreaPadding()
                .opacity(isDeckExhausted && currentPage == history.count ? 0 : 1)
                .animation(.easeOut(duration: 0.3), value: currentPage)
            }
        }
        .onAppear {
            refreshFromSettings()
        }
        .onChange(of: settingsVersion) { _, _ in
            refreshFromSettings()
        }
        .onChange(of: contentService.isLoaded) { _, isLoaded in
            if isLoaded {
                refreshFromSettings()
            }
        }
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

        // Save session state after navigation
        saveSessionState()
    }

    private func generatePendingNext() {
        guard totalItems > 0 else {
            pendingNextIndex = nil
            return
        }

        // If deck is exhausted, don't generate next - show end card instead
        if deckPosition >= shuffledDeck.count {
            pendingNextIndex = nil
            return
        }

        pendingNextIndex = shuffledDeck[deckPosition]
        deckPosition += 1
    }

    private var isDeckExhausted: Bool {
        deckPosition >= shuffledDeck.count && pendingNextIndex == nil
    }

    private func restartSameOrder() {
        guard !shuffledDeck.isEmpty else { return }

        // Reset to beginning of same shuffled order
        deckPosition = 0
        history = []

        // Draw first item from same deck
        let firstIndex = shuffledDeck[deckPosition]
        deckPosition += 1
        history.append(firstIndex)
        currentPage = 0
        generatePendingNext()
        saveSessionState()
    }

    private func shuffleAndRestart() {
        guard totalItems > 0 else { return }

        reshuffleDeck()
        history = []

        // Draw first item from fresh deck
        let firstIndex = shuffledDeck[deckPosition]
        deckPosition += 1
        history.append(firstIndex)
        currentPage = 0
        generatePendingNext()
        saveSessionState()
    }

    private func reshuffleDeck() {
        shuffledDeck = Array(0..<totalItems).shuffled()
        deckPosition = 0
    }

    // MARK: - Card View

    @ViewBuilder
    private func cardView(for item: (question: String, answer: String)?, pageIndex: Int, safeAreaInsets: EdgeInsets) -> some View {
        if let item = item {
            ZStack {
                #if DEBUG
                // Stable background color based on page index for debugging card boundaries
                Color.gray.opacity(debugColorOpacity(for: pageIndex))
                #endif

                VStack(spacing: 16) {
                    // Peek hint area
                    peekHintView

                    // Question (the katakana)
                    Text(item.question)
                        .font(.system(size: 72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)

                    // Answer
                    Text(item.answer)
                        .font(.title)
                        .foregroundColor(.secondary)
                        .opacity(isAnswerRevealed ? 1 : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // 20px base padding, plus safe area insets for Dynamic Island
                .padding(.leading, 20 + safeAreaInsets.leading)
                .padding(.trailing, 20 + safeAreaInsets.trailing)
                .padding(.top, 20 + safeAreaInsets.top)
                .padding(.bottom, 20 + safeAreaInsets.bottom)
            }
        } else if isDeckExhausted && pageIndex == history.count {
            // End card - shown when all items have been seen
            endCardView(safeAreaInsets: safeAreaInsets)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func endCardView(safeAreaInsets: EdgeInsets) -> some View {
        ZStack {
            #if DEBUG
            Color.gray.opacity(0.15)
            #endif

            HStack(spacing: 40) {
                // Restart button - repeat same order
                Button {
                    restartSameOrder()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 32))
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial, in: Circle())
                }

                // Shuffle button - reshuffle and restart
                Button {
                    shuffleAndRestart()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 32))
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 20 + safeAreaInsets.leading)
            .padding(.trailing, 20 + safeAreaInsets.trailing)
            .padding(.top, 20 + safeAreaInsets.top)
            .padding(.bottom, 20 + safeAreaInsets.bottom)
        }
    }

    #if DEBUG
    /// Generate a stable opacity value based on page index
    private func debugColorOpacity(for pageIndex: Int) -> Double {
        let hash = abs(pageIndex.hashValue)
        return 0.1 + Double(hash % 20) / 100.0
    }
    #endif

    // MARK: - Peek Gesture

    private var peekGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let vertical = value.translation.height
                if vertical > 0 {
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
        let oldCategory = activeSelectedCategory

        activeContentType = settings.contentType
        activePatterns = settings.enabledPatterns
        activePeekHintType = settings.peekHintType
        activeSelectedCategory = settings.selectedCategory

        // Rebuild filtered caches when criteria change
        let filterCriteriaChanged = oldContentType != activeContentType
            || oldPatterns != activePatterns
            || oldCategory != activeSelectedCategory

        if filterCriteriaChanged || history.isEmpty {
            rebuildFilteredCache()

            // Try to restore saved session if filter criteria matches
            if let saved = SessionState.load(),
               saved.contentType == activeContentType.rawValue,
               Set(saved.patterns) == Set(activePatterns),
               saved.selectedCategory == activeSelectedCategory,
               !saved.history.isEmpty,
               saved.history.allSatisfy({ $0 < totalItems }),
               saved.shuffledDeck.count == totalItems {
                // Restore saved session
                history = saved.history
                shuffledDeck = saved.shuffledDeck
                deckPosition = saved.deckPosition
                currentPage = saved.currentPage
                generatePendingNext()
            } else {
                // Start fresh session
                resetHistory()
            }
        }
    }

    private func saveSessionState() {
        guard !history.isEmpty else { return }

        let state = SessionState(
            history: history,
            shuffledDeck: shuffledDeck,
            deckPosition: deckPosition,
            currentPage: currentPage ?? 0,
            contentType: activeContentType.rawValue,
            patterns: activePatterns,
            selectedCategory: activeSelectedCategory
        )
        state.save()
    }

    private func rebuildFilteredCache() {
        let enabledSet = Set(activePatterns)

        // Filter words by patterns and optionally by parent category
        cachedFilteredWords = contentService.words.filter { word in
            let matchesPattern = word.patterns.contains { enabledSet.contains($0) }
            let matchesCategory = activeSelectedCategory == nil
                || word.parentCategory == activeSelectedCategory
            return matchesPattern && matchesCategory
        }

        // Kana don't have categories, only filter by pattern
        cachedFilteredKana = contentService.kana.filter { kana in
            enabledSet.contains(kana.pattern)
        }
    }

    private func resetHistory() {
        history = []
        pendingNextIndex = nil
        isAnswerRevealed = false

        // Initialize shuffled deck and start fresh
        guard totalItems > 0 else { return }
        reshuffleDeck()

        // Draw first item from deck
        let firstIndex = shuffledDeck[deckPosition]
        deckPosition += 1
        history.append(firstIndex)
        currentPage = 0
        generatePendingNext()
        saveSessionState()
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
        guard let page = currentPage,
              page >= 0,
              page < history.count else { return nil }

        let index = history[page]

        switch activeContentType {
        case .word:
            guard index < filteredWords.count else { return nil }
            let word = filteredWords[index]
            switch activePeekHintType {
            case .romaji:
                return word.romaji
            case .originalWord:
                return word.originalWord ?? word.originalWordInferred
            }
        case .kana:
            guard index < filteredKana.count else { return nil }
            let kana = filteredKana[index]
            return kana.romaji
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
