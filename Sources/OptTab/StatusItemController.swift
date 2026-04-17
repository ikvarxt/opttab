import AppKit

final class StatusItemController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusMenuItem = NSMenuItem(title: "Starting", action: nil, keyEquivalent: "")
    private var requestPermission: (() -> Void)?
    private var quit: (() -> Void)?

    func configure(requestPermission: @escaping () -> Void, quit: @escaping () -> Void) {
        self.requestPermission = requestPermission
        self.quit = quit

        statusItem.button?.title = "OptTab"

        let menu = NSMenu()
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())
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

    @objc private func requestPermissionAction() {
        requestPermission?()
    }

    @objc private func quitAction() {
        quit?()
    }
}
