import SwiftUI

struct MenuButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct MenuToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(label, isOn: $isOn)
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(8)
    }
}

struct MenuSegmentedToggle: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(0..<options.count, id: \.self) { index in
                Text(options[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 12) {
        MenuButton(label: "Test Button") {}
        MenuToggle(label: "Test Toggle", isOn: .constant(true))
        MenuSegmentedToggle(options: ["Word", "Kana"], selection: .constant(0))
    }
    .padding()
    .frame(width: 250)
}
