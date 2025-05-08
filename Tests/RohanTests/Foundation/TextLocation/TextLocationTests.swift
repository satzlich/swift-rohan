// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct TextLocationTests {

  @Test
  func coverage() {
    let indices: [RohanIndex] = []
    let location = TextLocation(indices, 7)
    #expect(location.asArray.count == indices.count + 1)

    _ = "\(location)"
  }
}
