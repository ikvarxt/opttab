import AppKit
import Combine

enum TriggerKey: String, CaseIterable, Identifiable {
    case leftOption
    case rightOption
    case leftCommand
    case rightCommand
    case leftControl
    case rightControl
    case leftShift
    case rightShift

    var id: String { rawValue }

    var label: String {
        switch self {
        case .leftOption:
            return "Left Option"
        case .rightOption:
            return "Right Option"
        case .leftCommand:
            return "Left Command"
        case .rightCommand:
            return "Right Command"
        case .leftControl:
            return "Left Control"
        case .rightControl:
            return "Right Control"
        case .leftShift:
            return "Left Shift"
        case .rightShift:
            return "Right Shift"
        }
    }

    var keyCode: CGKeyCode {
        switch self {
        case .leftOption:
            return 58
        case .rightOption:
            return 61
        case .leftCommand:
            return 55
        case .rightCommand:
            return 54
        case .leftControl:
            return 59
        case .rightControl:
            return 62
        case .leftShift:
            return 56
        case .rightShift:
            return 60
        }
    }

    var flags: CGEventFlags {
        switch self {
        case .leftOption, .rightOption:
            return .maskAlternate
        case .leftCommand, .rightCommand:
            return .maskCommand
        case .leftControl, .rightControl:
            return .maskControl
        case .leftShift, .rightShift:
            return .maskShift
        }
    }
}

enum AppSource: String, CaseIterable, Identifiable {
    case dockAndRunning
    case dockOnly
    case runningOnly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dockAndRunning:
            return "Dock apps, then running apps"
        case .dockOnly:
            return "Dock apps only"
        case .runningOnly:
            return "Running apps only"
        }
    }

    var detail: String {
        switch self {
        case .dockAndRunning:
            return "Pinned Dock apps stay first, with open apps added after them."
        case .dockOnly:
            return "Only apps pinned in the Dock are shown."
        case .runningOnly:
            return "Only currently open regular apps are shown."
        }
    }
}

enum KeyOrder: String, CaseIterable, Identifiable {
    case homeRowFirst
    case alphabetical

    var id: String { rawValue }

    var label: String {
        switch self {
        case .homeRowFirst:
            return "Home row first"
        case .alphabetical:
            return "Alphabetical"
        }
    }

    var detail: String {
        switch self {
        case .homeRowFirst:
            return "A S D F first, then the remaining letters."
        case .alphabetical:
            return "A through Z in normal alphabet order."
        }
    }
}

final class AppSettings: ObservableObject {
    private enum Keys {
        static let triggerKey = "triggerKey"
        static let appSource = "appSource"
        static let keyOrder = "keyOrder"
        static let showAppNames = "showAppNames"
        static let closeAfterSelection = "closeAfterSelection"
    }

    private let defaults: UserDefaults

    @Published var triggerKey: TriggerKey {
        didSet { defaults.set(triggerKey.rawValue, forKey: Keys.triggerKey) }
    }

    @Published var appSource: AppSource {
        didSet { defaults.set(appSource.rawValue, forKey: Keys.appSource) }
    }

    @Published var keyOrder: KeyOrder {
        didSet { defaults.set(keyOrder.rawValue, forKey: Keys.keyOrder) }
    }

    @Published var showAppNames: Bool {
        didSet { defaults.set(showAppNames, forKey: Keys.showAppNames) }
    }

    @Published var closeAfterSelection: Bool {
        didSet { defaults.set(closeAfterSelection, forKey: Keys.closeAfterSelection) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        triggerKey = defaults.string(forKey: Keys.triggerKey)
            .flatMap(TriggerKey.init(rawValue:)) ?? .leftOption

        appSource = defaults.string(forKey: Keys.appSource)
            .flatMap(AppSource.init(rawValue:)) ?? .dockAndRunning

        keyOrder = defaults.string(forKey: Keys.keyOrder)
            .flatMap(KeyOrder.init(rawValue:)) ?? .homeRowFirst

        if defaults.object(forKey: Keys.showAppNames) == nil {
            showAppNames = true
        } else {
            showAppNames = defaults.bool(forKey: Keys.showAppNames)
        }

        if defaults.object(forKey: Keys.closeAfterSelection) == nil {
            closeAfterSelection = false
        } else {
            closeAfterSelection = defaults.bool(forKey: Keys.closeAfterSelection)
        }
    }
}
