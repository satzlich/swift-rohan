// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NewlineArrayTests {
    @Test
    static func testNewlineArray() {
        do {
            let isBlock: [Bool] = []
            let newlines = NewlineArray(isBlock)
            #expect(newlines.trueValueCount == 0)
            #expect(newlines.asBitArray == [])
        }

        do {
            let isBlock: [Bool] = [true]
            let newlines = NewlineArray(isBlock)
            #expect(newlines.trueValueCount == 0)
            #expect(newlines.asBitArray == [false])
        }

        do {
            let isBlock: [Bool] = [false, false, true, false, true, true]
            var newlines = NewlineArray(isBlock)
            #expect(newlines.asBitArray == [false, true, true, true, true, false])
            #expect(newlines.trueValueCount == 4)

            // insert
            newlines.insert(contentsOf: [true, false], at: 1)
            // [false, ꞈ true, false, ꞈ false, true, false, true, true]
            #expect(newlines.asBitArray ==
                [true, true, false, true, true, true, true, false])
            #expect(newlines.trueValueCount == 6)

            // remove
            newlines.removeSubrange(1 ..< 3)
            // [ false, ꞈꞈ false, true, false, true, true ]
            #expect(newlines.asBitArray == [false, true, true, true, true, false])
            #expect(newlines.trueValueCount == 4)
        }
    }
}
