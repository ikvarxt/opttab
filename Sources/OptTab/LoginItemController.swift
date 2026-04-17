import Foundation
import ServiceManagement

enum LoginItemController {
    static var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static var statusDescription: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "OptTab will open automatically when you log in."
        case .notRegistered:
            return "OptTab will not open automatically when you log in."
        case .notFound:
            return "Launch at login is unavailable for the current build."
        case .requiresApproval:
            return "macOS needs approval in System Settings > General > Login Items."
        @unknown default:
            return "Launch at login status is unknown."
        }
    }

    static func setLaunchAtLoginEnabled(_ isEnabled: Bool) throws {
        if isEnabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
