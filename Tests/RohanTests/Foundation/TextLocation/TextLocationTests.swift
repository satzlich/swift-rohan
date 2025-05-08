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

    do {
      let location1 = location.with(offsetDelta: 2)
      #expect(location1.indices == indices)
      #expect(location1.offset == location.offset + 2)
    }
  }

  @Test
  func compare() {
    func construct(_ index: RohanIndex) -> TextLocation {
      TextLocation([index], 3)
    }

    do {
      let a = construct(.index(7))
      let b = construct(.index(13))
      #expect(a.compare(b) == .orderedAscending)
    }

    do {
      let a = construct(.mathIndex(.nuc))
      let b = construct(.mathIndex(.sub))
      #expect(a.compare(b) == .orderedAscending)
    }

    do {
      let a = construct(.gridIndex(1, 3))
      let b = construct(.gridIndex(1, 5))
      #expect(a.compare(b) == .orderedAscending)
    }

    do {
      let a = construct(.argumentIndex(3))
      let b = construct(.argumentIndex(5))
      #expect(a.compare(b) == .orderedAscending)
    }

    do {
      let a = construct(.index(7))
      let b = construct(.mathIndex(.nuc))
      #expect(a.compare(b) == nil)
    }
  }
}
