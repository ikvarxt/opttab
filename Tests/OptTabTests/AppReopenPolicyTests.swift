import Foundation
@testable import OptTab
import XCTest

final class AppReopenPolicyTests: XCTestCase {
    func testAllowsReopenForApplicationBundle() {
        let appURL = URL(fileURLWithPath: "/Applications/Safari.app")

        XCTAssertTrue(DockAppProvider.allowsReopenWhileRunning(url: appURL))
    }

    func testBlocksReopenForBareExecutable() {
        let executableURL = URL(fileURLWithPath: "/opt/homebrew/Cellar/scrcpy/4.0/bin/scrcpy")

        XCTAssertFalse(DockAppProvider.allowsReopenWhileRunning(url: executableURL))
    }

    func testAllowsReopenRegardlessOfBundleExtensionCase() {
        let appURL = URL(fileURLWithPath: "/Applications/Example.APP")

        XCTAssertTrue(DockAppProvider.allowsReopenWhileRunning(url: appURL))
    }
}
