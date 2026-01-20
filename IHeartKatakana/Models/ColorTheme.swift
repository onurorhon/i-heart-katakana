import SwiftUI

struct ColorTheme: Identifiable {
    let id: String
    let name: String

    // Light mode colors
    let backgroundColorLight: Color
    let textColorLight: Color
    let accentColorLight: Color

    // Dark mode colors
    let backgroundColorDark: Color
    let textColorDark: Color
    let accentColorDark: Color

    // Convenience accessors for current color scheme
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? backgroundColorDark : backgroundColorLight
    }

    func textColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textColorDark : textColorLight
    }

    func accentColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? accentColorDark : accentColorLight
    }
}

// Placeholder theme for Phase 1
extension ColorTheme {
    static let placeholder = ColorTheme(
        id: "default",
        name: "Default",
        backgroundColorLight: .white,
        textColorLight: .black,
        accentColorLight: .accentColor,
        backgroundColorDark: .black,
        textColorDark: .white,
        accentColorDark: .accentColor
    )
}
