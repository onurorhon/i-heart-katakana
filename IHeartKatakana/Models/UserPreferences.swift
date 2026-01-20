import Foundation
import SwiftData

@Model
class UserPreferences {
    var selectedColorThemeId: String
    var selectedPracticeFontId: String

    init(selectedColorThemeId: String = "default", selectedPracticeFontId: String = "system") {
        self.selectedColorThemeId = selectedColorThemeId
        self.selectedPracticeFontId = selectedPracticeFontId
    }
}
