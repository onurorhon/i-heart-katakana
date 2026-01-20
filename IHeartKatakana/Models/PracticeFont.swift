import SwiftUI

struct PracticeFont: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let fileName: String?  // nil for system font
}

// Placeholder font for Phase 1
extension PracticeFont {
    static let system = PracticeFont(
        id: "system",
        name: "System",
        displayName: "System",
        fileName: nil
    )
}
