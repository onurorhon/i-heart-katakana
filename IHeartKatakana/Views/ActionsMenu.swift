import SwiftUI

struct ActionsMenu: View {
    @Bindable var settings: PracticeSettings
    let onClose: () -> Void
    let onStart: () -> Void
    let onCategoryTap: () -> Void

    var body: some View {
        MenuContainer(alignment: .leading, onClose: onClose) {
            VStack(spacing: 12) {
                // Word / Kana toggle
                Picker("", selection: $settings.contentType) {
                    ForEach(PracticeSettings.ContentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // Level heading
                Text("Level")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                // Level checkboxes
                VStack(spacing: 8) {
                    MenuToggle(label: "Gojūon (basic)", isOn: $settings.gojuonEnabled)
                    MenuToggle(label: "Dakuon", isOn: $settings.dakuonEnabled)
                    MenuToggle(label: "Handakuon", isOn: $settings.handakuonEnabled)
                    MenuToggle(label: "Yōon", isOn: $settings.youonEnabled)
                    MenuToggle(label: "Extended", isOn: $settings.extendedEnabled)
                }

                // Category button (only for words)
                if settings.contentType == .word {
                    MenuButton(label: "Category") {
                        onCategoryTap()
                    }
                    .padding(.top, 8)
                }

                // Start button
                Button(action: onStart) {
                    Text("Start · スタート")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    ActionsMenu(
        settings: PracticeSettings(),
        onClose: {},
        onStart: {},
        onCategoryTap: {}
    )
}
