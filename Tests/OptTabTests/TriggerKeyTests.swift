import CoreGraphics
@testable import OptTab
import XCTest

final class TriggerKeyTests: XCTestCase {
    func testGlobeTriggerKeyUsesFunctionKeyCode() {
        XCTAssertEqual(TriggerKey.globe.label, "Globe / fn")
        XCTAssertEqual(TriggerKey.globe.keyCodes, [63])
        XCTAssertEqual(TriggerKey.globe.flags, .maskSecondaryFn)
    }

    func testSecondaryTriggerKeyCanBeUnset() {
        XCTAssertEqual(SecondaryTriggerKey.none.label, "Off")
        XCTAssertNil(SecondaryTriggerKey.none.keyCode)
    }

    func testSecondaryTriggerKeyMapsF18() {
        XCTAssertEqual(SecondaryTriggerKey.f18.label, "F18")
        XCTAssertEqual(SecondaryTriggerKey.f18.keyCode, 79)
    }
}
