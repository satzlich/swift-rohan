// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Testing

@testable import SwiftRohan

struct CGSizeTests {
  @Test
  func coverage() {
    let size = CGSize(width: 10, height: 20)

    _ = size.with(width: 20)
    _ = size.with(height: 30)
    _ = size.formatted(2)
  }
}
