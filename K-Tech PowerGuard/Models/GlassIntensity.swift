import SwiftUI
import AppKit

enum GlassIntensity: Int, CaseIterable, Identifiable, Codable {
    case off = 0
    case light = 1
    case medium = 2
    case strong = 3
    case maximum = 4

    var id: Int { rawValue }

    func title() -> String {
        switch self {
        case .off: return L10n.t("glass.off")
        case .light: return L10n.t("glass.light")
        case .medium: return L10n.t("glass.medium")
        case .strong: return L10n.t("glass.strong")
        case .maximum: return L10n.t("glass.maximum")
        }
    }

    var material: Material {
        switch self {
        case .off: return .regularMaterial
        case .light: return .ultraThinMaterial
        case .medium: return .regularMaterial
        case .strong, .maximum: return .thickMaterial
        }
    }

    var secondaryMaterial: Material {
        switch self {
        case .maximum: return .regularMaterial
        default: return .ultraThinMaterial
        }
    }

    var materialBlend: Double {
        switch self {
        case .off: return 0
        case .light: return 0.45
        case .medium: return 0.65
        case .strong: return 0.92
        case .maximum: return 1.0
        }
    }

    var secondaryBlend: Double {
        switch self {
        case .strong: return 0.3
        case .maximum: return 0.55
        default: return 0
        }
    }

    var usesDoubleLayer: Bool {
        rawValue >= GlassIntensity.strong.rawValue
    }

    var backgroundTintOpacity: Double {
        switch self {
        case .off: return 1.0
        case .light: return 0.72
        case .medium: return 0.52
        case .strong: return 0.32
        case .maximum: return 0.18
        }
    }

    var cardMaterialBoost: Double {
        switch self {
        case .off: return 0
        case .light: return 0.12
        case .medium: return 0.18
        case .strong: return 0.24
        case .maximum: return 0.32
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case history
    case appearance

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .general: return "gearshape.fill"
        case .history: return "clock.arrow.circlepath"
        case .appearance: return "paintpalette.fill"
        }
    }

    func title() -> String {
        switch self {
        case .general: return L10n.t("settings.tab.general")
        case .history: return L10n.t("settings.tab.history")
        case .appearance: return L10n.t("settings.tab.appearance")
        }
    }
}

extension AppSettings {
    var effectiveGlassIntensity: GlassIntensity {
        if NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency {
            return .off
        }
        return glassIntensity
    }
}

struct GlassSurface<S: Shape>: View {
    let glass: GlassIntensity
    let tint: Color
    let shape: S

    var body: some View {
        if glass == .off {
            shape.fill(Color(nsColor: .controlBackgroundColor).opacity(0.94))
        } else {
            ZStack {
                shape.fill(tint.opacity(glass.backgroundTintOpacity))
                shape.fill(glass.material).opacity(glass.materialBlend)
                if glass.usesDoubleLayer {
                    shape.fill(glass.secondaryMaterial).opacity(glass.secondaryBlend)
                }
            }
        }
    }
}
