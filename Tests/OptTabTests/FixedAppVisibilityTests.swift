import CoreGraphics
import Foundation
@testable import OptTab
import XCTest

final class FixedAppVisibilityTests: XCTestCase {
    func testFixedAppsAreVisibleByDefault() {
        let fixedItem = makeItem(id: "fixed", keyLabel: "F", keyCode: 3)
        let dynamicItem = makeItem(id: "dynamic", keyLabel: "D", keyCode: 2)

        let items = SwitcherItems(
            fixedItems: [fixedItem],
            dynamicItems: [dynamicItem],
            hidesFixedApps: false
        )

        XCTAssertEqual(items.visible, [fixedItem, dynamicItem])
        XCTAssertEqual(items.actionable, [fixedItem, dynamicItem])
    }

    func testHiddenFixedAppsRemainActionable() {
        let fixedItem = makeItem(id: "fixed", keyLabel: "F", keyCode: 3)
        let dynamicItem = makeItem(id: "dynamic", keyLabel: "D", keyCode: 2)

        let items = SwitcherItems(
            fixedItems: [fixedItem],
            dynamicItems: [dynamicItem],
            hidesFixedApps: true
        )

        XCTAssertEqual(items.visible, [dynamicItem])
        XCTAssertEqual(items.actionable, [fixedItem, dynamicItem])
    }

    func testVisibilitySettingDefaultsOffAndPersists() throws {
        let suiteName = "OptTabTests.FixedAppVisibility.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let initialSettings = AppSettings(defaults: defaults)
        XCTAssertFalse(initialSettings.hidesFixedAppsInSwitcher)

        initialSettings.hidesFixedAppsInSwitcher = true

        let restoredSettings = AppSettings(defaults: defaults)
        XCTAssertTrue(restoredSettings.hidesFixedAppsInSwitcher)
    }

    private func makeItem(id: String, keyLabel: String, keyCode: CGKeyCode) -> SwitcherItem {
        SwitcherItem(
            app: DockApp(
                id: id,
                name: id,
                bundleIdentifier: nil,
                url: URL(fileURLWithPath: "/Applications/\(id).app"),
                isRunning: false
            ),
            keyBinding: KeyBinding(label: keyLabel, keyCode: keyCode)
        )
    }
}
