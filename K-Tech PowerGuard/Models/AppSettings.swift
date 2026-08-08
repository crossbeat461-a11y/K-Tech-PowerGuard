import SwiftUI
import AppKit
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private enum Keys {
        static let lowerThreshold = "lowerThreshold"
        static let upperThreshold = "upperThreshold"
        static let launchAtLogin = "launchAtLogin"
        static let notificationsEnabled = "notificationsEnabled"
        static let preset = "neoPreset"
        static let customAccentR = "customAccentR"
        static let customAccentG = "customAccentG"
        static let customAccentB = "customAccentB"
        static let useCustomAccent = "useCustomAccent"
        static let language = "appLanguage"
    }

    @Published var lowerThreshold: Int {
        didSet { UserDefaults.standard.set(lowerThreshold, forKey: Keys.lowerThreshold) }
    }

    @Published var upperThreshold: Int {
        didSet { UserDefaults.standard.set(upperThreshold, forKey: Keys.upperThreshold) }
    }

    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var selectedPreset: NeoColorPreset {
        didSet { UserDefaults.standard.set(selectedPreset.rawValue, forKey: Keys.preset) }
    }

    @Published var useCustomAccent: Bool {
        didSet { UserDefaults.standard.set(useCustomAccent, forKey: Keys.useCustomAccent) }
    }

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    @Published var theme: ThemeColors

    @Published var customAccent: Color {
        didSet {
            let c = NSColor(customAccent).usingColorSpace(.sRGB) ?? .systemBlue
            UserDefaults.standard.set(Double(c.redComponent), forKey: Keys.customAccentR)
            UserDefaults.standard.set(Double(c.greenComponent), forKey: Keys.customAccentG)
            UserDefaults.standard.set(Double(c.blueComponent), forKey: Keys.customAccentB)
            if useCustomAccent {
                theme = ThemeColors(accent: customAccent, background: selectedPreset.background)
            }
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        lowerThreshold = defaults.object(forKey: Keys.lowerThreshold) as? Int ?? 20
        upperThreshold = defaults.object(forKey: Keys.upperThreshold) as? Int ?? 80
        launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true

        let langRaw = defaults.string(forKey: Keys.language) ?? AppLanguage.ja.rawValue
        language = AppLanguage(rawValue: langRaw) ?? .ja

        let presetRaw = defaults.string(forKey: Keys.preset) ?? NeoColorPreset.silver.rawValue
        selectedPreset = NeoColorPreset(rawValue: presetRaw) ?? .silver
        useCustomAccent = defaults.bool(forKey: Keys.useCustomAccent)

        let r = defaults.object(forKey: Keys.customAccentR) as? Double ?? 0.66
        let g = defaults.object(forKey: Keys.customAccentG) as? Double ?? 0.66
        let b = defaults.object(forKey: Keys.customAccentB) as? Double ?? 0.68
        customAccent = Color(red: r, green: g, blue: b)

        if useCustomAccent {
            theme = ThemeColors(accent: Color(red: r, green: g, blue: b), background: NeoColorPreset(rawValue: presetRaw)?.background ?? NeoColorPreset.silver.background)
        } else {
            theme = ThemeColors.from(preset: NeoColorPreset(rawValue: presetRaw) ?? .silver)
        }
    }

    func applyPreset(_ preset: NeoColorPreset) {
        useCustomAccent = false
        selectedPreset = preset
        theme = ThemeColors.from(preset: preset)
        customAccent = preset.accent
    }

    func applyCustomAccent(_ color: Color) {
        useCustomAccent = true
        customAccent = color
        theme = ThemeColors(accent: color, background: selectedPreset.background)
    }

    var isValidThresholds: Bool {
        lowerThreshold >= 5 && upperThreshold <= 100 && lowerThreshold < upperThreshold
    }
}
