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
    @State private var isPracticing = false
    @State private var contentService = ContentService()

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

                // Center content
                if isPracticing {
                    PracticeView(
                        settings: settings,
                        contentService: contentService,
                        onExit: { isPracticing = false }
                    )
                } else {
                    Text("I❤️Katakana")
                        .font(.largeTitle)
                }

                Spacer()
            }

            // Menu overlays
            if activeMenu != .none {
                // Dim background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            activeMenu = .none
                        }
                    }

                // Menu positioning
                VStack {
                    HStack {
                        if activeMenu == .actions {
                            ActionsMenu(
                                settings: settings,
                                onClose: { withAnimation { activeMenu = .none } },
                                onStart: {
                                    withAnimation { activeMenu = .none }
                                    contentService.load()
                                    isPracticing = true
                                },
                                onCategoryTap: {
                                    // TODO: Show category submenu
                                }
                            )
                            Spacer()
                        }

                        if activeMenu == .hamburger {
                            Spacer()
                            HamburgerMenu(
                                onClose: { withAnimation { activeMenu = .none } },
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LikedWord.self, inMemory: true)
}
