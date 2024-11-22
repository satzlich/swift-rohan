// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class AbsLengthTests: XCTestCase {
    func testValueConversion() {
        let abs = AbsLength.pt(10)
        let eps = 1e-9

        XCTAssertEqual(abs.ptValue, 10)
        XCTAssertEqual(abs.mmValue, 3.527_777_777, accuracy: eps)
        XCTAssertEqual(abs.cmValue, 0.352_777_777, accuracy: eps)
        XCTAssertEqual(abs.picaValue, 10 / 12, accuracy: eps)
        XCTAssertEqual(abs.inValue, 10 / 72, accuracy: eps)
    }
}
