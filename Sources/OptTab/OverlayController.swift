import AppKit
import SwiftUI

final class OverlayController {
    private var panel: NSPanel?

    func show(items: [SwitcherItem], showsAppNames: Bool) {
        if panel == nil {
            panel = makePanel()
        }

        guard let panel else { return }

        let contentView = SwitcherBarView(items: items, showsAppNames: showsAppNames)
        panel.contentView = NSHostingView(rootView: contentView)
        panel.setFrame(frame(for: items.count, showsAppNames: showsAppNames), display: true)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        return panel
    }

    private func frame(for itemCount: Int, showsAppNames: Bool) -> NSRect {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let itemWidth: CGFloat = 82
        let horizontalPadding: CGFloat = 32
        let width = min(
            screenFrame.width - 80,
            max(360, CGFloat(itemCount) * itemWidth + horizontalPadding)
        )
        let height: CGFloat = showsAppNames ? 118 : 92
        let x = screenFrame.midX - width / 2
        let y = screenFrame.midY - height / 2
        return NSRect(x: x, y: y, width: width, height: height)
    }
}
