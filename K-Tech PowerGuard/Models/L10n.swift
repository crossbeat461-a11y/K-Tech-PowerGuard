import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case ja
    case en

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ja: return "日本語"
        case .en: return "English"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue == "ja" ? "ja_JP" : "en_US")
    }
}

enum L10n {
    static func t(_ key: String, _ args: CVarArg...) -> String {
        let lang = AppSettings.shared.language
        let table = strings[lang] ?? strings[.ja]!
        let template = table[key] ?? key
        guard !args.isEmpty else { return template }
        return String(format: template, locale: lang.locale, arguments: args)
    }

    private static let strings: [AppLanguage: [String: String]] = [
        .ja: [
            "settings.window_title": "K-Tech PowerGuard 設定",
            "settings.subtitle": "v1.0.0 · MacBook Neo テーマ",
            "settings.language": "表示言語",
            "battery.current": "現在のバッテリー",
            "battery.state": "状態",
            "battery.unknown": "不明",
            "battery.charging": "充電中",
            "battery.on_battery": "バッテリー駆動",
            "battery.menu_status": "バッテリー %d%% · %@",
            "battery.menu_charging": "充電中",
            "battery.menu_on_battery": "駆動中",
            "thresholds.title": "通知のしきい値",
            "thresholds.lower": "下限（充電を促す）",
            "thresholds.upper": "上限（充電停止を促す）",
            "thresholds.invalid": "下限は上限より小さくしてください。",
            "neo.title": "MacBook Neo カラー",
            "neo.subtitle": "Silver · Blush · Citrus · Indigo",
            "color.custom": "カスタムアクセント色",
            "toggle.notifications": "通知を有効にする",
            "toggle.login": "ログイン時に起動",
            "about.charge_limit": "充電の物理的な停止は macOS では行えません。上限到達時は通知でお知らせします。",
            "about.watch": "Apple Watch には、Mac の通知を Watch に表示する設定をオンにすると届くことがあります。",
            "menu.settings": "設定…",
            "menu.quit": "終了",
            "notify.low_body": "バッテリーが %d%% です。%d%% 付近 — 充電を検討してください。",
            "notify.high_body": "バッテリーが %d%% です。%d%% に達しました — コンセントを外して充電を止めましょう。"
        ],
        .en: [
            "settings.window_title": "K-Tech PowerGuard Settings",
            "settings.subtitle": "v1.0.0 · MacBook Neo theme",
            "settings.language": "Language",
            "battery.current": "Battery",
            "battery.state": "Status",
            "battery.unknown": "Unknown",
            "battery.charging": "Charging",
            "battery.on_battery": "On battery",
            "battery.menu_status": "Battery %d%% · %@",
            "battery.menu_charging": "Charging",
            "battery.menu_on_battery": "On battery",
            "thresholds.title": "Notification thresholds",
            "thresholds.lower": "Lower limit (prompt to charge)",
            "thresholds.upper": "Upper limit (prompt to unplug)",
            "thresholds.invalid": "Lower limit must be below upper limit.",
            "neo.title": "MacBook Neo colors",
            "neo.subtitle": "Silver · Blush · Citrus · Indigo",
            "color.custom": "Custom accent color",
            "toggle.notifications": "Enable notifications",
            "toggle.login": "Launch at login",
            "about.charge_limit": "macOS cannot stop charging physically. At the upper limit you will get a notification.",
            "about.watch": "Apple Watch may show alerts if mirroring Mac notifications is enabled.",
            "menu.settings": "Settings…",
            "menu.quit": "Quit",
            "notify.low_body": "Battery is at %d%%. Near %d%% — consider charging.",
            "notify.high_body": "Battery is at %d%%. Reached %d%% — unplug to stop charging."
        ]
    ]
}
