import SwiftUI

struct NeoPresetPicker: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        HStack(spacing: 10) {
            ForEach(NeoColorPreset.allCases) { preset in
                presetButton(preset)
            }
        }
    }

    private func presetButton(_ preset: NeoColorPreset) -> some View {
        let isSelected = !settings.useCustomAccent && settings.selectedPreset == preset
        return Button {
            settings.applyPreset(preset)
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(preset.accent)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(isSelected ? settings.theme.accent : Color.clear, lineWidth: 2)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                    )
                Text(preset.displayName)
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
