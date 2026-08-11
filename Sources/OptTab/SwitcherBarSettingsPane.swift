import AppKit
import ImageIO
import SwiftUI

struct SwitcherBarSettingsPane: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        Form {
            Section {
                SwitcherBarPreview(settings: settings)
            } header: {
                Text("Preview")
            } footer: {
                Text("Hover an icon to try the highlight. Nothing is activated from this preview.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Appearance") {
                SettingsRow(
                    symbol: "text.below.photo",
                    tint: .orange,
                    title: "Show app names",
                    detail: "Draws each app's name under its icon."
                ) {
                    Toggle("Show app names", isOn: $settings.showAppNames)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }

                SettingsRow(
                    symbol: "eye.slash",
                    tint: .brown,
                    title: "Hide fixed apps from bar",
                    detail: "Their keys keep working while they stay out of the bar."
                ) {
                    Toggle("Hide fixed apps from bar", isOn: $settings.hidesFixedAppsInSwitcher)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }

            Section("Mouse") {
                SettingsRow(
                    symbol: "cursorarrow.motionlines",
                    tint: .pink,
                    title: "Switch to hovered app",
                    detail: "Releasing the trigger switches to the app under the pointer. Clicking always switches; turning this off also removes the hover highlight."
                ) {
                    Toggle("Switch to hovered app", isOn: $settings.activatesHoveredApp)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }

            Section("After switching") {
                SettingsRow(
                    symbol: "rectangle.slash",
                    tint: .blue,
                    title: "Close bar after switching",
                    detail: "Off keeps the bar open so you can jump again while still holding the trigger."
                ) {
                    Toggle("Close bar after switching", isOn: $settings.closeAfterSelection)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }
        }
        .formStyle(.grouped)
    }
}

/// Renders the real switcher bar so the preview cannot drift from what the bar draws.
private struct SwitcherBarPreview: View {
    @ObservedObject var settings: AppSettings

    private static let previewWidth: CGFloat = 380
    private static let itemLimit = 4

    @State private var items: [SwitcherItem] = []
    @State private var wallpaper: NSImage?

    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No apps to preview yet.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(height: 96)
            } else {
                SwitcherBarView(
                    items: items,
                    showsAppNames: settings.showAppNames,
                    activatesHoveredApp: settings.activatesHoveredApp,
                    metrics: metrics,
                    onSelect: { _ in },
                    onPreselectionChange: { _ in }
                )
                .frame(width: metrics.panelWidth, height: metrics.panelHeight)
                .shadow(color: .black.opacity(0.28), radius: 12, y: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(desktopBackdrop)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.vertical, 4)
        .onAppear(perform: loadItems)
    }

    /// The bar is translucent, so the preview only tells the truth over the real desktop.
    @ViewBuilder
    private var desktopBackdrop: some View {
        if let wallpaper {
            Image(nsImage: wallpaper)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            LinearGradient(
                colors: [Color(white: 0.42), Color(white: 0.26)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var metrics: SwitcherBarMetrics {
        SwitcherBarMetrics.make(
            itemCount: items.count,
            availableWidth: Self.previewWidth,
            showsAppNames: settings.showAppNames
        )
    }

    private func loadItems() {
        loadWallpaper()

        guard items.isEmpty else { return }

        let apps = DockAppProvider().loadApps(source: settings.appSource).prefix(Self.itemLimit)
        let bindings = KeyBinding.bindings(for: settings.keyOrder, layout: settings.keyboardLayout)

        items = zip(apps, bindings).map { SwitcherItem(app: $0, keyBinding: $1) }
    }

    private func loadWallpaper() {
        guard wallpaper == nil, let screen = NSScreen.main,
              let url = NSWorkspace.shared.desktopImageURL(for: screen) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let image = DesktopWallpaperLoader.thumbnail(at: url, maxPixelSize: 1200)
            DispatchQueue.main.async { wallpaper = image }
        }
    }
}

/// Wallpapers are full-resolution HEIC files, so the stage only ever needs a thumbnail.
private enum DesktopWallpaperLoader {
    static func thumbnail(at url: URL, maxPixelSize: Int) -> NSImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let image = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            options as CFDictionary
        ) else {
            return nil
        }

        return NSImage(cgImage: image, size: .zero)
    }
}
