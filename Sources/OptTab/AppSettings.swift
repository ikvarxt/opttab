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

struct FixedAppShortcut: Codable, Hashable, Identifiable {
    var id: UUID
    var appName: String
    var bundleIdentifier: String?
    var appPath: String
    var keyLabel: String

    init(
        id: UUID = UUID(),
        appName: String,
        bundleIdentifier: String?,
        appPath: String,
        keyLabel: String
    ) {
        self.id = id
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.appPath = appPath
        self.keyLabel = keyLabel
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
        static let fixedAppShortcuts = "fixedAppShortcuts"
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

    @Published var fixedAppShortcuts: [FixedAppShortcut] {
        didSet { persistFixedAppShortcuts() }
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

        fixedAppShortcuts = Self.loadFixedAppShortcuts(defaults: defaults)
    }

    var canAddFixedAppShortcut: Bool {
        fixedAppShortcuts.count < KeyBinding.availableLabels.count
    }

    @discardableResult
    func addFixedAppShortcut(appURL: URL) -> Bool {
        guard canAddFixedAppShortcut, !containsFixedShortcut(appURL: appURL) else {
            return false
        }

        guard let keyLabel = firstAvailableFixedShortcutLabel() else {
            return false
        }

        let bundle = Bundle(url: appURL)
        let appName = bundleDisplayName(bundle: bundle)
            ?? FileManager.default.displayName(atPath: appURL.path)
                .replacingOccurrences(of: ".app", with: "")

        fixedAppShortcuts.append(FixedAppShortcut(
            appName: appName,
            bundleIdentifier: bundle?.bundleIdentifier,
            appPath: appURL.standardizedFileURL.path,
            keyLabel: keyLabel
        ))
        return true
    }

    func removeFixedAppShortcut(id: FixedAppShortcut.ID) {
        fixedAppShortcuts.removeAll { $0.id == id }
    }

    func updateFixedAppShortcut(id: FixedAppShortcut.ID, keyLabel: String) {
        guard
            let index = fixedAppShortcuts.firstIndex(where: { $0.id == id }),
            fixedAppShortcuts[index].keyLabel != keyLabel
        else {
            return
        }

        let previousKeyLabel = fixedAppShortcuts[index].keyLabel
        if let conflictIndex = fixedAppShortcuts.firstIndex(where: {
            $0.id != id && $0.keyLabel == keyLabel
        }) {
            fixedAppShortcuts[conflictIndex].keyLabel = previousKeyLabel
        }

        fixedAppShortcuts[index].keyLabel = keyLabel
    }

    private static func loadFixedAppShortcuts(defaults: UserDefaults) -> [FixedAppShortcut] {
        guard let data = defaults.data(forKey: Keys.fixedAppShortcuts) else {
            return []
        }

        return (try? JSONDecoder().decode([FixedAppShortcut].self, from: data)) ?? []
    }

    private func persistFixedAppShortcuts() {
        guard let data = try? JSONEncoder().encode(fixedAppShortcuts) else {
            return
        }

        defaults.set(data, forKey: Keys.fixedAppShortcuts)
    }

    private func containsFixedShortcut(appURL: URL) -> Bool {
        let standardizedPath = appURL.standardizedFileURL.path
        let bundleIdentifier = Bundle(url: appURL)?.bundleIdentifier

        return fixedAppShortcuts.contains { shortcut in
            shortcut.appPath == standardizedPath ||
                (bundleIdentifier != nil && shortcut.bundleIdentifier == bundleIdentifier)
        }
    }

    private func firstAvailableFixedShortcutLabel() -> String? {
        let usedLabels = Set(fixedAppShortcuts.map(\.keyLabel))
        return KeyBinding.availableLabels.first { !usedLabels.contains($0) }
    }

    private func bundleDisplayName(bundle: Bundle?) -> String? {
        guard let bundle else { return nil }
        return bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
