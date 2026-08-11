import Foundation

enum MacHardwareInfo {
    static let modelIdentifier: String = sysctlString("hw.model") ?? "Unknown"
    static let chipName: String? = chipDisplayName

    static var displayName: String {
        let model = marketingName(for: modelIdentifier)
        guard let chip = chipName else { return model }
        return "\(model) · \(chip)"
    }

    private static var chipDisplayName: String? {
        guard let brand = sysctlString("machdep.cpu.brand_string"), !brand.isEmpty else { return nil }
        if brand.hasPrefix("Apple ") {
            return String(brand.dropFirst("Apple ".count))
        }
        return brand
    }

    private static func sysctlString(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 1 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        return String(cString: buffer)
    }

    private static let knownModels: [String: String] = [
        "Mac16,10": "MacBook Neo",
        "Mac16,11": "MacBook Neo",
        "Mac16,12": "MacBook Neo",
        "Mac16,13": "MacBook Neo",
        "Mac15,12": "MacBook Air",
        "Mac15,13": "MacBook Air",
        "Mac14,15": "MacBook Air",
        "Mac14,2": "MacBook Pro",
        "Mac14,5": "MacBook Pro",
        "Mac14,6": "MacBook Pro",
        "Mac14,7": "MacBook Pro",
        "Mac14,9": "MacBook Pro",
        "Mac14,10": "MacBook Pro",
        "Mac15,3": "MacBook Pro",
        "Mac15,6": "MacBook Pro",
        "Mac15,7": "MacBook Pro",
        "Mac15,8": "MacBook Pro",
        "Mac15,9": "MacBook Pro",
        "Mac15,10": "MacBook Pro",
        "Mac15,11": "MacBook Pro",
        "Mac14,3": "Mac mini",
        "Mac14,12": "Mac mini",
        "Mac16,1": "Mac mini",
        "Mac16,2": "Mac mini",
        "Mac13,1": "Mac Studio",
        "Mac13,2": "Mac Studio",
        "Mac14,13": "Mac Studio",
        "Mac14,14": "Mac Studio",
        "Mac15,14": "Mac Studio",
        "Mac14,8": "Mac Pro",
        "Mac15,4": "iMac",
        "Mac15,5": "iMac"
    ]

    static func marketingName(for identifier: String) -> String {
        if let name = knownModels[identifier] { return name }
        if identifier.hasPrefix("MacBookAir") { return "MacBook Air" }
        if identifier.hasPrefix("MacBookPro") { return "MacBook Pro" }
        if identifier.hasPrefix("Macmini") { return "Mac mini" }
        if identifier.hasPrefix("iMac") { return "iMac" }
        if identifier.hasPrefix("MacPro") { return "Mac Pro" }
        if identifier.hasPrefix("Mac") { return "Mac" }
        return identifier
    }
}
