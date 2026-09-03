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

/// Full-screen surface for a menu takeover.
/// Content is inset to clear the pinned controls and constrained to a readable
/// width on larger screens. The background is full-bleed.
struct MenuSurface<Content: View>: View {
    /// Shown in the left slot when the menu is in a submenu.
    var onBack: (() -> Void)?
    let onClose: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            content()
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 32)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .overlay(alignment: .top) {
            // The card carries its own controls: back left, close right.
            HStack {
                if let onBack {
                    FloatingBackButton(action: onBack)
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                FloatingCloseButton(action: onClose)
            }
            .cardControlPlacement()
        }
    }
}

/// Soft shadow cast by a card onto whatever sits below it in the stack.
/// Drawn as a narrow gradient just outside the card's trailing edge rather
/// than as a real `.shadow`, which would need `compositingGroup()` and force
/// the whole card to rasterise offscreen every frame while it moves.
struct CardEdgeShadow: ViewModifier {
    var width: CGFloat = 24
    var opacity: Double = 0.16

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .trailing) {
                LinearGradient(
                    colors: [.black.opacity(opacity), .black.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: width)
                .offset(x: width)
                .allowsHitTesting(false)
            }
    }
}

extension View {
    /// Applied to cards that sit above another card in the stack.
    func cardEdgeShadow() -> some View {
        modifier(CardEdgeShadow())
    }
}

/// Placement for the control row every card carries at its top edge.
/// Shared so the practice card's triggers and the menu cards' controls
/// land in exactly the same spot.
struct CardControlPlacement: ViewModifier {
    /// Margin from the card edge, added to whatever the safe area requires.
    static let margin: CGFloat = 22

    @Environment(\.cardSafeAreaInsets) private var insets

    func body(content: Content) -> some View {
        VStack {
            content
                .padding(.leading, insets.leading + Self.margin)
                .padding(.trailing, insets.trailing + Self.margin)
                .padding(.top, insets.top + 4)

            Spacer()
        }
    }
}

/// Real safe-area insets, captured before the card stack ignores the safe area.
/// Cards paint edge to edge, so anything that must stay clear of the Dynamic
/// Island or the home indicator reads its insets from here instead.
private struct CardSafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    var cardSafeAreaInsets: EdgeInsets {
        get { self[CardSafeAreaInsetsKey.self] }
        set { self[CardSafeAreaInsetsKey.self] = newValue }
    }
}

extension View {
    func cardControlPlacement() -> some View {
        modifier(CardControlPlacement())
    }
}

/// A floating close button, carried by each menu card.
struct FloatingCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.title2)
                .frame(width: 44, height: 44)
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
                .frame(width: 44, height: 44)
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
