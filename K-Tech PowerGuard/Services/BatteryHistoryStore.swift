import Foundation
import Combine

@MainActor
final class BatteryHistoryStore: ObservableObject {
    static let shared = BatteryHistoryStore()

    @Published private(set) var samples: [BatterySample] = []
    @Published private(set) var chargingSessions: [ChargingSession] = []
    @Published private(set) var activeChargingSession: ChargingSession?

    private let maxSamples = 2_880
    private let maxSessions = 120
    private var lastSnapshot: BatterySnapshot?
    private var storageURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("K-Tech PowerGuard", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("battery-history.json")
    }

    private init() {
        load()
        reconcileActiveSession(with: BatteryService.currentSnapshot())
    }

    func record(_ snapshot: BatterySnapshot) {
        guard snapshot.isPresent else { return }

        let now = Date()
        if let previous = lastSnapshot {
            handleTransition(from: previous, to: snapshot, at: now)
        } else if snapshot.isCharging {
            beginSession(at: now, level: snapshot.levelPercent)
        }

        appendSample(BatterySample(date: now, levelPercent: snapshot.levelPercent, isCharging: snapshot.isCharging))
        lastSnapshot = snapshot
        save()
        objectWillChange.send()
    }

    func todayUsage() -> DailyUsageSummary {
        summarize(day: Date())
    }

    func recentSessions(limit: Int = 8) -> [ChargingSession] {
        var list = chargingSessions.sorted { $0.startDate > $1.startDate }
        if let active = activeChargingSession {
            list.removeAll { $0.id == active.id }
            list.insert(active, at: 0)
        }
        return Array(list.prefix(limit))
    }

    func levelSamples(hours: Int = 24) -> [BatterySample] {
        let cutoff = Date().addingTimeInterval(TimeInterval(-hours * 3600))
        return samples.filter { $0.date >= cutoff }
    }

    private func handleTransition(from previous: BatterySnapshot, to current: BatterySnapshot, at date: Date) {
        if !previous.isCharging && current.isCharging {
            beginSession(at: date, level: current.levelPercent)
        } else if previous.isCharging && !current.isCharging {
            endSession(at: date, level: current.levelPercent)
        }
    }

    private func beginSession(at date: Date, level: Int) {
        guard activeChargingSession == nil else { return }
        let session = ChargingSession(
            id: UUID(),
            startDate: date,
            endDate: nil,
            startLevel: level,
            endLevel: nil
        )
        activeChargingSession = session
    }

    private func endSession(at date: Date, level: Int) {
        guard var session = activeChargingSession else { return }
        session.endDate = date
        session.endLevel = level
        chargingSessions.append(session)
        trimSessions()
        activeChargingSession = nil
    }

    private func reconcileActiveSession(with snapshot: BatterySnapshot) {
        guard snapshot.isPresent else {
            if var session = activeChargingSession {
                session.endDate = Date()
                session.endLevel = snapshot.levelPercent
                chargingSessions.append(session)
                activeChargingSession = nil
                save()
            }
            return
        }

        if snapshot.isCharging {
            if activeChargingSession == nil {
                beginSession(at: Date(), level: snapshot.levelPercent)
            }
        } else if activeChargingSession != nil {
            endSession(at: Date(), level: snapshot.levelPercent)
        }
        lastSnapshot = snapshot
    }

    private func appendSample(_ sample: BatterySample) {
        samples.append(sample)
        if samples.count > maxSamples {
            samples.removeFirst(samples.count - maxSamples)
        }
    }

    private func trimSessions() {
        if chargingSessions.count > maxSessions {
            chargingSessions.removeFirst(chargingSessions.count - maxSessions)
        }
    }

    private func summarize(day: Date) -> DailyUsageSummary {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return DailyUsageSummary(onBatterySeconds: 0, chargingSeconds: 0)
        }

        let daySamples = samples.filter { $0.date >= start && $0.date < end }.sorted { $0.date < $1.date }
        guard daySamples.count >= 2 else {
            return DailyUsageSummary(onBatterySeconds: 0, chargingSeconds: 0)
        }

        var onBattery: TimeInterval = 0
        var charging: TimeInterval = 0
        for index in 0..<(daySamples.count - 1) {
            let current = daySamples[index]
            let next = daySamples[index + 1]
            let delta = next.date.timeIntervalSince(current.date)
            if current.isCharging {
                charging += delta
            } else {
                onBattery += delta
            }
        }
        return DailyUsageSummary(onBatterySeconds: onBattery, chargingSeconds: charging)
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let file = try JSONDecoder().decode(BatteryHistoryFile.self, from: data)
            samples = file.samples
            chargingSessions = file.chargingSessions.filter { !$0.isActive }
            activeChargingSession = file.chargingSessions.last(where: { $0.isActive })
        } catch {
            samples = []
            chargingSessions = []
            activeChargingSession = nil
        }
    }

    private func save() {
        var sessions = chargingSessions
        if let active = activeChargingSession {
            sessions.append(active)
        }
        let file = BatteryHistoryFile(samples: samples, chargingSessions: sessions)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            // Keep in-memory data even if persistence fails.
        }
    }
}

enum BatteryHistoryFormatting {
    static func duration(_ interval: TimeInterval) -> String {
        let totalMinutes = max(0, Int(interval / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        }
        return String(format: "%dm", minutes)
    }

    static func dateTime(_ date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
