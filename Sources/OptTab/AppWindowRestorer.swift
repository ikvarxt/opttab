import ApplicationServices
import AppKit

enum AppWindowRestorer {
    static func restoreWindows(for runningApp: NSRunningApplication) -> Bool {
        let application = AXUIElementCreateApplication(runningApp.processIdentifier)
        let windows = windows(for: application)

        guard !windows.isEmpty else {
            return false
        }

        for window in windows {
            restore(window)
        }

        return true
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

    private static func restore(_ window: AXUIElement) {
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
