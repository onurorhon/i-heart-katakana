import SwiftUI

struct ActionsMenu: View {
    @Bindable var settings: PracticeSettings
    let availableCategories: [String]
    let likeService: LikeService?
    let onClose: () -> Void

    @State private var showingCategories = false

    var body: some View {
        if showingCategories {
            categorySubmenu
        } else {
            mainMenu
        }
    }

    private var mainMenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Close button
            FloatingCloseButton(action: onClose)

            // Word / Kana toggle
            FloatingCard {
                Picker("", selection: $settings.contentType) {
                    ForEach(PracticeSettings.ContentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Level toggles
            FloatingCard {
                VStack(spacing: 0) {
                    Text("Level")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        Toggle("Gojūon (basic)", isOn: $settings.gojuonEnabled)
                        Toggle("Dakuon", isOn: $settings.dakuonEnabled)
                        Toggle("Handakuon", isOn: $settings.handakuonEnabled)
                        Toggle("Yōon", isOn: $settings.youonEnabled)
                        Toggle("Extended", isOn: $settings.extendedEnabled)
                    }
                }
            }

            // Category button (only for words)
            if settings.contentType == .word {
                FloatingCard {
                    Button {
                        showingCategories = true
                    } label: {
                        HStack {
                            Text(categoryButtonLabel)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 220)
    }

    private var categorySubmenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Back and close buttons
            HStack {
                FloatingBackButton {
                    showingCategories = false
                }
                Spacer()
                FloatingCloseButton(action: onClose)
            }

            // Category list as floating card
            FloatingCard {
                VStack(spacing: 0) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 0) {
                            // "All" option
                            CategoryRow(
                                label: "All",
                                isSelected: settings.selectedCategory == nil,
                                action: {
                                    settings.selectedCategory = nil
                                    showingCategories = false
                                }
                            )

                            Divider()
                                .padding(.leading, 28)

                            // "Liked" option (only shown when liked words exist)
                            if let likeService, !likeService.likedWordIds.isEmpty {
                                CategoryRow(
                                    label: "Liked",
                                    isSelected: settings.selectedCategory == "Liked",
                                    action: {
                                        settings.selectedCategory = "Liked"
                                        showingCategories = false
                                    }
                                )

                                Divider()
                                    .padding(.leading, 28)
                            }

                            // Individual categories
                            ForEach(Array(availableCategories.enumerated()), id: \.element) { index, category in
                                CategoryRow(
                                    label: category,
                                    isSelected: settings.selectedCategory == category,
                                    action: {
                                        settings.selectedCategory = category
                                        showingCategories = false
                                    }
                                )

                                if index < availableCategories.count - 1 {
                                    Divider()
                                        .padding(.leading, 28)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
            }
        }
        .frame(width: 220)
    }

    private var categoryButtonLabel: String {
        if let category = settings.selectedCategory {
            return "Category: \(category)"
        }
        return "Category: All"
    }
}

struct CategoryRow: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .opacity(isSelected ? 1 : 0)
                    .frame(width: 20)

                Text(label)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.5)
            .ignoresSafeArea()

        VStack {
            HStack {
                ActionsMenu(
                    settings: PracticeSettings(),
                    availableCategories: ["Everyday Life", "Sports & Recreation", "Technology"],
                    likeService: nil,
                    onClose: {}
                )
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
}
