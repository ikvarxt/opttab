import AppKit
import SwiftUI

final class OverlayController {
    private var panel: NSPanel?

    func show(items: [SwitcherItem], showsAppNames: Bool) {
        if panel == nil {
            panel = makePanel()
        }

        guard let panel else { return }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let metrics = SwitcherBarMetrics.make(
            itemCount: items.count,
            availableWidth: screenFrame.width - 96,
            showsAppNames: showsAppNames
        )
        let contentView = SwitcherBarView(
            items: items,
            showsAppNames: showsAppNames,
            metrics: metrics
        )
        panel.contentView = NSHostingView(rootView: contentView)
        panel.setFrame(frame(screenFrame: screenFrame, metrics: metrics), display: true)
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

    private func frame(screenFrame: NSRect, metrics: SwitcherBarMetrics) -> NSRect {
        let x = screenFrame.midX - metrics.panelWidth / 2
        let y = screenFrame.midY - metrics.panelHeight / 2
        return NSRect(
            x: x,
            y: y,
            width: metrics.panelWidth,
            height: metrics.panelHeight
        )
    }
}
