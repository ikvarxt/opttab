import AppKit
import Combine

enum TriggerKey: String, CaseIterable, Identifiable {
    case leftOption
    case rightOption
    case eitherOption
    case leftCommand
    case rightCommand
    case eitherCommand
    case leftControl
    case rightControl
    case eitherControl
    case leftShift
    case rightShift
    case eitherShift

    var id: String { rawValue }

    var label: String {
        switch self {
        case .leftOption:
            return "Left Option"
        case .rightOption:
            return "Right Option"
        case .eitherOption:
            return "Either Option"
        case .leftCommand:
            return "Left Command"
        case .rightCommand:
            return "Right Command"
        case .eitherCommand:
            return "Either Command"
        case .leftControl:
            return "Left Control"
        case .rightControl:
            return "Right Control"
        case .eitherControl:
            return "Either Control"
        case .leftShift:
            return "Left Shift"
        case .rightShift:
            return "Right Shift"
        case .eitherShift:
            return "Either Shift"
        }
    }

    var keyCodes: Set<CGKeyCode> {
        switch self {
        case .leftOption:
            return [58]
        case .rightOption:
            return [61]
        case .eitherOption:
            return [58, 61]
        case .leftCommand:
            return [55]
        case .rightCommand:
            return [54]
        case .eitherCommand:
            return [55, 54]
        case .leftControl:
            return [59]
        case .rightControl:
            return [62]
        case .eitherControl:
            return [59, 62]
        case .leftShift:
            return [56]
        case .rightShift:
            return [60]
        case .eitherShift:
            return [56, 60]
        }
    }

    var flags: CGEventFlags {
        switch self {
        case .leftOption, .rightOption, .eitherOption:
            return .maskAlternate
        case .leftCommand, .rightCommand, .eitherCommand:
            return .maskCommand
        case .leftControl, .rightControl, .eitherControl:
            return .maskControl
        case .leftShift, .rightShift, .eitherShift:
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

enum KeyboardLayout: String, CaseIterable, Identifiable {
    case qwerty
    case programmerDvorak

    var id: String { rawValue }

    var label: String {
        switch self {
        case .qwerty:
            return "QWERTY"
        case .programmerDvorak:
            return "Programmer Dvorak"
        }
    }

    var detail: String {
        switch self {
        case .qwerty:
            return "A-Z are mapped to the standard US QWERTY letter positions."
        case .programmerDvorak:
            return "A-Z are mapped to Programmer Dvorak letter positions, including W/V/Z on comma, period, and slash keys."
        }
    }
}

final class AppSettings: ObservableObject {
    private enum Keys {
        static let triggerKey = "triggerKey"
        static let appSource = "appSource"
        static let keyOrder = "keyOrder"
        static let keyboardLayout = "keyboardLayout"
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

    @Published var keyboardLayout: KeyboardLayout {
        didSet { defaults.set(keyboardLayout.rawValue, forKey: Keys.keyboardLayout) }
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

        keyboardLayout = defaults.string(forKey: Keys.keyboardLayout)
            .flatMap(KeyboardLayout.init(rawValue:)) ?? .qwerty

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
