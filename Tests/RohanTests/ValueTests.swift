// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class ValueTests: XCTestCase {
    func testValueSize() {
        XCTAssertEqual(MemoryLayout<String>.size, 16)

        XCTAssertLessThanOrEqual(MemoryLayout<Value>.size, 24)
    }
}
