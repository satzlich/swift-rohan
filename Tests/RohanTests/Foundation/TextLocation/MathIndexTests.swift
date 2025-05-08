// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct MathIndexTests {
  @Test
  func coverage() {
    for (lhs, rhs) in zip(MathIndex.allCases, MathIndex.allCases) {
      _ = lhs < rhs
    }

    for i in MathIndex.allCases {
      _ = "\(i)"
    }
  }
}
