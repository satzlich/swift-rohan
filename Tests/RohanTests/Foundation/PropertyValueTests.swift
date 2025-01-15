// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct PropertyValueTests {
    @Test
    static func testMemoryLayoutSize() {
        #expect(MemoryLayout<String>.size == 16)
        #expect(MemoryLayout<Color>.size == 8)

        #expect(MemoryLayout<PropertyValue>.size == 17)
    }
}
