import Foundation
@testable import OptTab
import XCTest

final class HoverActivationSettingTests: XCTestCase {
    func testHoverActivationDefaultsOnAndPersists() throws {
        let suiteName = "OptTabTests.HoverActivation.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let initialSettings = AppSettings(defaults: defaults)
        XCTAssertTrue(initialSettings.activatesHoveredApp)

        initialSettings.activatesHoveredApp = false

        let restoredSettings = AppSettings(defaults: defaults)
        XCTAssertFalse(restoredSettings.activatesHoveredApp)
    }
}
