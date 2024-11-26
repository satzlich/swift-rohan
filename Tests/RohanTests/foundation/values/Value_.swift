// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.attributeValues))
struct Value_ {
    @Test
    static func memoryLayoutSize() {
        #expect(MemoryLayout<String>.size == 16)
        #expect(MemoryLayout<Color>.size == 32)

        #expect(MemoryLayout<Value>.size == 17)
    }
}
