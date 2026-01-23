import SwiftUI

enum HamburgerMenuItem: String, CaseIterable {
    case font = "Font"
    case colors = "Colors"
    case about = "About"
}

struct HamburgerMenu: View {
    @Bindable var settings: PracticeSettings
    let onClose: () -> Void
    let onItemTap: (HamburgerMenuItem) -> Void

    @State private var showingPeekOptions = false

    var body: some View {
        if showingPeekOptions {
            peekSubmenu
        } else {
            mainMenu
        }
    }

    private var mainMenu: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Close button
            FloatingCloseButton(action: onClose)

            // Pull to Peek button (opens submenu)
            FloatingCard {
                Button {
                    showingPeekOptions = true
                } label: {
                    HStack {
                        Text("Pull to Peek: \(settings.peekHintType.rawValue)")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            // Menu items as separate floating cards
            ForEach(HamburgerMenuItem.allCases, id: \.self) { item in
                FloatingCard {
                    Button {
                        onItemTap(item)
                    } label: {
                        HStack {
                            Text(item.rawValue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 220)
    }

    private var peekSubmenu: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Back and close buttons
            HStack {
                FloatingBackButton {
                    showingPeekOptions = false
                }
                Spacer()
                FloatingCloseButton(action: onClose)
            }

            // Peek options
            FloatingCard {
                VStack(spacing: 0) {
                    Text("Pull to Peek")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ForEach(Array(PracticeSettings.PeekHintType.allCases.enumerated()), id: \.element) { index, option in
                        Button {
                            settings.peekHintType = option
                            showingPeekOptions = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .opacity(settings.peekHintType == option ? 1 : 0)
                                    .frame(width: 20)

                                Text(option.rawValue)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < PracticeSettings.PeekHintType.allCases.count - 1 {
                            Divider()
                                .padding(.leading, 28)
                        }
                    }
                }
            }
        }
        .frame(width: 220)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.5)
            .ignoresSafeArea()

        VStack {
            HStack {
                Spacer()
                HamburgerMenu(
                    settings: PracticeSettings(),
                    onClose: {},
                    onItemTap: { _ in }
                )
            }
            .padding()
            Spacer()
        }
    }
}
