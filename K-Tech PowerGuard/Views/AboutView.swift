import SwiftUI
import AppKit

struct AboutView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 16) {
            appIconImage
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

            Text("K-Tech PowerGuard")
                .font(.title3.bold())

            Text(L10n.t("about.version_line", AppMetadata.shortVersion))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(L10n.t("about.tagline"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Button {
                    openURL(AppMetadata.studioHomeURL)
                } label: {
                    Text(L10n.t("about.open_studio"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(settings.theme.accent)

                Link(L10n.t("about.open_releases"), destination: AppMetadata.releasesURL)
                    .font(.caption)
            }
            .padding(.top, 4)
        }
        .padding(28)
        .frame(minWidth: 340, minHeight: 300)
        .background(settings.theme.background)
        .onAppear(perform: updateWindowTitle)
        .onChange(of: settings.language) { _, _ in
            updateWindowTitle()
        }
    }

    @ViewBuilder
    private var appIconImage: some View {
        if let image = NSApplication.shared.applicationIconImage {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "battery.100")
                .font(.system(size: 48))
                .foregroundStyle(settings.theme.accent)
        }
    }

    private func updateWindowTitle() {
        for window in NSApp.windows where window.canBecomeMain {
            if window.contentView != nil {
                window.title = L10n.t("about.window_title")
            }
        }
    }
}
