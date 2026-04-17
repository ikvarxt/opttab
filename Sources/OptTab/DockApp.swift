import AppKit

struct DockApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let url: URL
    let isRunning: Bool

    var icon: NSImage {
        let image = NSWorkspace.shared.icon(forFile: url.path)
        image.size = NSSize(width: 64, height: 64)
        return image
    }
}
