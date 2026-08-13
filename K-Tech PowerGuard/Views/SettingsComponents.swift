import SwiftUI

struct SettingsWindowBackground: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        let glass = settings.effectiveGlassIntensity
        ZStack {
            settings.theme.background
            if glass != .off {
                GlassSurface(
                    glass: glass,
                    tint: settings.theme.background,
                    shape: Rectangle()
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct SettingsCard<Content: View>: View {
    @ObservedObject var settings: AppSettings
    @ViewBuilder var content: () -> Content

    private let cardShape = RoundedRectangle(cornerRadius: 12, style: .continuous)

    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(cardShape)
            .overlay {
                cardShape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }

    @ViewBuilder
    private var cardBackground: some View {
        let glass = settings.effectiveGlassIntensity
        if glass == .off {
            cardShape.fill(Color(nsColor: .controlBackgroundColor).opacity(0.94))
        } else {
            ZStack {
                cardShape.fill(settings.theme.background.opacity(glass.backgroundTintOpacity))
                cardShape.fill(glass.material).opacity(min(1, glass.materialBlend + glass.cardMaterialBoost))
                if glass.usesDoubleLayer {
                    cardShape.fill(glass.secondaryMaterial).opacity(glass.secondaryBlend)
                }
            }
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    @ViewBuilder var trailing: () -> Trailing

    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 22, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
        }
        .padding(.vertical, 4)
    }
}

struct SettingsRowContent<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsTabBar: View {
    @Binding var selection: SettingsTab
    @ObservedObject var settings: AppSettings

    var body: some View {
        HStack(spacing: 8) {
            ForEach(SettingsTab.allCases) { tab in
                tabButton(tab)
            }
        }
    }

    private func tabButton(_ tab: SettingsTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.iconName)
                    .font(.title3)
                Text(tab.title())
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? settings.theme.accent : Color.primary.opacity(0.06))
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct GlassIntensityPicker: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        HStack(spacing: 6) {
            ForEach(GlassIntensity.allCases) { level in
                glassButton(level)
            }
        }
    }

    private func glassButton(_ level: GlassIntensity) -> some View {
        let isSelected = settings.glassIntensity == level
        return Button {
            settings.glassIntensity = level
        } label: {
            Text(level.title())
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? settings.theme.accent : Color.primary.opacity(0.07))
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
