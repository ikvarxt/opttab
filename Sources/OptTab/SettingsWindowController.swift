import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings

        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: SettingsMetrics.paneWidth,
                height: SettingsTab.general.contentHeight(fixedAppCount: 0)
            ),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = SettingsTab.general.title
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentMinSize = NSSize(
            width: SettingsMetrics.paneWidth,
            height: SettingsMetrics.paneHeight
        )
        window.contentView = NSHostingView(
            rootView: SettingsView(
                settings: settings,
                onLayoutChange: { [weak window] tab, contentHeight in
                    window?.title = tab.title
                    Self.resize(window, toContentHeight: contentHeight)
                }
            )
        )
        window.center()
        window.isReleasedWhenClosed = false

        super.init(window: window)
        window.delegate = self
    }

    /// Grows and shrinks from the title bar down, the way tabbed macOS settings windows do.
    ///
    /// Driven by Core Animation on purpose: `setFrame(display:animate:)` runs its animation
    /// synchronously and blocks the main thread for the whole duration, which is 350ms on the
    /// largest pane-to-pane jump and reads as a stutter on every tab switch.
    private static func resize(_ window: NSWindow?, toContentHeight height: CGFloat) {
        guard let window else { return }

        let contentSize = NSSize(width: window.frame.width, height: height)
        let frameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
        guard abs(frameSize.height - window.frame.height) > 1 else { return }

        let frame = NSRect(
            x: window.frame.minX,
            y: window.frame.maxY - frameSize.height,
            width: window.frame.width,
            height: frameSize.height
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(frame, display: true)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        if window?.isVisible != true {
            window?.center()
        }

        settings.refreshLaunchAtLoginStatus()
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
    }
}
