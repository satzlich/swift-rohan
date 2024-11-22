// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct PropertyValue_ {
    @Test
    static func memoryLayoutSize() {
        #expect(MemoryLayout<String>.size == 16)

        #expect(MemoryLayout<PropertyValue>.size == 17)
    }
}
