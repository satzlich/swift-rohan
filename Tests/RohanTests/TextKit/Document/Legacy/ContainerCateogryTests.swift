// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ContainerCateogryTests {
  @Test
  func coverage() {
    for category in ContainerCategory.allCases {
      _ = category.layoutMode()
    }
  }
}
