// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class PropertyValueTests: XCTestCase {
    func testMemoryLayout() {
        XCTAssertEqual(MemoryLayout<String>.size, 16)

        XCTAssertEqual(MemoryLayout<PropertyValue>.size, 17)
    }

    func testFontSize() {
        XCTAssertNil(FontSize(0.5))
        XCTAssertNotNil(FontSize(1))
        XCTAssertNotNil(FontSize(10))
        XCTAssertNotNil(FontSize(10.5))
        XCTAssertNil(FontSize(10.8))
        XCTAssertNotNil(FontSize(1638))
        XCTAssertNil(FontSize(1639))
    }

    func testAbsLength() {
        let abs = AbsLength.pt(10)
        let eps = 1e-9

        XCTAssertEqual(abs.ptValue, 10)
        XCTAssertEqual(abs.mmValue, 3.527_777_777, accuracy: eps)
        XCTAssertEqual(abs.cmValue, 0.352_777_777, accuracy: eps)
        XCTAssertEqual(abs.picaValue, 10 / 12, accuracy: eps)
        XCTAssertEqual(abs.inValue, 10 / 72, accuracy: eps)
    }
}
