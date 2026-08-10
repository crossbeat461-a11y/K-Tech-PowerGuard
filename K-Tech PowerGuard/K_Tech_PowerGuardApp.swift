import SwiftUI

@main
struct K_Tech_PowerGuardApp: App {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var monitor = BatteryMonitor()

    var body: some Scene {
        MenuBarExtra("K-Tech PowerGuard", systemImage: menuSymbol) {
            MenuBarContent(settings: settings, monitor: monitor)
        }
        .menuBarExtraStyle(.menu)

        Window(L10n.t("settings.window_title"), id: "settings") {
            SettingsView(settings: settings, monitor: monitor)
        }
        .defaultSize(width: 440, height: 580)

        Window(L10n.t("about.window_title"), id: "about") {
            AboutView(settings: settings)
        }
        .defaultSize(width: 360, height: 340)
    }

    private var menuSymbol: String {
        if monitor.snapshot.isCharging {
            return "bolt.fill"
        }
        return monitor.snapshot.levelPercent <= settings.lowerThreshold ? "battery.25" : "battery.100"
    }
}

private struct MenuBarContent: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var monitor: BatteryMonitor
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            if monitor.snapshot.isPresent {
                Text(menuStatusLine)
            }
            Button(L10n.t("menu.settings")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }
            Button(L10n.t("menu.about")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }
            Button(L10n.t("menu.quit")) {
                NSApplication.shared.terminate(nil)
            }
        }
        .id(settings.language)
        .onAppear {
            Task {
                _ = await NotificationService.requestAuthorization()
                if settings.launchAtLogin != LoginItemService.isEnabled() {
                    try? LoginItemService.setEnabled(settings.launchAtLogin)
                }
            }
            monitor.start(settings: settings)
        }
    }

    private var menuStatusLine: String {
        let state = monitor.snapshot.isCharging
            ? L10n.t("battery.menu_charging")
            : L10n.t("battery.menu_on_battery")
        return L10n.t("battery.menu_status", monitor.snapshot.levelPercent, state)
    }
}
