import AppKit
import SwiftUI

enum SettingsMetrics {
    static let gap: CGFloat = 12
    static let iconSize: CGFloat = 20
    static let rowHeight: CGFloat = 22
    static let paneWidth: CGFloat = 580
    static let paneHeight: CGFloat = 260
    static let fixedAppsChrome: CGFloat = 240
    static let fixedAppRowHeight: CGFloat = 58
}

struct SettingsIconBadge: View {
    let symbol: String
    let tint: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(tint.gradient)
            .frame(width: SettingsMetrics.iconSize, height: SettingsMetrics.iconSize)
            .overlay(
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}

struct SettingsRow<Control: View>: View {
    let symbol: String
    let tint: Color
    let title: String
    var detail: String?
    @ViewBuilder var control: () -> Control

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: SettingsMetrics.gap) {
                SettingsIconBadge(symbol: symbol, tint: tint)
                Text(title)
                Spacer(minLength: SettingsMetrics.gap)
                control()
            }
            .frame(minHeight: SettingsMetrics.rowHeight)

            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, SettingsMetrics.iconSize + SettingsMetrics.gap)
            }
        }
        .padding(.vertical, 2)
    }
}

/// Lets the form scroll under a translucent title bar instead of a flat opaque band.
struct WindowGlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

/// Reuses the switcher bar's letter badge so settings and the bar read as one product.
struct KeyCapView: View {
    let text: String
    var size: CGFloat = 24

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.46, weight: .bold, design: .rounded))
            .foregroundStyle(Color(nsColor: .windowBackgroundColor))
            .frame(minWidth: size, minHeight: size)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .labelColor).opacity(0.85))
            )
    }
}
