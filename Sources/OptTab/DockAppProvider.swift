import AppKit
import Foundation

final class DockAppProvider {
    func loadApps(source: AppSource) -> [DockApp] {
        switch source {
        case .dockAndRunning:
            return deduplicate(loadPinnedDockApps() + loadRunningApps())
        case .dockOnly:
            return deduplicate(loadPinnedDockApps())
        case .runningOnly:
            return deduplicate(loadRunningApps())
        }
    }

    private func deduplicate(_ candidates: [DockApp]) -> [DockApp] {
        var apps: [DockApp] = []
        var seen = Set<String>()

        for app in candidates {
            guard !seen.contains(app.id) else { continue }
            seen.insert(app.id)
            apps.append(app)
        }

        return apps
    }

    func activate(_ app: DockApp) {
        if let runningApp = runningApplication(for: app) {
            runningApp.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: app.url, configuration: configuration) { _, error in
            if let error {
                NSLog("OptTab: failed to open \(app.url.path): \(error.localizedDescription)")
            }
        }
    }

    private func loadPinnedDockApps() -> [DockApp] {
        let dockPreferencesURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/com.apple.dock.plist")

        guard
            let dictionary = NSDictionary(contentsOf: dockPreferencesURL) as? [String: Any],
            let persistentApps = dictionary["persistent-apps"] as? [[String: Any]]
        else {
            return []
        }

        return persistentApps.compactMap { tile in
            guard
                let tileData = tile["tile-data"] as? [String: Any],
                let url = appURL(from: tileData)
            else {
                return nil
            }

            return makeDockApp(
                url: url,
                fallbackName: tileData["file-label"] as? String,
                runningApp: runningApplication(bundleURL: url)
            )
        }
    }

    private func loadRunningApps() -> [DockApp] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { runningApp in
                guard let url = runningApp.bundleURL else { return nil }
                return makeDockApp(
                    url: url,
                    fallbackName: runningApp.localizedName,
                    runningApp: runningApp
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func appURL(from tileData: [String: Any]) -> URL? {
        guard
            let fileData = tileData["file-data"] as? [String: Any],
            let urlString = fileData["_CFURLString"] as? String
        else {
            return nil
        }

        if urlString.hasPrefix("file://") {
            return URL(string: urlString)?.standardizedFileURL
        }

        if urlString.hasPrefix("/") {
            return URL(fileURLWithPath: urlString).standardizedFileURL
        }

        return nil
    }

    private func makeDockApp(url: URL, fallbackName: String?, runningApp: NSRunningApplication?) -> DockApp {
        let bundle = Bundle(url: url)
        let bundleIdentifier = runningApp?.bundleIdentifier ?? bundle?.bundleIdentifier
        let displayName = runningApp?.localizedName
            ?? fallbackName
            ?? bundleDisplayName(bundle: bundle)
            ?? FileManager.default.displayName(atPath: url.path)
                .replacingOccurrences(of: ".app", with: "")

        let id = bundleIdentifier ?? url.standardizedFileURL.path

        return DockApp(
            id: id,
            name: displayName,
            bundleIdentifier: bundleIdentifier,
            url: url,
            isRunning: runningApp != nil
        )
    }

    private func bundleDisplayName(bundle: Bundle?) -> String? {
        guard let bundle else { return nil }
        return bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    private func runningApplication(for app: DockApp) -> NSRunningApplication? {
        if let bundleIdentifier = app.bundleIdentifier {
            return NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first
        }

        return runningApplication(bundleURL: app.url)
    }

    private func runningApplication(bundleURL: URL) -> NSRunningApplication? {
        let standardizedPath = bundleURL.standardizedFileURL.path
        return NSWorkspace.shared.runningApplications.first { runningApp in
            runningApp.bundleURL?.standardizedFileURL.path == standardizedPath
        }
    }
}
