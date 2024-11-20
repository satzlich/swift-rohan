// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class PropertyValueTests: XCTestCase {
    func testValueSize() {
        XCTAssertEqual(MemoryLayout<String>.size, 16)

        XCTAssertEqual(MemoryLayout<PropertyValue>.size, 17)
    }
}
