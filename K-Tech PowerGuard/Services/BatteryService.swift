import Foundation
import IOKit
import IOKit.ps

struct BatterySnapshot: Equatable {
    let levelPercent: Int
    let isCharging: Bool
    let isPresent: Bool
}

enum BatteryService {
    static func currentSnapshot() -> BatterySnapshot {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any]
        else {
            return BatterySnapshot(levelPercent: 0, isCharging: false, isPresent: false)
        }

        let capacity = description[kIOPSCurrentCapacityKey] as? Int ?? 0
        let maxCapacity = description[kIOPSMaxCapacityKey] as? Int ?? 100
        let percent = maxCapacity > 0 ? Int((Double(capacity) / Double(maxCapacity)) * 100) : 0
        let state = description[kIOPSPowerSourceStateKey] as? String ?? ""
        let isCharging = (description[kIOPSIsChargingKey] as? Bool)
            ?? (state == kIOPSACPowerValue)

        return BatterySnapshot(levelPercent: min(100, max(0, percent)), isCharging: isCharging, isPresent: true)
    }
}
