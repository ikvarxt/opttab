import AppKit

struct DockApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let url: URL
    let isRunning: Bool

    var icon: NSImage {
        let image = DockAppIconProvider.icon(for: url, appName: name)
        image.size = NSSize(width: 64, height: 64)
        return image
    }
}

enum DockAppIconProvider {
    static func icon(for appURL: URL, appName: String) -> NSImage {
        if let iconURL = companionIconURL(for: appURL, appName: appName),
           let image = NSImage(contentsOf: iconURL) {
            return image
        }

        return NSWorkspace.shared.icon(forFile: appURL.path)
    }

    static func companionIconURL(
        for executableURL: URL,
        appName: String,
        fileExists: (String) -> Bool = FileManager.default.fileExists(atPath:)
    ) -> URL? {
        let binDirectory = executableURL.deletingLastPathComponent()
        guard binDirectory.lastPathComponent == "bin" else {
            return nil
        }

        let installRoot = binDirectory.deletingLastPathComponent()
        let iconNames = [
            executableURL.deletingPathExtension().lastPathComponent,
            appName.lowercased()
        ].reduce(into: [String]()) { names, candidate in
            guard !candidate.isEmpty,
                  !candidate.contains("/"),
                  !names.contains(candidate) else {
                return
            }
            names.append(candidate)
        }

        let relativeDirectories = [
            "share/icons/hicolor/512x512/apps",
            "share/icons/hicolor/256x256/apps",
            "share/icons/hicolor/128x128/apps",
            "share/icons/hicolor/64x64/apps",
            "share/icons/hicolor/48x48/apps",
            "share/pixmaps"
        ]

        for directory in relativeDirectories {
            for iconName in iconNames {
                for pathExtension in ["png", "icns"] {
                    let candidate = installRoot
                        .appendingPathComponent(directory, isDirectory: true)
                        .appendingPathComponent(iconName)
                        .appendingPathExtension(pathExtension)

                    if fileExists(candidate.path) {
                        return candidate
                    }
                }
            }
        }

        return nil
    }
}
