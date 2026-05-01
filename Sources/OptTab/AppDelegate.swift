import AppKit
import ApplicationServices
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private let appProvider = DockAppProvider()
    private let overlayController = OverlayController()
    private lazy var hotkeyController = HotkeyController(settings: settings)
    private lazy var settingsWindowController = SettingsWindowController(settings: settings)
    private let statusItemController = StatusItemController()
    private var settingsCancellables: Set<AnyCancellable> = []
    private var permissionRetryTimer: Timer?
    private var visibleItems: [SwitcherItem] = []
    private var isKeyboardListenerRunning = false
    private var lastActivatedAppID: String?
    private var windowCycleIndexByAppID: [String: Int] = [:]
    private var currentDynamicKeyCodeByAppID: [String: CGKeyCode] = [:]
    private var preferredDynamicKeyCodeByAppID: [String: CGKeyCode] = [:]

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        hotkeyController.delegate = self
        statusItemController.configure(
            openSettings: { [weak self] in self?.openSettings() },
            requestPermission: { [weak self] in self?.requestAccessibilityPermission() },
            quit: { NSApp.terminate(nil) }
        )
        observeSettings()

        startKeyboardListenerIfPermitted()
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionRetryTimer?.invalidate()
        hotkeyController.stop()
    }

    private func startKeyboardListenerIfPermitted() {
        guard AccessibilityPermission.isTrusted(prompt: false) else {
            isKeyboardListenerRunning = false
            statusItemController.updateStatus("Waiting for Accessibility permission")
            schedulePermissionRetry()
            return
        }

        if hotkeyController.start() {
            isKeyboardListenerRunning = true
            updateReadyStatus()
            permissionRetryTimer?.invalidate()
            permissionRetryTimer = nil
        } else {
            isKeyboardListenerRunning = false
            statusItemController.updateStatus("Keyboard listener could not start")
            schedulePermissionRetry()
        }
    }

    private func schedulePermissionRetry() {
        guard permissionRetryTimer == nil else { return }

        permissionRetryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }
            if AccessibilityPermission.isTrusted(prompt: false) {
                self.startKeyboardListenerIfPermitted()
            }
        }
    }

    private func requestAccessibilityPermission() {
        if AccessibilityPermission.isTrusted(prompt: true) {
            startKeyboardListenerIfPermitted()
        } else {
            statusItemController.updateStatus("Waiting for Accessibility permission")
            schedulePermissionRetry()
        }
    }

    private func openSettings() {
        settingsWindowController.show()
    }

    private func observeSettings() {
        settings.$triggerKey
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateReadyStatus()
            }
            .store(in: &settingsCancellables)

        settings.$fixedAppShortcuts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.currentDynamicKeyCodeByAppID.removeAll()
            }
            .store(in: &settingsCancellables)
    }

    private func updateReadyStatus() {
        guard isKeyboardListenerRunning else { return }
        statusItemController.updateStatus("Hold \(settings.triggerKey.label), then press a letter")
    }

    private func reloadVisibleItems() {
        let apps = appProvider.loadApps(source: settings.appSource)
        let bindings = KeyBinding.bindings(
            for: settings.keyOrder,
            layout: settings.keyboardLayout
        )
        var fixedItems: [SwitcherItem] = []
        var usedAppIDs = Set<String>()
        var usedKeyCodes = Set<CGKeyCode>()

        for shortcut in settings.fixedAppShortcuts {
            guard
                let app = appProvider.loadFixedApp(shortcut: shortcut),
                let binding = KeyBinding.binding(
                    for: shortcut.keyLabel,
                    layout: settings.keyboardLayout
                ),
                !usedAppIDs.contains(app.id),
                !usedKeyCodes.contains(binding.keyCode)
            else {
                continue
            }

            fixedItems.append(SwitcherItem(app: app, keyBinding: binding))
            usedAppIDs.insert(app.id)
            usedKeyCodes.insert(binding.keyCode)
        }

        let dynamicApps = apps.filter { !usedAppIDs.contains($0.id) }
        let dynamicBindings = bindings.filter { !usedKeyCodes.contains($0.keyCode) }
        let dynamicBindingByAppID = stableDynamicBindings(
            apps: dynamicApps,
            availableBindings: dynamicBindings
        )
        let dynamicItems = dynamicApps.compactMap { app -> SwitcherItem? in
            guard let binding = dynamicBindingByAppID[app.id] else {
                return nil
            }

            return SwitcherItem(app: app, keyBinding: binding)
        }

        visibleItems = fixedItems + dynamicItems
    }

    private func stableDynamicBindings(
        apps: [DockApp],
        availableBindings: [KeyBinding]
    ) -> [String: KeyBinding] {
        let availableKeyCodes = Set(availableBindings.map(\.keyCode))
        let bindingByKeyCode = Dictionary(uniqueKeysWithValues: availableBindings.map { ($0.keyCode, $0) })
        var assignedKeyCodeByAppID: [String: CGKeyCode] = [:]
        var reservedKeyCodes = Set<CGKeyCode>()

        for app in apps {
            guard
                let keyCode = currentDynamicKeyCodeByAppID[app.id],
                availableKeyCodes.contains(keyCode),
                !reservedKeyCodes.contains(keyCode)
            else {
                continue
            }

            assignedKeyCodeByAppID[app.id] = keyCode
            reservedKeyCodes.insert(keyCode)
        }

        for app in apps where assignedKeyCodeByAppID[app.id] == nil {
            guard
                let keyCode = preferredDynamicKeyCodeByAppID[app.id],
                availableKeyCodes.contains(keyCode),
                !reservedKeyCodes.contains(keyCode)
            else {
                continue
            }

            assignedKeyCodeByAppID[app.id] = keyCode
            reservedKeyCodes.insert(keyCode)
        }

        var unassignedBindings = availableBindings.filter { !reservedKeyCodes.contains($0.keyCode) }
        for app in apps where assignedKeyCodeByAppID[app.id] == nil {
            guard !unassignedBindings.isEmpty else {
                break
            }

            let binding = unassignedBindings.removeFirst()
            assignedKeyCodeByAppID[app.id] = binding.keyCode
            reservedKeyCodes.insert(binding.keyCode)
        }

        currentDynamicKeyCodeByAppID = assignedKeyCodeByAppID
        for (appID, keyCode) in assignedKeyCodeByAppID {
            preferredDynamicKeyCodeByAppID[appID] = keyCode
        }

        return assignedKeyCodeByAppID.reduce(into: [String: KeyBinding]()) { result, entry in
            guard let binding = bindingByKeyCode[entry.value] else {
                return
            }

            result[entry.key] = binding
        }
    }
}

