import ApplicationServices
import AppKit

enum AppWindowRestorer {
    struct Result {
        let windowCount: Int
        let focusedWindow: AXUIElement?

        var hasWindows: Bool {
            windowCount > 0
        }

        static let noWindows = Result(windowCount: 0, focusedWindow: nil)
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
        let application = AXUIElementCreateApplication(runningApp.processIdentifier)
        return orderedWindows(for: application)
    }

    private static func windows(for application: AXUIElement) -> [AXUIElement] {
        var rawValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(
            application,
            kAXWindowsAttribute as CFString,
            &rawValue
        )

        guard error == .success else {
            return []
        }

        return rawValue as? [AXUIElement] ?? []
    }

    private static func orderedWindows(for application: AXUIElement) -> [AXUIElement] {
        let windows = windows(for: application)
        let visibleWindows = windows.filter { !isMinimized($0) }
        let minimizedWindows = windows.filter { isMinimized($0) }
        return visibleWindows + minimizedWindows
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
