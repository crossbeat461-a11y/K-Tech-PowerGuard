import SwiftUI

enum NeoColorPreset: String, CaseIterable, Identifiable, Codable {
    case silver
    case blush
    case citrus
    case indigo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .silver: return "Silver"
        case .blush: return "Blush"
        case .citrus: return "Citrus"
        case .indigo: return "Indigo"
        }
    }

    var accent: Color {
        Color(red: accentRGB.r, green: accentRGB.g, blue: accentRGB.b)
    }

    var background: Color {
        Color(red: backgroundRGB.r, green: backgroundRGB.g, blue: backgroundRGB.b)
    }

    var accentRGB: (r: Double, g: Double, b: Double) {
        switch self {
        case .silver: return (0.66, 0.66, 0.68)
        case .blush: return (0.85, 0.55, 0.58)
        case .citrus: return (0.78, 0.72, 0.22)
        case .indigo: return (0.45, 0.42, 0.78)
        }
    }

    var backgroundRGB: (r: Double, g: Double, b: Double) {
        switch self {
        case .silver: return (0.96, 0.96, 0.97)
        case .blush: return (0.99, 0.94, 0.94)
        case .citrus: return (0.98, 0.98, 0.93)
        case .indigo: return (0.94, 0.94, 0.98)
        }
    }
}

struct ThemeColors: Equatable {
    var accent: Color
    var background: Color

    static func from(preset: NeoColorPreset) -> ThemeColors {
        ThemeColors(accent: preset.accent, background: preset.background)
    }
}
