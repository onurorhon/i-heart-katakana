import SwiftUI

enum HamburgerMenuItem: String, CaseIterable {
    case font = "Font"
    case colors = "Colors"
    case about = "About"
}

enum HamburgerSubmenu {
    case peek
    case colors
    case fonts
}

struct HamburgerMenu: View {
    @Bindable var settings: PracticeSettings
    /// Owned by ContentView so the pinned back control can drive it.
    @Binding var submenu: HamburgerSubmenu?
    let onItemTap: (HamburgerMenuItem) -> Void

    // Theme names in display order
    private let themeNames = ["Pink", "Blue", "Green", "Yellow", "Purple"]

    var body: some View {
        MenuSurface {
            switch submenu {
            case .peek: peekSubmenu
            case .colors: colorSubmenu
            case .fonts: fontSubmenu
            case nil: mainMenu
            }
        }
    }

    private var mainMenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Pull-down Hint button (opens submenu)
            FloatingCard {
                Button {
                    submenu = .peek
                } label: {
                    HStack {
                        Text("Pull-down Hint: \(settings.peekHintType.rawValue)")
                            .lineLimit(1)
                            .truncationMode(.tail)
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
                        if item == .colors {
                            submenu = .colors
                        } else if item == .font {
                            submenu = .fonts
                        } else {
                            onItemTap(item)
                        }
                    } label: {
                        HStack {
                            Text(item.rawValue)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var peekSubmenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Peek options
            FloatingCard {
                VStack(spacing: 0) {
                    Text("Pull-down Hint")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ForEach(Array(PracticeSettings.PeekHintType.allCases.enumerated()), id: \.element) { index, option in
                        Button {
                            settings.peekHintType = option
                            submenu = nil
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .opacity(settings.peekHintType == option ? 1 : 0)
                                    .frame(width: 20)

                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

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
    }

    private var colorSubmenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Color options
            FloatingCard {
                VStack(spacing: 0) {
                    // Randomize toggle
                    Toggle("Randomize", isOn: $settings.randomizeTheme)
                        .padding(.bottom, 8)

                    // Select all / Unselect all pill (only when randomize is on)
                    if settings.randomizeTheme {
                        let allSelected = settings.enabledThemeIndices.count == themeNames.count

                        Button {
                            if allSelected {
                                // Unselect all but first
                                settings.enabledThemeIndices = [0]
                            } else {
                                // Select all
                                settings.enabledThemeIndices = Set(0..<themeNames.count)
                            }
                        } label: {
                            Text(allSelected ? "Unselect all" : "Select all")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.quaternary, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    }

                    Divider()
                        .padding(.bottom, 8)

                    // Theme list
                    ForEach(Array(themeNames.enumerated()), id: \.offset) { index, name in
                        Button {
                            if settings.randomizeTheme {
                                // Checkbox mode - toggle this theme
                                if settings.enabledThemeIndices.contains(index) {
                                    // Don't allow deselecting the last one
                                    if settings.enabledThemeIndices.count > 1 {
                                        settings.enabledThemeIndices.remove(index)
                                    }
                                } else {
                                    settings.enabledThemeIndices.insert(index)
                                }
                            } else {
                                // Radio mode - select only this theme
                                settings.selectedThemeIndex = index
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if settings.randomizeTheme {
                                    // Checkbox
                                    Image(systemName: settings.enabledThemeIndices.contains(index) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(settings.enabledThemeIndices.contains(index) ? .accentColor : .secondary)
                                        .frame(width: 20)
                                } else {
                                    // Radio button
                                    Image(systemName: settings.selectedThemeIndex == index ? "circle.inset.filled" : "circle")
                                        .foregroundColor(settings.selectedThemeIndex == index ? .accentColor : .secondary)
                                        .frame(width: 20)
                                }

                                Text(name)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < themeNames.count - 1 {
                            Divider()
                                .padding(.leading, 28)
                        }
                    }
                }
            }
        }
    }
    private var fontSubmenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Font options
            FloatingCard {
                VStack(spacing: 0) {
                    // Randomize toggle
                    Toggle("Randomize", isOn: $settings.randomizeFont)
                        .padding(.bottom, 8)

                    // Select all / Unselect all pill (only when randomize is on)
                    if settings.randomizeFont {
                        let allSelected = settings.enabledFontIds.count == PracticeFont.allFonts.count

                        Button {
                            if allSelected {
                                // Unselect all but default
                                settings.enabledFontIds = [PracticeFont.allFonts[0].id]
                            } else {
                                // Select all
                                settings.enabledFontIds = Set(PracticeFont.allFonts.map(\.id))
                            }
                        } label: {
                            Text(allSelected ? "Unselect all" : "Select all")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.quaternary, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    }

                    Divider()
                        .padding(.bottom, 8)

                    // Font list. Lazy so only visible rows realise: each row will
                    // eventually render a katakana specimen in its own font.
                    LazyVStack(spacing: 0) {
                    ForEach(Array(PracticeFont.allFonts.enumerated()), id: \.element.id) { index, font in
                        Button {
                            if settings.randomizeFont {
                                // Checkbox mode - toggle this font
                                if settings.enabledFontIds.contains(font.id) {
                                    if settings.enabledFontIds.count > 1 {
                                        settings.enabledFontIds.remove(font.id)
                                    }
                                } else {
                                    settings.enabledFontIds.insert(font.id)
                                }
                            } else {
                                // Radio mode - select only this font
                                settings.selectedFontId = font.id
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if settings.randomizeFont {
                                    // Checkbox
                                    Image(systemName: settings.enabledFontIds.contains(font.id) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(settings.enabledFontIds.contains(font.id) ? .accentColor : .secondary)
                                        .frame(width: 20)
                                } else {
                                    // Radio button
                                    Image(systemName: settings.selectedFontId == font.id ? "circle.inset.filled" : "circle")
                                        .foregroundColor(settings.selectedFontId == font.id ? .accentColor : .secondary)
                                        .frame(width: 20)
                                }

                                Text(font.displayName)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < PracticeFont.allFonts.count - 1 {
                            Divider()
                                .padding(.leading, 28)
                        }
                    }
                    }
                }
            }
        }
    }
}

#Preview {
    HamburgerMenu(
        settings: PracticeSettings(),
        submenu: .constant(nil),
        onItemTap: { _ in }
    )
}
