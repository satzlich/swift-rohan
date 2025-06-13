// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct MutabeTextLocationTests {
  @Test
  func coverage() {
    let indices: Array<RohanIndex> = [
      .index(0),
      .mathIndex(.nuc),
      .index(3),
    ]
    let location = TextLocation(indices, 13)
    var mutableLocation = MutableTextLocation(location)
    mutableLocation.rectify(2, with: 4)
    _ = mutableLocation.toTextLocation()
  }
}
