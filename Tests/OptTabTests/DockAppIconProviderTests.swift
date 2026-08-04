import XCTest
@testable import OptTab

final class DockAppIconProviderTests: XCTestCase {
    func testFindsHomebrewHicolorCompanionIconForBareExecutable() {
        let executableURL = URL(fileURLWithPath: "/opt/homebrew/Cellar/scrcpy/4.0/bin/scrcpy")
        let expectedPath = "/opt/homebrew/Cellar/scrcpy/4.0/share/icons/hicolor/256x256/apps/scrcpy.png"

        let iconURL = DockAppIconProvider.companionIconURL(
            for: executableURL,
            appName: "scrcpy",
            fileExists: { $0 == expectedPath }
        )

        XCTAssertEqual(iconURL?.path, expectedPath)
    }

    func testDoesNotReplaceApplicationBundleIcon() {
        let appURL = URL(fileURLWithPath: "/Applications/Safari.app")

        let iconURL = DockAppIconProvider.companionIconURL(
            for: appURL,
            appName: "Safari",
            fileExists: { _ in true }
        )

        XCTAssertNil(iconURL)
    }

    func testFallsBackWhenNoCompanionIconExists() {
        let executableURL = URL(fileURLWithPath: "/usr/local/bin/example")

        let iconURL = DockAppIconProvider.companionIconURL(
            for: executableURL,
            appName: "Example",
            fileExists: { _ in false }
        )

        XCTAssertNil(iconURL)
    }
}
