import SwiftUI

/// A floating card component for menu items.
/// Each card is a separate floating element with rounded corners and shadow.
struct FloatingCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
    }
}

/// A floating close button for menus
struct FloatingCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.title2)
                .padding(12)
                .background(.regularMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

/// A floating back button for submenus
struct FloatingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .padding(12)
                .background(.regularMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3)
            .ignoresSafeArea()

        VStack(spacing: 12) {
            HStack {
                FloatingBackButton {}
                Spacer()
                FloatingCloseButton {}
            }

            FloatingCard {
                Text("Floating Card Content")
            }

            FloatingCard {
                VStack(spacing: 8) {
                    Text("Multiple items")
                    Text("In one card")
                }
            }
        }
        .padding()
        .frame(width: 250)
    }
}
