import SwiftUI

struct BatteryHistorySection: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var monitor: BatteryMonitor
    @ObservedObject private var history = BatteryHistoryStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            usageSection
            if monitor.snapshot.isCharging, let active = history.activeChargingSession {
                activeChargingCard(active)
            }
            levelTrendSection
            chargingHistorySection
        }
    }

    private var usageSection: some View {
        let usage = history.todayUsage()
        return VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("history.usage_title"))
                .font(.headline)
            HStack {
                usageMetric(title: L10n.t("history.on_battery"), seconds: usage.onBatterySeconds)
                Spacer()
                usageMetric(title: L10n.t("history.charging"), seconds: usage.chargingSeconds)
            }
            .padding()
            .background(.background.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(L10n.t("history.usage_note"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func usageMetric(title: String, seconds: TimeInterval) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(BatteryHistoryFormatting.duration(seconds))
                .font(.title3.bold())
                .monospacedDigit()
        }
    }

    private func activeChargingCard(_ session: ChargingSession) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t("history.active_charging"))
                .font(.headline)
            HStack {
                Text(L10n.t("history.session_duration", BatteryHistoryFormatting.duration(session.duration)))
                Spacer()
                Text("\(session.startLevel)% → \(monitor.snapshot.levelPercent)%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding()
        .background(settings.theme.accent.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var levelTrendSection: some View {
        let recent = history.levelSamples(hours: 24)
        return VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("history.level_trend"))
                .font(.headline)
            if recent.isEmpty {
                Text(L10n.t("history.empty"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                LevelTrendChart(samples: recent, accent: settings.theme.accent)
                    .frame(height: 72)
                Text(L10n.t("history.level_trend_note"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var chargingHistorySection: some View {
        let sessions = history.recentSessions()
        return VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("history.charging_title"))
                .font(.headline)
            if sessions.isEmpty {
                Text(L10n.t("history.empty"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sessions) { session in
                    chargingRow(session)
                }
            }
        }
    }

    private func chargingRow(_ session: ChargingSession) -> some View {
        let locale = settings.language.locale
        let endLevel = session.endLevel ?? monitor.snapshot.levelPercent
        let status = session.isActive ? L10n.t("history.session_active") : L10n.t("history.session_done")
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(BatteryHistoryFormatting.dateTime(session.startDate, locale: locale))
                    .font(.subheadline)
                Spacer()
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(L10n.t("history.session_duration", BatteryHistoryFormatting.duration(session.duration)))
                Spacer()
                Text("\(session.startLevel)% → \(endLevel)%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.background.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct LevelTrendChart: View {
    let samples: [BatterySample]
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let count = max(samples.count, 1)
            HStack(alignment: .bottom, spacing: max(1, width / CGFloat(count) / 4)) {
                ForEach(samples) { sample in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(sample.isCharging ? accent.opacity(0.85) : Color.secondary.opacity(0.45))
                        .frame(
                            width: max(2, width / CGFloat(count) - 1),
                            height: max(4, height * CGFloat(sample.levelPercent) / 100)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
