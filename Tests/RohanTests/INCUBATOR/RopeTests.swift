// Copyright 2024-2025 Lie Yan

@testable import Rohan
import _RopeModule
import Foundation
import Testing

struct RopeTests {
    @Test
    static func testRope() { }

    @Test
    static func testString() {
        let a = "\r"
        let b = "\n"
        let c = a + b

        #expect(a.count == 1)
        #expect(b.count == 1)
        #expect(c.count == 1)
        #expect(a.lengthAsNSString() == 1)
        #expect(b.lengthAsNSString() == 1)
        #expect(c.lengthAsNSString() == 2)
    }
}
