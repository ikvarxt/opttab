import CoreGraphics
@testable import OptTab
import XCTest

final class KeyCaptureTests: XCTestCase {
    func testCapturedKeyCodeMapsToQwertyLetter() {
        XCTAssertEqual(KeyBinding.label(forKeyCode: 1, layout: .qwerty), "S")
        XCTAssertEqual(KeyBinding.label(forKeyCode: 46, layout: .qwerty), "M")
    }

    func testSameKeyCodeMapsToLayoutSpecificLetter() {
        XCTAssertEqual(KeyBinding.label(forKeyCode: 1, layout: .programmerDvorak), "O")
        XCTAssertEqual(KeyBinding.label(forKeyCode: 41, layout: .programmerDvorak), "S")
    }

    func testNonLetterKeyCodeIsRejected() {
        XCTAssertNil(KeyBinding.label(forKeyCode: 36, layout: .qwerty))
        XCTAssertNil(KeyBinding.label(forKeyCode: KeyBinding.escapeKeyCode, layout: .qwerty))
    }

    func testCapturedLabelRoundTripsToTheSameKeyCode() throws {
        let keyCode: CGKeyCode = 9
        let label = try XCTUnwrap(KeyBinding.label(forKeyCode: keyCode, layout: .programmerDvorak))
        let binding = try XCTUnwrap(KeyBinding.binding(for: label, layout: .programmerDvorak))

        XCTAssertEqual(binding.keyCode, keyCode)
    }
}
