// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct PickedRangeTests {
  @Test
  func coverage() {
    let range = PickedRange(10..<15, 0.3)

    #expect(range.lowerBound == 10)
    #expect(range.upperBound == 15)
    #expect(range.fraction == 0.3)
    #expect(range.isEmpty == false)
    #expect(range.count == 5)

    // subtracting()
    do {
      let subtracted = range.subtracting(9)
      #expect(subtracted == PickedRange(1..<6, 0.3))
    }
    do {
      let subtracted = range.subtracting(10)
      #expect(subtracted == PickedRange(0..<5, 0.3))
    }
    do {
      let subtracted = range.subtracting(11)
      #expect(subtracted == nil)
    }
  }
}
