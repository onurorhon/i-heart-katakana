import SwiftUI
import UIKit

struct MenuContainer<Content: View>: View {
    let alignment: HorizontalAlignment
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let onClose: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        alignment: HorizontalAlignment = .leading,
        showBackButton: Bool = false,
        onBack: (() -> Void)? = nil,
        onClose: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.onClose = onClose
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            // Header with back/close buttons
            HStack {
                if showBackButton {
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.title2)
                }
            }
            .padding(.bottom, 16)

            // Menu content
            content()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.67)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        MenuContainer(onClose: {}) {
            VStack(spacing: 12) {
                MenuButton(label: "Option 1") {}
                MenuButton(label: "Option 2") {}
                MenuButton(label: "Option 3") {}
            }
        }
    }
}
