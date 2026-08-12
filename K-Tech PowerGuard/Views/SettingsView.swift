import SwiftUI
import AppKit

private enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case history
    case appearance

    var id: String { rawValue }

    func title() -> String {
        switch self {
        case .general: return L10n.t("settings.tab.general")
        case .history: return L10n.t("settings.tab.history")
        case .appearance: return L10n.t("settings.tab.appearance")
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var monitor: BatteryMonitor
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            tabPicker
            tabContent
        }
        .padding(24)
        .frame(minWidth: 440, minHeight: 520)
        .background(settings.theme.background)
        .tint(settings.theme.accent)
        .environment(\.locale, settings.language.locale)
        .onAppear(perform: updateWindowTitle)
        .onChange(of: settings.language) { _, _ in
            updateWindowTitle()
        }
    }

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            ForEach(SettingsTab.allCases) { tab in
                Text(tab.title()).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    @ViewBuilder
    private var tabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch selectedTab {
                case .general:
                    generalTab
                case .history:
                    BatteryHistorySection(settings: settings, monitor: monitor)
                case .appearance:
                    appearanceTab
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var generalTab: some View {
        Group {
            statusCard
            thresholdsSection
            togglesSection
            aboutSection
        }
    }

    private var appearanceTab: some View {
        Group {
            languageSection
            macSection
            NeoPresetPicker(settings: settings)
            customColorSection
        }
    }

    private func updateWindowTitle() {
        for window in NSApp.windows where window.canBecomeMain {
            if window.contentView != nil {
                window.title = L10n.t("settings.window_title")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("K-Tech PowerGuard")
                .font(.title2.bold())
            Text(L10n.t("settings.subtitle", AppMetadata.shortVersion))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var macSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t("settings.mac_title"))
                .font(.headline)
            Text(MacHardwareInfo.displayName)
                .font(.subheadline)
            Text(L10n.t("settings.mac_compat"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("settings.language"))
                .font(.headline)
            Picker("", selection: $settings.language) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(L10n.t("battery.current"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(monitor.snapshot.isPresent ? "\(monitor.snapshot.levelPercent)%" : "—")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(L10n.t("battery.state"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(chargingLabel)
                    .font(.headline)
            }
        }
        .padding()
        .background(.background.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chargingLabel: String {
        guard monitor.snapshot.isPresent else { return L10n.t("battery.unknown") }
        return monitor.snapshot.isCharging ? L10n.t("battery.charging") : L10n.t("battery.on_battery")
    }

    private var thresholdsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("thresholds.title"))
                .font(.headline)

            HStack {
                Text(L10n.t("thresholds.lower"))
                Spacer()
                Text("\(settings.lowerThreshold)%")
                    .monospacedDigit()
            }
            Slider(
                value: Binding(
                    get: { Double(settings.lowerThreshold) },
                    set: { settings.lowerThreshold = Int($0.rounded()) }
                ),
                in: 5...45,
                step: 1
            )

            HStack {
                Text(L10n.t("thresholds.upper"))
                Spacer()
                Text("\(settings.upperThreshold)%")
                    .monospacedDigit()
            }
            Slider(
                value: Binding(
                    get: { Double(settings.upperThreshold) },
                    set: { settings.upperThreshold = Int($0.rounded()) }
                ),
                in: 55...100,
                step: 1
            )

            if !settings.isValidThresholds {
                Text(L10n.t("thresholds.invalid"))
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var customColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("color.custom"))
                .font(.headline)
            ColorPicker("", selection: Binding(
                get: { settings.customAccent },
                set: { settings.applyCustomAccent($0) }
            ), supportsOpacity: false)
            .labelsHidden()
        }
    }

    private var togglesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(L10n.t("toggle.notifications"), isOn: $settings.notificationsEnabled)
            Toggle(L10n.t("toggle.login"), isOn: $settings.launchAtLogin)
                .onChange(of: settings.launchAtLogin) { _, newValue in
                    syncLoginItem(enabled: newValue)
                }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t("about.charge_limit"))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(L10n.t("about.watch"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func syncLoginItem(enabled: Bool) {
        do {
            _ = try LoginItemService.setEnabled(enabled)
        } catch {
            settings.launchAtLogin = LoginItemService.isEnabled()
        }
    }
}
