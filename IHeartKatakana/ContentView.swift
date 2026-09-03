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

    // Submenu state lives here so the pinned back button can drive it
    @State private var actionsShowingCategories = false
    @State private var hamburgerSubmenu: HamburgerSubmenu?

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
                    submenu: $hamburgerSubmenu,
                    onItemTap: { item in
                        // TODO: Handle menu item taps
                        print("Tapped: \(item)")
                    }
                )
                .accessibilityHidden(activeMenu != .hamburger)

                // Practice card slides out to the left to reveal the hamburger card
                PracticeView(
                    settings: settings,
                    contentService: contentService,
                    ttsService: ttsService,
                    likeService: likeService,
                    settingsVersion: settingsVersion,
                    onExit: {}
                )
                .offset(x: activeMenu == .hamburger ? -geometry.size.width : 0)
                .accessibilityHidden(activeMenu != .none)

                // Actions card slides in from the left, over the practice card
                if activeMenu == .actions {
                    ActionsMenu(
                        settings: settings,
                        availableCategories: contentService.availableParentCategories,
                        likeService: likeService,
                        showingCategories: $actionsShowingCategories
                    )
                    .transition(.move(edge: .leading))
                }

                // Pinned controls, above every card
                topControls
            }
        }
        .task {
            contentService.load()
            likeService = LikeService(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            likeService?.loadLikedIds()
        }
    }

    // MARK: - Pinned Controls

    /// Left slot: actions trigger when closed, back when a submenu is open, hidden at menu root.
    /// Right slot: hamburger trigger when closed, close whenever a menu is open.
    private var topControls: some View {
        VStack {
            HStack {
                Button {
                    if activeMenu == .none {
                        openMenu(.actions)
                    } else {
                        goBack()
                    }
                } label: {
                    Image(systemName: isInSubmenu ? "chevron.left" : "bolt.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .opacity(isLeftControlVisible ? 1 : 0)
                .allowsHitTesting(isLeftControlVisible)
                .accessibilityLabel(isInSubmenu ? "Back" : "Actions")

                Spacer()

                Button {
                    if activeMenu == .none {
                        openMenu(.hamburger)
                    } else {
                        closeMenu()
                    }
                } label: {
                    Image(systemName: activeMenu == .none ? "line.3.horizontal" : "xmark")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .accessibilityLabel(activeMenu == .none ? "Menu" : "Close")
            }
            .padding(.horizontal, 6)
            .padding(.top, -12)

            Spacer()
        }
        .safeAreaPadding()
    }

    private var isInSubmenu: Bool {
        switch activeMenu {
        case .none: return false
        case .actions: return actionsShowingCategories
        case .hamburger: return hamburgerSubmenu != nil
        }
    }

    private var isLeftControlVisible: Bool {
        activeMenu == .none || isInSubmenu
    }

    // MARK: - Menu Actions

    private func openMenu(_ menu: ActiveMenu) {
        // Snapshot current settings before opening menu
        snapshotContentType = settings.contentType
        snapshotPatterns = settings.enabledPatterns
        snapshotPeekHintType = settings.peekHintType
        snapshotSelectedCategory = settings.selectedCategory

        withAnimation {
            activeMenu = menu
        }
    }

    private func goBack() {
        withAnimation {
            actionsShowingCategories = false
            hamburgerSubmenu = nil
        }
    }

    private func closeMenu() {
        withAnimation {
            activeMenu = .none
        }

        // Reset submenus so menus reopen at their root
        actionsShowingCategories = false
        hamburgerSubmenu = nil

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
