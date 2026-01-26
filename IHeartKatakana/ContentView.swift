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
    @State private var settingsVersion = 0

    // Snapshot of settings when menu opens (to detect changes)
    @State private var snapshotContentType: PracticeSettings.ContentType = .word
    @State private var snapshotPatterns: [String] = []
    @State private var snapshotPeekHintType: PracticeSettings.PeekHintType = .romaji
    @State private var snapshotSelectedCategory: String? = nil

    var body: some View {
        ZStack {
            // Practice view fills entire screen
            PracticeView(
                settings: settings,
                contentService: contentService,
                ttsService: ttsService,
                settingsVersion: settingsVersion,
                onExit: {}
            )

            // Menu buttons overlay (top)
            VStack {
                HStack {
                    // Actions menu trigger (top left)
                    Button {
                        if activeMenu == .actions {
                            closeMenu()
                        } else {
                            openMenu(.actions)
                        }
                    } label: {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    // Hamburger menu trigger (top right)
                    Button {
                        if activeMenu == .hamburger {
                            closeMenu()
                        } else {
                            openMenu(.hamburger)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()
            }
            .safeAreaPadding()

            // Menu overlays
            if activeMenu != .none {
                // Dim background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }

                // Menu positioning
                VStack {
                    HStack {
                        if activeMenu == .actions {
                            ActionsMenu(
                                settings: settings,
                                availableCategories: contentService.availableParentCategories,
                                onClose: { closeMenu() }
                            )
                            Spacer()
                        }

                        if activeMenu == .hamburger {
                            Spacer()
                            HamburgerMenu(
                                settings: settings,
                                onClose: { closeMenu() },
                                onItemTap: { item in
                                    // TODO: Handle menu item taps
                                    print("Tapped: \(item)")
                                }
                            )
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
        .task {
            contentService.load()
        }
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

    private func closeMenu() {
        withAnimation {
            activeMenu = .none
        }

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
