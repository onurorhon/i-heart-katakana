import SwiftUI
import SwiftData

enum ActiveMenu {
    case none
    case actions
    case hamburger
}

struct ContentView: View {
    @State private var activeMenu: ActiveMenu = .none
    @State private var settings = PracticeSettings()
    @State private var contentService = ContentService()
    @State private var ttsService = TTSService()
    @State private var likeService: LikeService?
    @State private var settingsVersion = 0
    @Environment(\.modelContext) private var modelContext

    // Snapshot of settings when menu opens (to detect changes)
    @State private var snapshotContentType: PracticeSettings.ContentType = .word
    @State private var snapshotPatterns: [String] = []
    @State private var snapshotPeekHintType: PracticeSettings.PeekHintType = .romaji
    @State private var snapshotSelectedCategory: String? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hamburger card sits below the practice card and stays mounted,
                // so it's still there as the practice card slides back over it.
                HamburgerMenu(
                    settings: settings,
                    onClose: { closeMenu() },
                    onItemTap: { item in
                        // TODO: Handle menu item taps
                        print("Tapped: \(item)")
                    }
                )
                .accessibilityHidden(activeMenu != .hamburger)

                // Practice card slides out to the left to reveal the hamburger
                // card. Its triggers belong to the card and travel with it.
                ZStack {
                    PracticeView(
                        settings: settings,
                        contentService: contentService,
                        ttsService: ttsService,
                        likeService: likeService,
                        settingsVersion: settingsVersion,
                        onExit: {}
                    )

                    practiceTriggers
                }
                .offset(x: activeMenu == .hamburger ? -geometry.size.width : 0)
                .accessibilityHidden(activeMenu != .none)

                // Actions card sits above the practice card, parked off-stage
                // to the left and sliding in over it.
                ActionsMenu(
                    settings: settings,
                    availableCategories: contentService.availableParentCategories,
                    likeService: likeService,
                    onClose: { closeMenu() }
                )
                .offset(x: activeMenu == .actions ? 0 : -geometry.size.width)
                .accessibilityHidden(activeMenu != .actions)
            }
            .animation(.easeInOut(duration: 0.3), value: activeMenu)
        }
        .task {
            contentService.load()
            likeService = LikeService(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            likeService?.loadLikedIds()
        }
    }

    // MARK: - Practice Card Triggers

    /// Carried by the practice card, so they slide away with it.
    private var practiceTriggers: some View {
        HStack {
            Button {
                openMenu(.actions)
            } label: {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Actions")

            Spacer()

            Button {
                openMenu(.hamburger)
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Menu")
        }
        .cardControlPlacement()
    }

    // MARK: - Menu Actions

    private func openMenu(_ menu: ActiveMenu) {
        // Snapshot current settings before opening menu
        snapshotContentType = settings.contentType
        snapshotPatterns = settings.enabledPatterns
        snapshotPeekHintType = settings.peekHintType
        snapshotSelectedCategory = settings.selectedCategory

        activeMenu = menu
    }

    private func closeMenu() {
        activeMenu = .none

        // Check if settings changed while menu was open
        let settingsChanged = settings.contentType != snapshotContentType
            || settings.enabledPatterns != snapshotPatterns
            || settings.peekHintType != snapshotPeekHintType
            || settings.selectedCategory != snapshotSelectedCategory

        if settingsChanged {
            settingsVersion += 1
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LikedWord.self, inMemory: true)
}
