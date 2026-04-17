import AppKit

protocol HotkeyControllerDelegate: AnyObject {
    func hotkeyDidPress()
    func hotkeyDidRelease()
    func hotkeyDidReceiveKeyCode(_ keyCode: CGKeyCode)
}

final class HotkeyController {
    weak var delegate: HotkeyControllerDelegate?

    private let settings: AppSettings
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isTriggerDown = false
    private var activeTriggerKeyCodes = Set<CGKeyCode>()

    init(settings: AppSettings) {
        self.settings = settings
    }

    func start() -> Bool {
        guard eventTap == nil else { return true }

        let mask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let controller = Unmanaged<HotkeyController>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                return controller.handle(type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        self.eventTap = eventTap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        self.runLoopSource = runLoopSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        return true
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isTriggerDown = false
        activeTriggerKeyCodes.removeAll()
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        let triggerKey = settings.triggerKey

        if type == .flagsChanged, triggerKey.keyCodes.contains(keyCode) {
            updateTriggerState(
                changedKeyCode: keyCode,
                eventFlags: event.flags,
                triggerKey: triggerKey
            )
            return nil
        }

        guard isTriggerDown else {
            return Unmanaged.passUnretained(event)
        }

        if type == .keyDown {
            if keyCode == KeyBinding.escapeKeyCode {
                isTriggerDown = false
                activeTriggerKeyCodes.removeAll()
                delegate?.hotkeyDidRelease()
                return nil
            }

            delegate?.hotkeyDidReceiveKeyCode(keyCode)
            return nil
        }

        if type == .keyUp {
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func updateTriggerState(
        changedKeyCode: CGKeyCode,
        eventFlags: CGEventFlags,
        triggerKey: TriggerKey
    ) {
        let wasTriggerDown = isTriggerDown

        if activeTriggerKeyCodes.contains(changedKeyCode) {
            activeTriggerKeyCodes.remove(changedKeyCode)
        } else if eventFlags.contains(triggerKey.flags) {
            activeTriggerKeyCodes.insert(changedKeyCode)
        } else {
            activeTriggerKeyCodes.remove(changedKeyCode)
        }

        let isNowTriggerDown = !activeTriggerKeyCodes.isEmpty
        isTriggerDown = isNowTriggerDown

        if !wasTriggerDown && isNowTriggerDown {
            delegate?.hotkeyDidPress()
        } else if wasTriggerDown && !isNowTriggerDown {
            delegate?.hotkeyDidRelease()
        }
    }
}
