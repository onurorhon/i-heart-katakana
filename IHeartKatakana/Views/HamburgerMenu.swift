import SwiftUI

enum HamburgerMenuItem: String, CaseIterable {
    case settings = "Settings"
    case font = "Font"
    case colors = "Colors"
    case about = "About"
}

struct HamburgerMenu: View {
    let onClose: () -> Void
    let onItemTap: (HamburgerMenuItem) -> Void

    var body: some View {
        MenuContainer(alignment: .trailing, onClose: onClose) {
            VStack(spacing: 12) {
                ForEach(HamburgerMenuItem.allCases, id: \.self) { item in
                    MenuButton(label: item.rawValue) {
                        onItemTap(item)
                    }
                }
            }
        }
    }
}

#Preview {
    HamburgerMenu(onClose: {}, onItemTap: { _ in })
}
