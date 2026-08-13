import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var monitor: BatteryMonitor
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        ZStack {
            SettingsWindowBackground(settings: settings)
            VStack(alignment: .leading, spacing: 14) {
                header
                SettingsTabBar(selection: $selectedTab, settings: settings)
                tabContent
                footer
            }
            .padding(20)
        }
        .frame(minWidth: 440, minHeight: 520)
        .tint(settings.theme.accent)
        .environment(\.locale, settings.language.locale)
        .onAppear(perform: updateWindowTitle)
        .onChange(of: settings.language) { _, _ in
            updateWindowTitle()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
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
            SettingsCard(settings: settings) {
                statusContent
            }
            SettingsCard(settings: settings) {
                thresholdsContent
            }
            SettingsCard(settings: settings) {
                togglesContent
            }
            SettingsCard(settings: settings) {
                aboutContent
            }
        }
    }

    private var appearanceTab: some View {
        Group {
            SettingsCard(settings: settings) {
                SettingsRow(icon: "globe", title: L10n.t("settings.language")) {
                    Picker("", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 160)
                }
            }

            SettingsCard(settings: settings) {
                SettingsRow(
                    icon: "desktopcomputer",
                    title: L10n.t("settings.mac_title"),
                    subtitle: L10n.t("settings.mac_compat")
                ) {
                    Text(MacHardwareInfo.displayName)
                        .font(.caption.weight(.medium))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 120, alignment: .trailing)
                }
            }

            SettingsCard(settings: settings) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsRow(
                        icon: "paintpalette.fill",
                        title: L10n.t("neo.title"),
                        subtitle: L10n.t("neo.subtitle")
                    ) {
                        EmptyView()
                    }
                    NeoPresetPicker(settings: settings)
                }
            }

            SettingsCard(settings: settings) {
                SettingsRow(icon: "eyedropper.halffull", title: L10n.t("color.custom")) {
                    ColorPicker("", selection: Binding(
                        get: { settings.customAccent },
                        set: { settings.applyCustomAccent($0) }
                    ), supportsOpacity: false)
                    .labelsHidden()
                }
            }

            SettingsCard(settings: settings) {
                VStack(alignment: .leading, spacing: 10) {
                    SettingsRow(
                        icon: "square.on.square.dashed",
                        title: L10n.t("glass.title"),
                        subtitle: L10n.t("glass.subtitle")
                    ) {
                        EmptyView()
                    }
                    GlassIntensityPicker(settings: settings)
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(settings.theme.accent)
            Text(L10n.t("settings.footer_hint"))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text("K-Tech")
                .font(.caption.weight(.semibold))
                .foregroundStyle(settings.theme.accent)
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

    private var statusContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.t("battery.current"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(monitor.snapshot.isPresent ? "\(monitor.snapshot.levelPercent)%" : "—")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(L10n.t("battery.state"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(chargingLabel)
                    .font(.headline)
            }
        }
    }

    private var chargingLabel: String {
        guard monitor.snapshot.isPresent else { return L10n.t("battery.unknown") }
        return monitor.snapshot.isCharging ? L10n.t("battery.charging") : L10n.t("battery.on_battery")
    }

    private var thresholdsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("thresholds.title"))
                .font(.subheadline.weight(.semibold))

            thresholdRow(
                label: L10n.t("thresholds.lower"),
                value: settings.lowerThreshold,
                binding: Binding(
                    get: { Double(settings.lowerThreshold) },
                    set: { settings.lowerThreshold = Int($0.rounded()) }
                ),
                range: 5...45
            )

            thresholdRow(
                label: L10n.t("thresholds.upper"),
                value: settings.upperThreshold,
                binding: Binding(
                    get: { Double(settings.upperThreshold) },
                    set: { settings.upperThreshold = Int($0.rounded()) }
                ),
                range: 55...100
            )

            if !settings.isValidThresholds {
                Text(L10n.t("thresholds.invalid"))
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func thresholdRow(label: String, value: Int, binding: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text("\(value)%")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            Slider(value: binding, in: range, step: 1)
        }
    }

    private var togglesContent: some View {
        VStack(spacing: 8) {
            SettingsRow(icon: "bell.fill", title: L10n.t("toggle.notifications")) {
                Toggle("", isOn: $settings.notificationsEnabled)
                    .labelsHidden()
            }
            Divider()
            SettingsRow(icon: "power", title: L10n.t("toggle.login")) {
                Toggle("", isOn: $settings.launchAtLogin)
                    .labelsHidden()
            }
        }
        .onChange(of: settings.launchAtLogin) { _, newValue in
            syncLoginItem(enabled: newValue)
        }
    }

    private var aboutContent: some View {
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
