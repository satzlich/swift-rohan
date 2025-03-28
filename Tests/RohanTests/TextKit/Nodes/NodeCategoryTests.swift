// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct NodeCategoryTests {
  // To ensure that all node types are categorized
  @Test
  static func test_ContentContainerCategory() {
    let n = NodeType.allCases.count - CONTENT_CONTAINER_CATEGORY.count
    #expect(n == 10)
  }
}
