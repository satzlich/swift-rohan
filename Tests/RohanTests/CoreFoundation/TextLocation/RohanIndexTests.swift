import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct RohanIndexTests {
  @Test
  func index() {
    let index: RohanIndex = .index(10)
    #expect(index.index() == 10)
    #expect(index.mathIndex() == nil)
    #expect("\(index)" == "↓10")
  }

  @Test
  func mathIndex() {
    let index: RohanIndex = .mathIndex(.nuc)
    #expect(index.mathIndex() == .nuc)
    #expect(index.gridIndex() == nil)
    #expect("\(index)" == "nuc")
  }

  @Test
  func gridIndex() {
    let index: RohanIndex = .gridIndex(3, 4)
    #expect(index.gridIndex() == GridIndex(3, 4))
    #expect(index.argumentIndex() == nil)
    #expect("\(index)" == "(3,4)")
  }

  @Test
  func argumentIndex() {
    let index: RohanIndex = .argumentIndex(2)
    #expect(index.argumentIndex() == 2)
    #expect(index.index() == nil)
    #expect("\(index)" == "⇒2")
  }

  @Test
  func isSameType() {
    do {
      let lhs = RohanIndex.index(10)
      let rhs = RohanIndex.index(13)
      #expect(lhs.isSameType(as: rhs) == true)
    }

    do {
      let lhs = RohanIndex.mathIndex(.nuc)
      let rhs = RohanIndex.index(13)
      #expect(lhs.isSameType(as: rhs) == false)
    }
  }

  @Test
  func parse() {
    let examples: Array<String> = [
      "↓10",
      "nuc",
      "(3,4)",
      "⇒2",
      // bad
      "x",
      "↓1x",
      "nucx",
      "(3,4x)",
      "⇒2x",
    ]

    let results: [RohanIndex?] = [
      .index(10),
      .mathIndex(.nuc),
      .gridIndex(3, 4),
      .argumentIndex(2),
      // bad
      nil,
      nil,
      nil,
      nil,
      nil,
    ]

    assert(examples.count == results.count)
    for (example, result) in zip(examples, results) {
      #expect(RohanIndex.parse(example) == result)
    }
  }
}
