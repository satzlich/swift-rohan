// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct NewlineArrayTests {
  @Test
  static func testNewlineArray() {
    do {
      let isBlock: [Bool] = []
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trueValueCount == 0)
      #expect(newlines.asBitArray == [])
    }

    do {
      let isBlock: [Bool] = [true]
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trueValueCount == 0)
      #expect(newlines.asBitArray == [false])
    }

    do {
      let isBlock: [Bool] = [false, false, true, false, true, true]
      var newlines = NewlineArray(isBlock)
      #expect(newlines.asBitArray == [false, true, true, true, true, false])
      #expect(newlines.trueValueCount == 4)

      // insert
      newlines.insert(contentsOf: [true, false], at: 1)
      // [false, ꞈ true, false, ꞈ false, true, false, true, true]
      #expect(newlines.asBitArray == [true, true, false, true, true, true, true, false])
      #expect(newlines.trueValueCount == 6)

      // remove
      newlines.removeSubrange(1..<3)
      // [ false, ꞈꞈ false, true, false, true, true ]
      #expect(newlines.asBitArray == [false, true, true, true, true, false])
      #expect(newlines.trueValueCount == 4)
    }

  }

  @Test
  static func testReplace() {
    let repeats = 10
    let count = 100
    for _ in 0..<repeats {
      let isBlock: [Bool] = randomBools(count)
      var control = NewlineArray(isBlock)
      var test = NewlineArray(isBlock)
      //
      let range = randomRange(count)
      let placement: [Bool] = randomBools(10)
      control.replaceSubrange(range, with: placement)
      test.replaceSubrange(range, with: placement)
      #expect(control == test)
    }
  }

  private static func randomBools(_ count: Int) -> [Bool] {
    return (0..<count).map { _ in Bool.random() }
  }
  private static func randomRange(_ count: Int) -> Range<Int> {
    guard count > 1 else { return 0..<0 }  // Handle edge case
    let start = Int.random(in: 0..<count)  // Random start
    let end = Int.random(in: start..<count)  // Random end (must be ≥ start)
    return start..<end
  }
}
