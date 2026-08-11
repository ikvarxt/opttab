import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case switcherBar
    case fixedApps

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .switcherBar:
            return "Switcher Bar"
        case .fixedApps:
            return "Fixed Apps"
        }
    }

    var symbol: String {
        switch self {
        case .general:
            return "gearshape"
        case .switcherBar:
            return "rectangle.grid.1x2"
        case .fixedApps:
            return "pin"
        }
    }

    /// Each pane keeps its own window height so no pane scrolls or trails dead space.
    func contentHeight(fixedAppCount: Int) -> CGFloat {
        switch self {
        case .general:
            return 815
        case .switcherBar:
            return 670
        case .fixedApps:
            let rows = CGFloat(max(1, fixedAppCount))
            return min(680, SettingsMetrics.fixedAppsChrome + rows * SettingsMetrics.fixedAppRowHeight)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    var onLayoutChange: (SettingsTab, CGFloat) -> Void = { _, _ in }

    @State private var tab: SettingsTab = .general

    var body: some View {
        TabView(selection: $tab) {
            GeneralSettingsPane(settings: settings)
                .tabItem { Label(SettingsTab.general.title, systemImage: SettingsTab.general.symbol) }
                .tag(SettingsTab.general)

            SwitcherBarSettingsPane(settings: settings)
                .tabItem { Label(SettingsTab.switcherBar.title, systemImage: SettingsTab.switcherBar.symbol) }
                .tag(SettingsTab.switcherBar)

            FixedAppsSettingsPane(settings: settings)
                .tabItem { Label(SettingsTab.fixedApps.title, systemImage: SettingsTab.fixedApps.symbol) }
                .tag(SettingsTab.fixedApps)
        }
        .scrollContentBackground(.hidden)
        .background(
            WindowGlassBackground()
                .overlay(Color(nsColor: .textBackgroundColor).opacity(0.3))
                .ignoresSafeArea()
        )
        .frame(minWidth: SettingsMetrics.paneWidth, minHeight: SettingsMetrics.paneHeight)
        .onAppear(perform: reportLayout)
        .onChange(of: tab) { _ in reportLayout() }
        .onChange(of: settings.fixedAppShortcuts.count) { _ in reportLayout() }
    }

    private func reportLayout() {
        onLayoutChange(tab, tab.contentHeight(fixedAppCount: settings.fixedAppShortcuts.count))
    }
}
