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

// MARK: - Card Data

private struct CardData {
    let question: String      // The katakana word/character
    let romaji: String
    let meaning: String
    let originalWord: String? // Only for words, not kana
    let originLanguage: String? // Language code (e.g., "eng", "gre", "por")
    let isWaseiEigo: Bool
}

struct PracticeView: View {
    let settings: PracticeSettings
    let contentService: ContentService
    let ttsService: TTSService
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
    @State private var hasTriggeredPeekAudio = false
    @AppStorage("hasUsedPullHint") private var hasUsedPullHint = false

    // Voice hint alert
    @State private var showVoiceHintAlert = false
    @State private var pendingTTSText: String? = nil

    // Theme cycling
    @State private var currentThemeIndex: Int? = 0
    private let themeColors: [Color] = [
        Color(red: 1.0, green: 0.98, blue: 0.9),   // Pale yellow
        Color(red: 1.0, green: 0.92, blue: 0.93),  // Pale pink
        Color(red: 0.95, green: 0.92, blue: 1.0),  // Pale purple
        Color(red: 0.92, green: 1.0, blue: 0.94),  // Pale green
        Color(red: 0.92, green: 0.96, blue: 1.0),  // Pale blue
    ]

    private let peekThreshold: CGFloat = 150

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
                                    cardView(for: itemForPage(pageIndex), pageIndex: pageIndex, themeIndex: currentThemeIndex ?? 0, safeAreaInsets: safeInsets)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(pageIndex)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $currentPage)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isAnswerRevealed.toggle()
                            }
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
                        .simultaneousGesture(themeCycleGesture)
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
                .opacity(isAnswerRevealed || (isDeckExhausted && currentPage == history.count) ? 0 : 1)
                .animation(.easeOut(duration: 0.3), value: isAnswerRevealed)
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
        .alert("Better Voice Quality", isPresented: $showVoiceHintAlert) {
            Button("Got it") {
                ttsService.markVoiceHintShown()
                if let text = pendingTTSText {
                    ttsService.speak(text)
                    pendingTTSText = nil
                }
            }
        } message: {
            Text("For clearer pronunciation, download an enhanced Japanese voice.\n\nOpen Settings, search for \"Japanese\" under Accessibility, and look for voices marked \"Enhanced\".")
        }
    }

    // MARK: - Page Management

    private var pageCount: Int {
        // Always have one more page available for "next"
        max(history.count + 1, 1)
    }

    private func itemForPage(_ page: Int) -> CardData? {
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
    private func cardView(for item: CardData?, pageIndex: Int, themeIndex: Int, safeAreaInsets: EdgeInsets) -> some View {
        if let item = item {
            // Only show revealed content on the current page
            let showRevealed = isAnswerRevealed && pageIndex == currentPage

            ZStack {
                // Theme background
                themeColors[themeIndex]

                // Subtle overlay on odd cards for visual separation
                if pageIndex % 2 == 1 {
                    Color.gray.opacity(0.05)
                }

                VStack(spacing: 16) {
                    // Peek hint area (fades out when answer revealed, only active on current page)
                    peekHintView(isCurrentPage: pageIndex == currentPage)
                        .opacity(showRevealed ? 0 : 1)

                    // Question (the katakana)
                    Text(item.question)
                        .font(.system(size: 72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)

                    // Action buttons (appear on reveal)
                    HStack(spacing: 32) {
                        Button {
                            if ttsService.shouldShowVoiceHint {
                                pendingTTSText = item.question
                                showVoiceHintAlert = true
                            } else {
                                ttsService.speak(item.question)
                            }
                        } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.title2)
                        }

                        Button {
                            // TODO: Toggle like
                        } label: {
                            Image(systemName: "heart")
                                .font(.title2)
                        }

                        Button {
                            // TODO: Bookmark
                        } label: {
                            Image(systemName: "bookmark")
                                .font(.title2)
                        }
                    }
                    .opacity(showRevealed ? 1 : 0)

                    // Answer details (appear on reveal)
                    VStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .center, spacing: 2) {
                            Text("Romaji")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                            Text(item.romaji.replacingOccurrences(of: "-", with: ""))
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }

                        if let originalWord = item.originalWord {
                            VStack(alignment: .center, spacing: 2) {
                                Text("Original Word")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                Text(originalWordDisplay(originalWord, lang: item.originLanguage, isWaseiEigo: item.isWaseiEigo))
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(alignment: .center, spacing: 2) {
                            Text("Meaning")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                            Text(item.meaning)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .opacity(showRevealed ? 1 : 0)
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
            endCardView(themeIndex: themeIndex, safeAreaInsets: safeAreaInsets)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func endCardView(themeIndex: Int, safeAreaInsets: EdgeInsets) -> some View {
        ZStack {
            // Theme background
            themeColors[themeIndex]

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

    // MARK: - Peek Gesture

    private var peekGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let vertical = value.translation.height
                let horizontal = abs(value.translation.width)

                // Only activate peek if pulling more down than sideways
                if vertical > 0 && vertical > horizontal {
                    isPeeking = true
                    peekDragOffset = vertical

                    // Mark pull hint as used once threshold is reached
                    if !hasUsedPullHint && vertical >= peekThreshold {
                        hasUsedPullHint = true
                    }

                    // Trigger audio when threshold is reached (only once per pull)
                    if activePeekHintType == .playAudio && !hasTriggeredPeekAudio && vertical >= peekThreshold {
                        hasTriggeredPeekAudio = true
                        if let question = currentQuestion {
                            ttsService.speak(question)
                        }
                    }
                } else if horizontal > vertical {
                    // Horizontal swipe - reset peek state
                    peekDragOffset = 0
                }
            }
            .onEnded { _ in
                if isPeeking {
                    withAnimation(.easeOut(duration: 0.3)) {
                        peekDragOffset = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPeeking = false
                        hasTriggeredPeekAudio = false
                    }
                }
            }
    }

    // MARK: - Theme Cycle Gesture

    private var themeCycleGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                let vertical = value.translation.height
                let horizontal = abs(value.translation.width)

                // Only cycle theme if swiping more up than sideways
                if vertical < -50 && abs(vertical) > horizontal {
                    // Swipe up - next theme
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentThemeIndex = ((currentThemeIndex ?? 0) + 1) % themeColors.count
                    }
                } else if vertical > 50 && vertical > horizontal && !isPeeking {
                    // Swipe down (when not peeking) - previous theme
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentThemeIndex = ((currentThemeIndex ?? 0) - 1 + themeColors.count) % themeColors.count
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
    private func peekHintView(isCurrentPage: Bool) -> some View {
        // Only show animated content on current page to avoid artifacts during swipe
        let revealProgress = isCurrentPage ? min(1.0, max(0.0, peekDragOffset / peekThreshold)) : 0
        let promptOpacity = max(0.0, 1.0 - (revealProgress * 4.0))

        ZStack {
            if !hasUsedPullHint && isCurrentPage {
                Text("Pull down for hint")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .opacity(promptOpacity)
            }

            if activePeekHintType == .playAudio {
                Image(systemName: "speaker.wave.2")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .opacity(revealProgress)
            } else {
                let hintText = currentPeekHint ?? "—"
                LetterRevealText(text: hintText, revealProgress: revealProgress)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 34)
    }

    private var currentPeekHint: String? {
        guard let page = currentPage,
              page >= 0,
              page < history.count else { return nil }

        let index = history[page]

        // Audio mode doesn't show text
        if activePeekHintType == .playAudio {
            return nil
        }

        switch activeContentType {
        case .word:
            guard index < filteredWords.count else { return nil }
            let word = filteredWords[index]
            switch activePeekHintType {
            case .romaji:
                return word.romaji
            case .originalWord:
                return word.originalWord ?? word.originalWordInferred
            case .playAudio:
                return nil
            }
        case .kana:
            guard index < filteredKana.count else { return nil }
            let kana = filteredKana[index]
            return kana.romaji
        }
    }

    private var currentQuestion: String? {
        guard let page = currentPage,
              page >= 0,
              page < history.count else { return nil }

        let index = history[page]

        switch activeContentType {
        case .word:
            guard index < filteredWords.count else { return nil }
            return filteredWords[index].word
        case .kana:
            guard index < filteredKana.count else { return nil }
            return filteredKana[index].kana
        }
    }

    // MARK: - Data

    private func itemAt(index: Int) -> CardData? {
        switch activeContentType {
        case .word:
            guard index < filteredWords.count else { return nil }
            let word = filteredWords[index]
            return CardData(
                question: word.word,
                romaji: word.romaji,
                meaning: word.meanings.joined(separator: ", "),
                originalWord: word.originalWord ?? word.originalWordInferred,
                originLanguage: word.originLanguage,
                isWaseiEigo: word.waseiEigo ?? false
            )
        case .kana:
            guard index < filteredKana.count else { return nil }
            let kana = filteredKana[index]
            return CardData(
                question: kana.kana,
                romaji: kana.romaji,
                meaning: kana.romaji, // For kana, meaning is just the romaji
                originalWord: nil,
                originLanguage: nil,
                isWaseiEigo: false
            )
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

// MARK: - Original Word Display

private func originalWordDisplay(_ word: String, lang: String?, isWaseiEigo: Bool) -> String {
    var suffixes: [String] = []

    // Add language suffix for non-English origins
    if let lang = lang, lang != "eng" {
        suffixes.append(languageDisplayName(for: lang))
    }

    // Add wasei-eigo suffix
    if isWaseiEigo {
        suffixes.append("wasei-eigo")
    }

    if suffixes.isEmpty {
        return word
    } else {
        return "\(word) (\(suffixes.joined(separator: ", ")))"
    }
}

// MARK: - Language Display Names

private func languageDisplayName(for code: String) -> String {
    switch code {
    case "eng": return "English"
    case "por": return "Portuguese"
    case "ger": return "German"
    case "fre": return "French"
    case "ita": return "Italian"
    case "spa": return "Spanish"
    case "dut": return "Dutch"
    case "rus": return "Russian"
    case "lat": return "Latin"
    case "grc", "gre": return "Greek"
    case "ara": return "Arabic"
    case "kor": return "Korean"
    case "chi", "chn": return "Chinese"
    case "hin": return "Hindi"
    case "may": return "Malay"
    case "ind": return "Indonesian"
    case "ain": return "Ainu"
    case "san": return "Sanskrit"
    case "haw": return "Hawaiian"
    case "tur": return "Turkish"
    case "tha": return "Thai"
    case "vie": return "Vietnamese"
    case "ukr": return "Ukrainian"
    case "lit": return "Lithuanian"
    case "urd": return "Urdu"
    case "tib": return "Tibetan"
    case "tam": return "Tamil"
    case "swe": return "Swedish"
    case "pol": return "Polish"
    case "mal": return "Malayalam"
    case "hun": return "Hungarian"
    case "fin": return "Finnish"
    case "bre": return "Breton"
    default: return code.uppercased()
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
        ttsService: TTSService(),
        settingsVersion: 0,
        onExit: {}
    )
}
