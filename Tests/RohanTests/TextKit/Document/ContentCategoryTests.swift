// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ContentCategoryTests {
  @Test
  func coverage() {
    let contentCategory = ContentCategory.plaintext
    
    #expect(contentCategory.isCompatible(with: .textTextContainer))
  }
}
