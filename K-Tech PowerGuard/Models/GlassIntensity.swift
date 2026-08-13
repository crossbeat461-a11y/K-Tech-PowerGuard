import SwiftUI
import AppKit

enum GlassIntensity: Int, CaseIterable, Identifiable, Codable {
    case off = 0
    case light = 1
    case medium = 2
    case strong = 3

    var id: Int { rawValue }

    func title() -> String {
        switch self {
        case .off: return L10n.t("glass.off")
        case .light: return L10n.t("glass.light")
        case .medium: return L10n.t("glass.medium")
        case .strong: return L10n.t("glass.strong")
        }
    }

    var material: Material {
        switch self {
        case .off: return .regularMaterial
        case .light: return .ultraThinMaterial
        case .medium: return .regularMaterial
        case .strong: return .thickMaterial
        }
    }

    var materialBlend: Double {
        switch self {
        case .off: return 0
        case .light: return 0.45
        case .medium: return 0.65
        case .strong: return 0.85
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
