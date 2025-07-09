// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct NewlineArrayTests {
  @Test
  static func coverage() {
    let newlines = NewlineArray([true, false, true])
    _ = newlines.first
    _ = newlines.last
  }

  @Test
  static func testNewlineArray() {
    do {
      let isBlock: Array<Bool> = []
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trailingCount == 0)
      #expect(newlines.asBitArray == [])
      #expect(newlines.isEmpty == true)
    }

    do {
      let isBlock: Array<Bool> = [true]
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trailingCount == 0)
      #expect(newlines.asBitArray == [false])
      #expect(newlines.isEmpty == false)
    }
  }

  @Test
  static func test_Manipulation() {
    let isBlock: Array<Bool> = [false, false, true, false, true, true]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // insert empty
    newlines.insert(contentsOf: [], at: 0)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // insert collection
    newlines.insert(contentsOf: [true, false], at: 1)
    // [false, ꞈ true, false, ꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // insert single
    newlines.insert(isBlock: false, at: 1)
    // [false, ꞈ false, ꞈ true, false, false, true, false, true, true]
    #expect(
      newlines.asBitArray == [false, true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // remove empty
    newlines.removeSubrange(0..<0)
    #expect(
      newlines.asBitArray == [false, true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // remove subrange
    newlines.removeSubrange(2..<4)
    // [ false, false, ꞈꞈ false, true, false, true, true ]
    #expect(newlines.asBitArray == [false, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // remove single
    newlines.remove(at: 1)
    // [ false, ꞈꞈ false, true, false, true, true ]
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // set value
    newlines.setValue(isBlock: true, at: 1)
    // [ false, true, true,  false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)
  }

  @Test
  static func testSetValue() {
    let isBlock: Array<Bool> = [false, false, true, false, true, true]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // set value
    newlines.setValue(isBlock: true, at: 1)
    // [ false, true, true, false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at first position
    newlines.setValue(isBlock: true, at: 0)
    // [ true, true, true, false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at last position
    newlines.setValue(isBlock: false, at: 5)
    // [ true, true, true, false, true, false ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at second last position
    newlines.setValue(isBlock: false, at: 4)
    // [ true, true, true, false, false, false ]
    #expect(newlines.asBitArray == [true, true, true, false, false, false])
    #expect(newlines.trailingCount == 3)
  }

  @Test
  static func testReplace() {
    let isBlock: Array<Bool> = [false, false, true, false, true, true]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // replace empty
    newlines.replaceSubrange(1..<1, with: [true, false])
    // [false, ꞈ true, false, ꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // replace with empty
    newlines.replaceSubrange(1..<3, with: [])
    // [false, ꞈꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)
  }

  @Test
  static func testRandomReplace() {
    let repeats = 10
    let count = 100
    for _ in 0..<repeats {
      let isBlock: Array<Bool> = randomBools(count)
      var control = NewlineArray(isBlock)
      var test = NewlineArray(isBlock)
      //
      let range = randomRange(count)
      let placement: Array<Bool> = randomBools(10)
      control.replaceSubrange(range, with: placement)
      test.replaceSubrange(range, with: placement)
      #expect(control == test)
    }
  }

  private static func randomBools(_ count: Int) -> Array<Bool> {
    return (0..<count).map { _ in Bool.random() }
  }
  private static func randomRange(_ count: Int) -> Range<Int> {
    guard count > 1 else { return 0..<0 }  // Handle edge case
    let start = Int.random(in: 0..<count)  // Random start
    let end = Int.random(in: start..<count)  // Random end (must be ≥ start)
    return start..<end
  }
}
