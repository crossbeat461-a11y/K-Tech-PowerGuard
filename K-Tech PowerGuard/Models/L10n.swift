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
    private static let languageKey = "appLanguage"

    static func t(_ key: String, _ args: CVarArg...) -> String {
        let raw = UserDefaults.standard.string(forKey: languageKey) ?? AppLanguage.ja.rawValue
        let lang = AppLanguage(rawValue: raw) ?? .ja
        let table = strings[lang] ?? strings[.ja]!
        let template = table[key] ?? key
        guard !args.isEmpty else { return template }
        return String(format: template, locale: lang.locale, arguments: args)
    }

    private static let strings: [AppLanguage: [String: String]] = [
        .ja: [
            "settings.window_title": "K-Tech PowerGuard 設定",
            "settings.subtitle": "v%@ · MacBook Neo テーマ",
            "settings.language": "表示言語",
            "settings.mac_title": "お使いの Mac",
            "settings.mac_compat": "バッテリー通知はすべての Mac で利用できます。Neo カラーはテーマとしてお好みで選べます。",
            "settings.tab.general": "一般",
            "settings.tab.history": "履歴",
            "settings.tab.appearance": "表示",
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
            "menu.about": "K-Tech PowerGuard について…",
            "menu.quit": "終了",
            "about.window_title": "K-Tech PowerGuard について",
            "about.version_line": "バージョン %@",
            "about.tagline": "K-Tech Studio — Digital Crafting & Minimal Solutions",
            "about.open_studio": "K-Tech Studio ウェブサイトを開く",
            "about.open_releases": "更新情報（GitHub Releases）",
            "about.open_issues": "不具合・要望（GitHub Issues）",
            "about.version_copy_hint": "クリックでバージョン番号をコピー",
            "notify.low_body": "バッテリーが %d%% です。%d%% 付近 — 充電を検討してください。",
            "notify.high_body": "バッテリーが %d%% です。%d%% に達しました — コンセントを外して充電を止めましょう。",
            "history.usage_title": "今日のバッテリー使用状況",
            "history.on_battery": "バッテリー駆動",
            "history.charging": "充電",
            "history.usage_note": "アプリ起動中に記録したデータから算出しています。",
            "history.active_charging": "現在の充電",
            "history.session_duration": "時間: %@",
            "history.level_trend": "残量の推移（24時間）",
            "history.level_trend_note": "濃い色 = 充電中、薄い色 = バッテリー駆動",
            "history.charging_title": "充電履歴",
            "history.empty": "まだ記録がありません。しばらく使うと表示されます。",
            "history.session_active": "充電中",
            "history.session_done": "完了"
        ],
        .en: [
            "settings.window_title": "K-Tech PowerGuard Settings",
            "settings.subtitle": "v%@ · MacBook Neo theme",
            "settings.language": "Language",
            "settings.mac_title": "Your Mac",
            "settings.mac_compat": "Battery alerts work on any Mac. Neo colors are an optional theme.",
            "settings.tab.general": "General",
            "settings.tab.history": "History",
            "settings.tab.appearance": "Appearance",
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
            "menu.about": "About K-Tech PowerGuard…",
            "menu.quit": "Quit",
            "about.window_title": "About K-Tech PowerGuard",
            "about.version_line": "Version %@",
            "about.tagline": "K-Tech Studio — Digital Crafting & Minimal Solutions",
            "about.open_studio": "Open K-Tech Studio website",
            "about.open_releases": "Updates on GitHub Releases",
            "about.open_issues": "Feedback & bugs (GitHub Issues)",
            "about.version_copy_hint": "Click to copy version number",
            "notify.low_body": "Battery is at %d%%. Near %d%% — consider charging.",
            "notify.high_body": "Battery is at %d%%. Reached %d%% — unplug to stop charging.",
            "history.usage_title": "Today's battery usage",
            "history.on_battery": "On battery",
            "history.charging": "Charging",
            "history.usage_note": "Estimated from samples recorded while the app is running.",
            "history.active_charging": "Current charge session",
            "history.session_duration": "Duration: %@",
            "history.level_trend": "Level trend (24 hours)",
            "history.level_trend_note": "Dark = charging, light = on battery",
            "history.charging_title": "Charging history",
            "history.empty": "No records yet. Data appears after some use.",
            "history.session_active": "Charging",
            "history.session_done": "Done"
        ]
    ]
}
