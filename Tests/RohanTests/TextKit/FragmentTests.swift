// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct FragmentTests {
    @Test
    static func testGlyphFragment() {
        #expect(MemoryLayout<GlyphFragment>.size == 59)
    }

    @Test
    static func testVariantFragment() {
        #expect(MemoryLayout<VariantFragment>.size == 68)
    }
}
