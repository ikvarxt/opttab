import AppKit
import Combine

/// Owns the one live key monitor so two rows can never record at the same time.
final class KeyRecorder: ObservableObject {
    @Published private(set) var recordingID: UUID?

    private var monitor: Any?
    private var resignObserver: NSObjectProtocol?
    private var handleKey: ((CGKeyCode) -> Bool)?

    deinit {
        removeMonitor()
    }

    func start(id: UUID, handleKey: @escaping (CGKeyCode) -> Bool) {
        stop()

        recordingID = id
        self.handleKey = handleKey

        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else { return event }

            let keyCode = CGKeyCode(event.keyCode)
            if keyCode == KeyBinding.escapeKeyCode || self.handleKey?(keyCode) == true {
                self.stop()
            }

            return nil
        }

        // A monitor left armed after the window loses focus would rewrite keys on the next keystroke.
        resignObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stop()
        }
    }

    func stop() {
        removeMonitor()
        handleKey = nil
        recordingID = nil
    }

    private func removeMonitor() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil

        if let resignObserver {
            NotificationCenter.default.removeObserver(resignObserver)
        }
        resignObserver = nil
    }
}
