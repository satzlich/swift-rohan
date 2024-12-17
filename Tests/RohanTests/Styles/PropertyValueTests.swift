// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct PropertyValueTests {
    @Test
    static func memoryLayoutSize() {
        #expect(MemoryLayout<String>.size == 16)
        #expect(MemoryLayout<Color>.size == 32)

        #expect(MemoryLayout<PropertyValue>.size == 33)
    }
}
