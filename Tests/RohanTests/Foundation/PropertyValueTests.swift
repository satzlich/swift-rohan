// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct PropertyValueTests {
  @Test
  static func test_MemoryLayout_size() {
    #expect(MemoryLayout<String>.size == 16)
    #expect(MemoryLayout<Color>.size == 8)

    #expect(MemoryLayout<PropertyValue>.size == 17)
  }
}
