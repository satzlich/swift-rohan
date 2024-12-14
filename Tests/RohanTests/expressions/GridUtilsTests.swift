// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct GridUtilsTests {
    @Test(arguments: [(0, 0), (123, 45), (32766, 62)])
    func testBasics(_ row: Int, _ column: Int) {
        let encodedValue = GridUtils.encodeRowColumn(row, column)
        #expect(encodedValue < 0)

        let (r, c) = GridUtils.decodeRowColumn(encodedValue)
        #expect(r == row)
        #expect(c == column)
    }
}
