import Foundation
@testable import OptTab
import XCTest

final class FixedAppKeySwapTests: XCTestCase {
    func testTakingAnOccupiedLetterReportsTheSwap() throws {
        let settings = try makeSettings()
        settings.addFixedAppShortcut(appURL: URL(fileURLWithPath: "/Applications/Alpha.app"))
        settings.addFixedAppShortcut(appURL: URL(fileURLWithPath: "/Applications/Beta.app"))

        let alpha = settings.fixedAppShortcuts[0]
        let beta = settings.fixedAppShortcuts[1]

        let swap = try XCTUnwrap(
            settings.updateFixedAppShortcut(id: alpha.id, keyLabel: beta.keyLabel)
        )

        XCTAssertEqual(swap.assignedAppName, alpha.appName)
        XCTAssertEqual(swap.assignedKeyLabel, beta.keyLabel)
        XCTAssertEqual(swap.displacedAppName, beta.appName)
        XCTAssertEqual(swap.displacedKeyLabel, alpha.keyLabel)

        XCTAssertEqual(settings.fixedAppShortcuts[0].keyLabel, beta.keyLabel)
        XCTAssertEqual(settings.fixedAppShortcuts[1].keyLabel, alpha.keyLabel)
    }

    func testTakingAFreeLetterReportsNoSwap() throws {
        let settings = try makeSettings()
        settings.addFixedAppShortcut(appURL: URL(fileURLWithPath: "/Applications/Alpha.app"))

        let alpha = settings.fixedAppShortcuts[0]

        XCTAssertNil(settings.updateFixedAppShortcut(id: alpha.id, keyLabel: "Q"))
        XCTAssertEqual(settings.fixedAppShortcuts[0].keyLabel, "Q")
    }

    func testReassigningTheSameLetterReportsNoSwap() throws {
        let settings = try makeSettings()
        settings.addFixedAppShortcut(appURL: URL(fileURLWithPath: "/Applications/Alpha.app"))

        let alpha = settings.fixedAppShortcuts[0]

        XCTAssertNil(settings.updateFixedAppShortcut(id: alpha.id, keyLabel: alpha.keyLabel))
    }

    private func makeSettings() throws -> AppSettings {
        let suiteName = "OptTabTests.FixedAppKeySwap.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        addTeardownBlock { defaults.removePersistentDomain(forName: suiteName) }

        return AppSettings(defaults: defaults)
    }
}
