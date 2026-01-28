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

    // Theme colors
    @Environment(\.colorScheme) private var colorScheme
    @State private var shuffledThemeOrder: [Int] = []

    private struct Theme {
        let lightBackground: Color
        let lightForeground: Color
        // Dark mode swaps: bg becomes fg, fg becomes bg
        var darkBackground: Color { lightForeground }
        var darkForeground: Color { lightBackground }
    }

    // Order: Pink, Blue, Green, Yellow, Purple
    private let themes: [Theme] = [
        Theme(lightBackground: Color(red: 1.0, green: 0.92, blue: 0.93),
              lightForeground: Color(red: 0.7, green: 0.2, blue: 0.3)),   // Pink
        Theme(lightBackground: Color(red: 0.92, green: 0.96, blue: 1.0),
              lightForeground: Color(red: 0.2, green: 0.4, blue: 0.6)),   // Blue
        Theme(lightBackground: Color(red: 0.92, green: 1.0, blue: 0.94),
              lightForeground: Color(red: 0.2, green: 0.5, blue: 0.3)),   // Green
        Theme(lightBackground: Color(red: 1.0, green: 0.98, blue: 0.9),
              lightForeground: Color(red: 0.6, green: 0.5, blue: 0.2)),   // Yellow
        Theme(lightBackground: Color(red: 0.95, green: 0.92, blue: 1.0),
              lightForeground: Color(red: 0.4, green: 0.3, blue: 0.6)),   // Purple
    ]

    private func themeIndex(for pageIndex: Int) -> Int {
        if settings.randomizeTheme && !shuffledThemeOrder.isEmpty {
            // Cycle through shuffled enabled themes
            return shuffledThemeOrder[pageIndex % shuffledThemeOrder.count]
        } else {
            // Single selected theme
            return settings.selectedThemeIndex
        }
    }

    private func backgroundColor(for pageIndex: Int) -> Color {
        let theme = themes[themeIndex(for: pageIndex)]
        return colorScheme == .dark ? theme.darkBackground : theme.lightBackground
    }

    private func foregroundColor(for pageIndex: Int) -> Color {
        let theme = themes[themeIndex(for: pageIndex)]
        return colorScheme == .dark ? theme.darkForeground : theme.lightForeground
    }

    private func reshuffleThemeOrder() {
        shuffledThemeOrder = Array(settings.enabledThemeIndices).shuffled()
    }

    private let peekThreshold: CGFloat = 150

    // MARK: - Layout Calculations

    /// Content top percentage: 40% portrait, 20% landscape
    private func contentTopPercent(for screenSize: CGSize) -> CGFloat {
        screenSize.height > screenSize.width ? 0.40 : 0.20
    }

    /// Katakana position for card layer (ignores safe area, so we add safeAreaTop)
    private func katakanaTopOffset(screenSize: CGSize, safeAreaTop: CGFloat) -> CGFloat {
        screenSize.height * contentTopPercent(for: screenSize) + safeAreaTop
    }

    /// Hint position for overlay layer (respects safe area, so no safeAreaTop)
    private func hintTopOffset(screenSize: CGSize) -> CGFloat {
        screenSize.height * contentTopPercent(for: screenSize) - 50
    }

    /// Reveal overlay position (respects safe area, so no safeAreaTop)
    private func revealOverlayTopOffset(screenSize: CGSize) -> CGFloat {
        screenSize.height * contentTopPercent(for: screenSize)
    }

    /// Gap between katakana and buttons: 100pt portrait, 80pt landscape
    private func katakanaToButtonsGap(for screenSize: CGSize) -> CGFloat {
        screenSize.height > screenSize.width ? 100 : 80
    }

    var body: some View {
        // Capture safe area insets before ignoring them
        GeometryReader { outerGeometry in
            let safeInsets = outerGeometry.safeAreaInsets
            let screenSize = outerGeometry.size

            ZStack {
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(0..<pageCount, id: \.self) { pageIndex in
                                    cardView(for: itemForPage(pageIndex), pageIndex: pageIndex, safeAreaInsets: safeInsets, screenSize: screenSize)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(pageIndex)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $currentPage)
                        .onTapGesture {
                            // Don't toggle on end card (no content to reveal)
                            guard !(isDeckExhausted && currentPage == history.count) else { return }
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
                    }
                }
                .ignoresSafeArea()

                // Peek hint overlay (single instance, above cards)
                peekHintOverlay(safeAreaInsets: safeInsets, screenSize: screenSize)
                    .opacity(isAnswerRevealed ? 0 : 1)
                    .animation(.easeOut(duration: 0.3), value: isAnswerRevealed)

                // Answer reveal overlay (single instance, above cards)
                cardRevealOverlay(safeAreaInsets: safeInsets, screenSize: screenSize)
                    .opacity(isAnswerRevealed ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isAnswerRevealed)

                // End card buttons overlay (single instance, above cards)
                endCardButtonsOverlay(screenSize: screenSize)
            }

            // Progress indicator (anchored to bottom of screen)
            Text("\(min((currentPage ?? 0) + 1, totalItems)) of \(totalItems)")
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .position(x: screenSize.width / 2, y: screenSize.height - 30)
                .opacity((isDeckExhausted && currentPage == history.count) ? 0 : 1)
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
        .onChange(of: settings.enabledThemeIndices) { _, _ in
            reshuffleThemeOrder()
        }
        .onChange(of: settings.randomizeTheme) { _, _ in
            reshuffleThemeOrder()
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
        reshuffleThemeOrder()
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
    private func cardView(for item: CardData?, pageIndex: Int, safeAreaInsets: EdgeInsets, screenSize: CGSize) -> some View {
        if let item = item {
            ZStack {
                // Theme background
                backgroundColor(for: pageIndex)

                // Subtle overlay on even cards for visual separation
                if pageIndex % 2 == 0 {
                    Color.black.opacity(colorScheme == .dark ? 0.06 : 0.035)
                }

                VStack(spacing: 16) {
                    // Question (the katakana) - top aligned at percentage-based position
                    Text(item.question)
                        .font(.system(size: 72))
                        .foregroundColor(foregroundColor(for: pageIndex))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)

                    // Space for action buttons and answer (rendered as overlay when revealed)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.leading, 20 + safeAreaInsets.leading)
                .padding(.trailing, 20 + safeAreaInsets.trailing)
                .padding(.top, katakanaTopOffset(screenSize: screenSize, safeAreaTop: safeAreaInsets.top))
                .padding(.bottom, 20 + safeAreaInsets.bottom)
            }
        } else if isDeckExhausted && pageIndex == history.count {
            endCardView(pageIndex: pageIndex, safeAreaInsets: safeAreaInsets, screenSize: screenSize)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func endCardView(pageIndex: Int, safeAreaInsets: EdgeInsets, screenSize: CGSize) -> some View {
        // Empty card - just background, buttons are rendered as overlay
        ZStack {
            backgroundColor(for: pageIndex)

            if pageIndex % 2 == 0 {
                Color.black.opacity(colorScheme == .dark ? 0.06 : 0.035)
            }
        }
    }

    // MARK: - End Card Buttons Overlay

    @ViewBuilder
    private func endCardButtonsOverlay(screenSize: CGSize) -> some View {
        if isDeckExhausted, let page = currentPage, page == history.count {
            HStack(spacing: 40) {
                Button {
                    restartSameOrder()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 32))
                        .foregroundColor(foregroundColor(for: page))
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial, in: Circle())
                }

                Button {
                    shuffleAndRestart()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 32))
                        .foregroundColor(foregroundColor(for: page))
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
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
                reshuffleThemeOrder()
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
        reshuffleThemeOrder()

        // Draw first item from deck
        let firstIndex = shuffledDeck[deckPosition]
        deckPosition += 1
        history.append(firstIndex)
        currentPage = 0
        generatePendingNext()
        saveSessionState()
    }

    // MARK: - Peek Hint Overlay

    @ViewBuilder
    private func peekHintOverlay(safeAreaInsets: EdgeInsets, screenSize: CGSize) -> some View {
        let revealProgress = min(1.0, max(0.0, peekDragOffset / peekThreshold))
        let promptOpacity = max(0.0, 1.0 - (revealProgress * 4.0))

        VStack {
            ZStack {
                if !hasUsedPullHint {
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

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading, 20 + safeAreaInsets.leading)
        .padding(.trailing, 20 + safeAreaInsets.trailing)
        .padding(.top, hintTopOffset(screenSize: screenSize))
        .allowsHitTesting(false)
    }

    // MARK: - Card Reveal Overlay

    @ViewBuilder
    private func cardRevealOverlay(safeAreaInsets: EdgeInsets, screenSize: CGSize) -> some View {
        // Always render stable frame structure to avoid layout shifts during scroll
        let page = currentPage ?? 0
        let item = itemForPage(page)
        let fgColor = foregroundColor(for: page)

        VStack(spacing: 16) {
            // Reserve space for katakana text
            Spacer().frame(height: katakanaToButtonsGap(for: screenSize))

            // Action buttons (interactive, but only when visible)
            HStack(spacing: 20) {
                Button {
                    if let item = item {
                        if ttsService.shouldShowVoiceHint {
                            pendingTTSText = item.question
                            showVoiceHintAlert = true
                        } else {
                            ttsService.speak(item.question)
                        }
                    }
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.title2)
                        .foregroundColor(fgColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }

                Button {
                    // TODO: Toggle like
                } label: {
                    Image(systemName: "heart")
                        .font(.title2)
                        .foregroundColor(fgColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }

                Button {
                    // TODO: Bookmark
                } label: {
                    Image(systemName: "bookmark")
                        .font(.title2)
                        .foregroundColor(fgColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            .opacity(item != nil ? 1 : 0)

            // Answer details (non-interactive, allow swipe through)
            VStack(alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 2) {
                    Text("Romaji")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                    Text(item?.romaji.replacingOccurrences(of: "-", with: "") ?? " ")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                // Original Word and Meaning only shown in word mode
                if activeContentType == .word {
                    VStack(alignment: .center, spacing: 2) {
                        Text("Original Word")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        Text(item.flatMap { originalWordDisplayOptional($0.originalWord, lang: $0.originLanguage, isWaseiEigo: $0.isWaseiEigo) } ?? " ")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .center, spacing: 2) {
                        Text("Meaning")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        Text(item?.meaning ?? " ")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .opacity(item != nil ? 1 : 0)
            .allowsHitTesting(false)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading, 20 + safeAreaInsets.leading)
        .padding(.trailing, 20 + safeAreaInsets.trailing)
        .padding(.top, revealOverlayTopOffset(screenSize: screenSize))
        .padding(.bottom, 20 + safeAreaInsets.bottom)
        .allowsHitTesting(isAnswerRevealed && item != nil)
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

private func originalWordDisplayOptional(_ word: String?, lang: String?, isWaseiEigo: Bool) -> String? {
    guard let word = word else { return nil }
    return originalWordDisplay(word, lang: lang, isWaseiEigo: isWaseiEigo)
}

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
