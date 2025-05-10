// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct GridIndexTests {
  @Test
  func coverage() {
    let values = [0, 30, 62]

    for (i, j) in zip(values, values) {
      _ = GridIndex(i, j)
    }

    do {
      let lhs = GridIndex(0, 0)
      let rhs = GridIndex(4, 3)
      #expect(lhs < rhs)
    }

    do {
      let index = GridIndex(0, 0)
      _ = "\(index)"
    }
  }

  @Test
  func parse() {
    #expect(GridIndex.parse("(1,3)") == GridIndex(1, 3))

    // invalid
    #expect(GridIndex.parse("1,3)") == nil)
    #expect(GridIndex.parse("(1,3,4)") == nil)
  }
}
