import AppKit

final class StatusItemController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let statusMenuItem = NSMenuItem(title: "Starting", action: nil, keyEquivalent: "")
    private var openSettings: (() -> Void)?
    private var requestPermission: (() -> Void)?
    private var quit: (() -> Void)?

    func configure(
        openSettings: @escaping () -> Void,
        requestPermission: @escaping () -> Void,
        quit: @escaping () -> Void
    ) {
        self.openSettings = openSettings
        self.requestPermission = requestPermission
        self.quit = quit

        if let button = statusItem.button {
            button.image = Self.makeMenuBarIcon()
            button.imagePosition = .imageOnly
            button.title = ""
        }

        let menu = NSMenu()
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Settings...",
            action: #selector(openSettingsAction),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem(
            title: "Request Accessibility Permission",
            action: #selector(requestPermissionAction),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem(
            title: "Quit OptTab",
            action: #selector(quitAction),
            keyEquivalent: "q"
        ))

        for item in menu.items where item.action != nil {
            item.target = self
        }

        statusItem.menu = menu
    }

    func updateStatus(_ status: String) {
        statusMenuItem.title = status
    }

    private static func makeMenuBarIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()

            let frontWindow = NSBezierPath(
                roundedRect: NSRect(x: 8.5, y: 4.5, width: 7.5, height: 9),
                xRadius: 2,
                yRadius: 2
            )
            frontWindow.lineWidth = 1.8
            frontWindow.stroke()

            let chevron = NSBezierPath()
            chevron.move(to: NSPoint(x: 7, y: 14))
            chevron.line(to: NSPoint(x: 2.5, y: 9))
            chevron.line(to: NSPoint(x: 7, y: 4))
            chevron.lineWidth = 2.2
            chevron.lineCapStyle = .round
            chevron.lineJoinStyle = .round
            chevron.stroke()

            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "OptTab"
        return image
    }

    @objc private func openSettingsAction() {
        openSettings?()
    }

    @objc private func requestPermissionAction() {
        requestPermission?()
    }

    @objc private func quitAction() {
        quit?()
    }
}
