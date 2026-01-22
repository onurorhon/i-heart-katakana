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
    @State private var refreshTrigger = 0

    var body: some View {
        ZStack {
            // Main content area
            VStack {
                // Top bar with menu triggers
                HStack {
                    // Actions menu trigger (top left)
                    Button {
                        withAnimation {
                            activeMenu = activeMenu == .actions ? .none : .actions
                        }
                    } label: {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                    }

                    Spacer()

                    // Hamburger menu trigger (top right)
                    Button {
                        withAnimation {
                            activeMenu = activeMenu == .hamburger ? .none : .hamburger
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                }
                .padding()

                Spacer()

                // Always show practice view
                PracticeView(
                    settings: settings,
                    contentService: contentService,
                    onExit: {}
                )
                .id(refreshTrigger) // Force refresh when trigger changes

                Spacer()
            }

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
                                onClose: { closeMenu() },
                                onCategoryTap: {
                                    // TODO: Show category submenu
                                }
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
        .onAppear {
            contentService.load()
        }
    }

    // MARK: - Menu Actions

    private func closeMenu() {
        withAnimation {
            activeMenu = .none
        }
        // Trigger practice view refresh after menu closes
        refreshTrigger += 1
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LikedWord.self, inMemory: true)
}