extension AppDelegate: HotkeyControllerDelegate {
    func hotkeyDidPress() {
        DispatchQueue.main.async {
            self.resetWindowCycleState()
            self.reloadVisibleItems()
            guard !self.visibleItems.isEmpty else { return }
            self.overlayController.show(
                items: self.visibleItems,
                showsAppNames: self.settings.showAppNames
            )
        }
    }

    func hotkeyDidRelease() {
        DispatchQueue.main.async {
            self.overlayController.hide()
            self.visibleItems = []
            self.resetWindowCycleState()
        }
    }

    func hotkeyDidReceiveKeyCode(_ keyCode: CGKeyCode) {
        DispatchQueue.main.async {
            guard let item = self.visibleItems.first(where: { $0.keyBinding.keyCode == keyCode }) else {
                return
            }

            let preferredWindowIndex = self.preferredWindowIndex(for: item)
            self.appProvider.activate(
                item.app,
                windowBehavior: self.settings.windowActivationBehavior,
                preferredWindowIndex: preferredWindowIndex
            )
            if self.settings.closeAfterSelection {
                self.overlayController.hide()
                self.visibleItems = []
                self.resetWindowCycleState()
            }
        }
    }

    private func preferredWindowIndex(for item: SwitcherItem) -> Int {
        guard settings.windowActivationBehavior == .focusOneAndCycle else {
            lastActivatedAppID = item.app.id
            return 0
        }

        if lastActivatedAppID == item.app.id {
            let nextIndex = (windowCycleIndexByAppID[item.app.id] ?? 0) + 1
            windowCycleIndexByAppID[item.app.id] = nextIndex
            return nextIndex
        }

        lastActivatedAppID = item.app.id
        windowCycleIndexByAppID[item.app.id] = 0
        return 0
    }

    private func resetWindowCycleState() {
        lastActivatedAppID = nil
        windowCycleIndexByAppID.removeAll()
        appProvider.resetWindowCycleSnapshots()
    }
}
