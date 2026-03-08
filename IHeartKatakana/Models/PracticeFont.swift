import SwiftUI

struct PracticeFont: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let postScriptName: String?  // iOS font name for custom fonts; nil for system
    let fileName: String?        // Bundle filename; nil for system font
    var tracking: CGFloat = 0    // Letter spacing adjustment (overridden by fonts.json)
    var maxSize: CGFloat = 72    // Maximum display size in points (overridden by fonts.json)

    func swiftUIFont(size: CGFloat) -> Font {
        if let psName = postScriptName {
            return .custom(psName, size: size)
        }
        return .system(size: size)
    }
}

// MARK: - Font Definitions (technical identifiers)

extension PracticeFont {
    static let system = PracticeFont(
        id: "system",
        name: "System",
        displayName: "System",
        postScriptName: nil,
        fileName: nil
    )

    static let notoSansCJK = PracticeFont(
        id: "noto-sans-cjk",
        name: "NotoSansCJKjp-Medium",
        displayName: "Noto Sans CJK",
        postScriptName: "NotoSansCJKjp-Medium",
        fileName: "NotoSansCJKjp-Medium.ttf"
    )

    static let cherryBombOne = PracticeFont(
        id: "cherry-bomb-one",
        name: "CherryBombOne-Regular",
        displayName: "Cherry Bomb One",
        postScriptName: "CherryBombOne-Regular",
        fileName: "CherryBombOne-Regular.ttf"
    )

    static let darumadropOne = PracticeFont(
        id: "darumadrop-one",
        name: "DarumadropOne-Regular",
        displayName: "Darumadrop One",
        postScriptName: "DarumadropOne-Regular",
        fileName: "DarumadropOne-Regular.ttf"
    )

    static let nicoMoji = PracticeFont(
        id: "nico-moji",
        name: "NicoMoji-Regular",
        displayName: "Nico Moji",
        postScriptName: "NicoMoji-Regular",
        fileName: "NicoMoji-Regular.ttf"
    )

    static let slacksideOne = PracticeFont(
        id: "slackside-one",
        name: "SlacksideOne-Regular",
        displayName: "Slackside One",
        postScriptName: "SlacksideOne-Regular",
        fileName: "SlacksideOne-Regular.ttf"
    )

    static let yomogi = PracticeFont(
        id: "yomogi",
        name: "Yomogi-Regular",
        displayName: "Yomogi",
        postScriptName: "Yomogi-Regular",
        fileName: "Yomogi-Regular.ttf"
    )

    static let astroZ = PracticeFont(
        id: "astroz-kta",
        name: "AstroZ-KtA",
        displayName: "AstroZ",
        postScriptName: "AstroZ-KtA",
        fileName: "AstroZ-KtA.otf"
    )

    static let shotaroV = PracticeFont(
        id: "shotarov-kt",
        name: "ShotaroV-KT",
        displayName: "Shotaro V",
        postScriptName: "ShotaroV-KT",
        fileName: "ShotaroV-KT.otf"
    )

    static let gavadon = PracticeFont(
        id: "gavadon-ultrakt",
        name: "Gavadon-UltraKt",
        displayName: "Gavadon",
        postScriptName: "Gavadon-UltraKt",
        fileName: "Gavadon-UltraKt.otf"
    )

    static let poppop = PracticeFont(
        id: "poppop-kt",
        name: "POPPOP-Kt",
        displayName: "POPPOP",
        postScriptName: "POPPOP-Kt",
        fileName: "POPPOP-Kt.otf"
    )

    static let holidayMDJP = PracticeFont(
        id: "holiday-mdjp",
        name: "HolidayMDJP",
        displayName: "Holiday",
        postScriptName: "HolidayMDJP",
        fileName: "HolidayMDJP.otf"
    )

    static let ikaho = PracticeFont(
        id: "ikaho-katakana",
        name: "Ikaho-Katakana",
        displayName: "Ikaho",
        postScriptName: "Ikaho-Katakana",
        fileName: "Ikaho-Katakana.otf"
    )

    static let futaba = PracticeFont(
        id: "futaba-kt",
        name: "Futaba-KT",
        displayName: "Futaba",
        postScriptName: "FutabaKT",
        fileName: "Futaba-KT.otf"
    )

    static let coppepan = PracticeFont(
        id: "coppepan-chocokt",
        name: "Coppepan-ChocoKt",
        displayName: "Coppepan",
        postScriptName: "CoppepanChocoKt",
        fileName: "Coppepan-ChocoKt.otf"
    )

    static let hachipochi = PracticeFont(
        id: "hachipochi-eightkt",
        name: "Hachipochi-EightKt",
        displayName: "Hachipochi",
        postScriptName: "HachipochiEightKt",
        fileName: "Hachipochi-EightKt.otf"
    )

    static let nihonbashi = PracticeFont(
        id: "nihonbashi-kt",
        name: "Nihonbashi-KT",
        displayName: "Nihonbashi",
        postScriptName: "NihonbashiKT",
        fileName: "Nihonbashi-KT.otf"
    )

    /// Lookup table for base font definitions by id
    private static let baseFontsByID: [String: PracticeFont] = {
        let all: [PracticeFont] = [
            notoSansCJK, system, cherryBombOne, darumadropOne,
            nicoMoji, slacksideOne, yomogi, astroZ, shotaroV, gavadon, poppop,
            holidayMDJP, ikaho, futaba, coppepan, hachipochi, nihonbashi,
        ]
        return Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }()

    /// All enabled fonts, ordered and tuned by data/fonts.json
    static let allFonts: [PracticeFont] = {
        let config = FontConfig.load()
        return config.compactMap { entry in
            guard entry.enabled, var font = baseFontsByID[entry.id] else { return nil }
            font.tracking = entry.tracking
            font.maxSize = entry.maxSize
            return font
        }
    }()

    static func font(forId id: String) -> PracticeFont {
        allFonts.first { $0.id == id } ?? allFonts.first { $0.id == "system" } ?? .system
    }
}

// MARK: - Display tuning from data/fonts.json

private struct FontConfig: Decodable {
    let id: String
    let enabled: Bool
    let tracking: CGFloat
    let maxSize: CGFloat

    static func load() -> [FontConfig] {
        guard let url = Bundle.main.url(forResource: "fonts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let configs = try? JSONDecoder().decode([FontConfig].self, from: data) else {
            return []
        }
        return configs
    }
}
