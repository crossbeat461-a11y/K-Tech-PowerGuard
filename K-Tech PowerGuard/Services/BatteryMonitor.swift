import Foundation
import Combine

@MainActor
final class BatteryMonitor: ObservableObject {
    @Published private(set) var snapshot = BatteryService.currentSnapshot()

    private var timer: Timer?
    private var lastLowNotify: Date?
    private var lastHighNotify: Date?
    private let cooldown: TimeInterval = 30 * 60

    private var wasBelowLower = false
    private var wasAboveUpper = false

    func start(settings: AppSettings) {
        timer?.invalidate()
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let settings = AppSettings.shared
        snapshot = BatteryService.currentSnapshot()
        guard snapshot.isPresent, settings.notificationsEnabled, settings.isValidThresholds else { return }

        let lower = settings.lowerThreshold
        let upper = settings.upperThreshold
        let level = snapshot.levelPercent

        if !snapshot.isCharging && level <= lower {
            if !wasBelowLower, shouldFire(last: lastLowNotify) {
                NotificationService.notify(
                    title: "K-Tech PowerGuard",
                    body: L10n.t("notify.low_body", level, lower)
                )
                lastLowNotify = Date()
            }
            wasBelowLower = true
        } else if level > lower + 3 {
            wasBelowLower = false
        }

        if snapshot.isCharging && level >= upper {
            if !wasAboveUpper, shouldFire(last: lastHighNotify) {
                NotificationService.notify(
                    title: "K-Tech PowerGuard",
                    body: L10n.t("notify.high_body", level, upper)
                )
                lastHighNotify = Date()
            }
            wasAboveUpper = true
        } else if level < upper - 3 {
            wasAboveUpper = false
        }
    }

    private func shouldFire(last: Date?) -> Bool {
        guard let last else { return true }
        return Date().timeIntervalSince(last) >= cooldown
    }
}
