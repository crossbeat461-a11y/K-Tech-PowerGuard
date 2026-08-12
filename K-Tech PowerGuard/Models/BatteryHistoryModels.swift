import Foundation

struct BatterySample: Codable, Equatable, Identifiable {
    let id: UUID
    let date: Date
    let levelPercent: Int
    let isCharging: Bool

    init(id: UUID = UUID(), date: Date, levelPercent: Int, isCharging: Bool) {
        self.id = id
        self.date = date
        self.levelPercent = levelPercent
        self.isCharging = isCharging
    }
}

struct ChargingSession: Codable, Equatable, Identifiable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    let startLevel: Int
    var endLevel: Int?

    var isActive: Bool { endDate == nil }

    var duration: TimeInterval {
        let end = endDate ?? Date()
        return max(0, end.timeIntervalSince(startDate))
    }
}

struct DailyUsageSummary: Equatable {
    let onBatterySeconds: TimeInterval
    let chargingSeconds: TimeInterval

    var totalSeconds: TimeInterval { onBatterySeconds + chargingSeconds }
}

struct BatteryHistoryFile: Codable {
    var samples: [BatterySample]
    var chargingSessions: [ChargingSession]
}
