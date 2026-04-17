import AppKit
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appProvider = DockAppProvider()
    private let overlayController = OverlayController()
    private let hotkeyController = HotkeyController()
    private let statusItemController = StatusItemController()
    private var permissionRetryTimer: Timer?
    private var visibleItems: [SwitcherItem] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        hotkeyController.delegate = self
        statusItemController.configure(
            requestPermission: { [weak self] in self?.requestAccessibilityPermission() },
            quit: { NSApp.terminate(nil) }
        )

        startKeyboardListenerOrPrompt()
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionRetryTimer?.invalidate()
        hotkeyController.stop()
    }

    private func startKeyboardListenerOrPrompt() {
        guard AccessibilityPermission.isTrusted(prompt: true) else {
            statusItemController.updateStatus("Waiting for Accessibility permission")
            schedulePermissionRetry()
            return
        }

        if hotkeyController.start() {
            statusItemController.updateStatus("Hold Left Option, then press a letter")
            permissionRetryTimer?.invalidate()
            permissionRetryTimer = nil
        } else {
            statusItemController.updateStatus("Keyboard listener could not start")
            schedulePermissionRetry()
        }
    }

    private func schedulePermissionRetry() {
        guard permissionRetryTimer == nil else { return }

        permissionRetryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }
            if AccessibilityPermission.isTrusted(prompt: false) {
                self.startKeyboardListenerOrPrompt()
            }
        }
    }

    private func requestAccessibilityPermission() {
        _ = AccessibilityPermission.isTrusted(prompt: true)
    }

    private func reloadVisibleItems() {
        let apps = appProvider.loadDockVisibleApps()
        visibleItems = zip(KeyBinding.defaultBindings, apps).map { binding, app in
            SwitcherItem(app: app, keyBinding: binding)
        }
    }
}

extension AppDelegate: HotkeyControllerDelegate {
    func hotkeyDidPress() {
        DispatchQueue.main.async {
            self.reloadVisibleItems()
            guard !self.visibleItems.isEmpty else { return }
            self.overlayController.show(items: self.visibleItems)
        }
    }

    func hotkeyDidRelease() {
        DispatchQueue.main.async {
            self.overlayController.hide()
            self.visibleItems = []
        }
    }

    func hotkeyDidReceiveKeyCode(_ keyCode: CGKeyCode) {
        DispatchQueue.main.async {
            guard let item = self.visibleItems.first(where: { $0.keyBinding.keyCode == keyCode }) else {
                return
            }

            self.appProvider.activate(item.app)
        }
    }
}
