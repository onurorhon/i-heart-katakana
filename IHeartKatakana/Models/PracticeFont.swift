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

    static let cherryBombOne = PracticeFont(
        id: "cherry-bomb-one",
        name: "CherryBombOne-Regular",
        displayName: "Cherry Bomb One",
        postScriptName: "CherryBombOne-Regular",
        fileName: "CherryBombOne-Regular.ttf",
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

    static let nicoMoji = PracticeFont(
        id: "nico-moji",
        name: "NicoMoji-Regular",
        displayName: "Nico Moji",
        postScriptName: "NicoMoji-Regular",
        fileName: "NicoMoji-Regular.ttf",
        tracking: 2
    )

    static let slacksideOne = PracticeFont(
        id: "slackside-one",
        name: "SlacksideOne-Regular",
        displayName: "Slackside One",
        postScriptName: "SlacksideOne-Regular",
        fileName: "SlacksideOne-Regular.ttf",
        tracking: 2
    )

    static let yomogi = PracticeFont(
        id: "yomogi",
        name: "Yomogi-Regular",
        displayName: "Yomogi",
        postScriptName: "Yomogi-Regular",
        fileName: "Yomogi-Regular.ttf",
        tracking: 2
    )

    static let allFonts: [PracticeFont] = [
        notoSansCJK, system, cherryBombOne, darumadropOne,
        nicoMoji, slacksideOne, yomogi,
    ]

    static func font(forId id: String) -> PracticeFont {
        allFonts.first { $0.id == id } ?? .system
    }
}
