// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct TextLocationSliceTests {
  @Test
  func coverage() {
    let indices: Array<RohanIndex> = [
      .index(0),
      .index(7),
      .mathIndex(.nuc),
      .index(9),
      .gridIndex(3, 11),
      .index(10),
      .argumentIndex(3),
    ]
    let location = TextLocation(indices, 29)

    let slice = location.toTextLocationSlice()

    #expect(slice.count == location.indices.count + 1)
    #expect(slice.dropFirst().count == location.indices.count)
    #expect(slice.dropFirst(2).count == location.indices.count - 1)
  }
}
