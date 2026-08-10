import Foundation

enum AppMetadata {
    static let studioHomeURL = URL(string: "https://k-tech-lab.vercel.app/")!
    static let releasesURL = URL(string: "https://github.com/crossbeat461-a11y/K-Tech-PowerGuard/releases")!

    static var shortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.1"
    }
}
