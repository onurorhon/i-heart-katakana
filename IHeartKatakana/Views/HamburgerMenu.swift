import SwiftUI

enum HamburgerMenuItem: String, CaseIterable {
    case font = "Font"
    case colors = "Colors"
    case about = "About"
}

struct HamburgerMenu: View {
    let settings: PracticeSettings
    let onClose: () -> Void
    let onItemTap: (HamburgerMenuItem) -> Void

    var body: some View {
        MenuContainer(alignment: .trailing, onClose: onClose) {
            VStack(spacing: 12) {
                // Pull to Peek setting (words only)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pull to Peek (words)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    ForEach(PracticeSettings.PeekHintType.allCases, id: \.self) { option in
                        MenuSelectionButton(
                            label: option.rawValue,
                            isSelected: settings.peekHintType == option
                        ) {
                            settings.peekHintType = option
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 4)

                // Other menu items
                ForEach(HamburgerMenuItem.allCases, id: \.self) { item in
                    MenuButton(label: item.rawValue) {
                        onItemTap(item)
                    }
                }
            }
        }
    }
}

struct MenuSelectionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .systemGray5))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HamburgerMenu(
        settings: PracticeSettings(),
        onClose: {},
        onItemTap: { _ in }
    )
}
