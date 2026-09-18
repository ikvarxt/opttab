import ApplicationServices
import AppKit
import CoreGraphics

enum AppWindowRestorer {
    struct Result {
        let windowCount: Int
        let focusedWindow: AXUIElement?

        var hasWindows: Bool {
            windowCount > 0
        }

        static let noWindows = Result(windowCount: 0, focusedWindow: nil)
    }

    struct WindowList {
        let windows: [AXUIElement]
        /// The AX query itself errored, so `windows` being empty says nothing about the app.
        let lookupFailed: Bool
    }

    static func focusWindow(
        for runningApp: NSRunningApplication,
        preferredWindowIndex: Int
    ) -> Result {
        let windows = orderedWindows(for: runningApp)

        guard let window = windows[safe: preferredWindowIndex.modulo(windows.count)] else {
            return .noWindows
        }

        focus(window)
        return Result(windowCount: windows.count, focusedWindow: window)
    }

    static func focusWindow(_ window: AXUIElement, windowCount: Int) -> Result {
        focus(window)
        return Result(windowCount: windowCount, focusedWindow: window)
    }

    static func restoreAllWindows(for runningApp: NSRunningApplication) -> Result {
        let windows = orderedWindows(for: runningApp)

        guard !windows.isEmpty else {
            return .noWindows
        }

        for window in windows {
            focus(window)
        }

        return Result(windowCount: windows.count, focusedWindow: windows.last)
    }

    static func orderedWindows(for runningApp: NSRunningApplication) -> [AXUIElement] {
        orderedWindowList(for: runningApp).windows
    }

    static func orderedWindowList(for runningApp: NSRunningApplication) -> WindowList {
        let application = AXUIElementCreateApplication(runningApp.processIdentifier)
        return orderedWindowList(for: application)
    }

    /// Answers before the app has built its AX tree, and needs no Accessibility permission.
    /// Only ever a veto: the window server reports the current Space, so a false here can still
    /// mean a window sits on another Space or minimized, and AX stays the authority on that.
    static func hasOnScreenWindows(pid: pid_t) -> Bool {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]

        guard
            let entries = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]]
        else {
            return false
        }

        return entries.contains { entry in
            (entry[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value == pid
                && (entry[kCGWindowLayer as String] as? NSNumber)?.intValue == 0
        }
    }

    private static func windows(for application: AXUIElement) -> WindowList {
        var rawValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(
            application,
            kAXWindowsAttribute as CFString,
            &rawValue
        )

        guard error == .success else {
            NSLog("OptTab: AX window query failed with error \(error.rawValue)")
            return WindowList(windows: [], lookupFailed: true)
        }

        return WindowList(windows: rawValue as? [AXUIElement] ?? [], lookupFailed: false)
    }

    private static func orderedWindowList(for application: AXUIElement) -> WindowList {
        let lookup = windows(for: application)
        let visibleWindows = lookup.windows.filter { !isMinimized($0) }
        let minimizedWindows = lookup.windows.filter { isMinimized($0) }
        return WindowList(
            windows: visibleWindows + minimizedWindows,
            lookupFailed: lookup.lookupFailed
        )
    }

    private static func focus(_ window: AXUIElement) {
        if isMinimized(window) {
            AXUIElementSetAttributeValue(
                window,
                kAXMinimizedAttribute as CFString,
                kCFBooleanFalse
            )
        }

        AXUIElementSetAttributeValue(
            window,
            kAXMainAttribute as CFString,
            kCFBooleanTrue
        )
        AXUIElementSetAttributeValue(
            window,
            kAXFocusedAttribute as CFString,
            kCFBooleanTrue
        )
        AXUIElementPerformAction(window, kAXRaiseAction as CFString)
    }

    private static func isMinimized(_ window: AXUIElement) -> Bool {
        var rawValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(
            window,
            kAXMinimizedAttribute as CFString,
            &rawValue
        )

        guard error == .success else {
            return false
        }

        return (rawValue as? Bool) == true
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }
}

private extension Int {
    func modulo(_ divisor: Int) -> Int {
        guard divisor > 0 else {
            return 0
        }

        let remainder = self % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }
}
