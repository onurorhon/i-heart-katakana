import SwiftUI

struct PracticeFont: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let postScriptName: String?  // iOS font name for custom fonts; nil for system
    let fileName: String?        // Bundle filename; nil for system font
    let tracking: CGFloat        // Letter spacing adjustment

    func swiftUIFont(size: CGFloat) -> Font {
        if let psName = postScriptName {
            return .custom(psName, size: size)
        }
        return .system(size: size)
    }
}

extension PracticeFont {
    static let system = PracticeFont(
        id: "system",
        name: "System",
        displayName: "System",
        postScriptName: nil,
        fileName: nil,
        tracking: 0
    )

    static let notoSansCJK = PracticeFont(
        id: "noto-sans-cjk",
        name: "NotoSansCJKjp-Medium",
        displayName: "Noto Sans CJK",
        postScriptName: "NotoSansCJKjp-Medium",
        fileName: "NotoSansCJKjp-Medium.ttf",
        tracking: 2
    )

    static let darumadropOne = PracticeFont(
        id: "darumadrop-one",
        name: "DarumadropOne-Regular",
        displayName: "Darumadrop One",
        postScriptName: "DarumadropOne-Regular",
        fileName: "DarumadropOne-Regular.ttf",
        tracking: 4
    )

    static let allFonts: [PracticeFont] = [notoSansCJK, system, darumadropOne]

    static func font(forId id: String) -> PracticeFont {
        allFonts.first { $0.id == id } ?? .system
    }
}
