// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct TextLocationTests {

  @Test
  func coverage() {
    let indices: Array<RohanIndex> = []
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

  @Test
  func parse() {
    do {
      let examples: Array<String> = [
        "[]:0",
        "[↓2]:0",
        "[↓2,⇒3]:0",
        "[↓2,(2,3)]:1",
        "[↓2,nuc]:1",
      ]
      for str in examples {
        let location = TextLocation.parse(str)
        #expect(location != nil)
        #expect(location?.description == str)
      }
    }

    do {
      let invalid: Array<String> = [
        "[]",
        "]:0",
        "[↓1x]:0",
      ]

      for str in invalid {
        #expect(TextLocation.parse(str) == nil)
      }
    }
  }

  // Here we test the edge cases.
  @Test
  func toUserSpace() {
    let location = TextLocation.parse("[↓2]:0")!
    let rootNode = RootNode()
    #expect(nil == location.toUseSpace(for: rootNode))
  }
}
