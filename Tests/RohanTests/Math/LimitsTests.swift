// Copyright 2024-2025 Lie Yan

@testable import SwiftRohan
import Foundation
import Testing

struct LimitsTests {
    @Test
    static func testLimits() {
        // Large
        #expect(UnicodeScalar("∫").mathClass == .Large)
        #expect(Limits.defaultValue(forChar: "∫") == .never)
        #expect(UnicodeScalar("∑").mathClass == .Large)
        #expect(Limits.defaultValue(forChar: "∑") == .display)
        // Relation
        #expect(UnicodeScalar("<").mathClass == .Relation)
        #expect(Limits.defaultValue(forChar: "<") == .always)
        // Alphabetic
        #expect(UnicodeScalar("c").mathClass == .Alphabetic)
        #expect(Limits.defaultValue(forChar: "c") == .never)
    }
}
