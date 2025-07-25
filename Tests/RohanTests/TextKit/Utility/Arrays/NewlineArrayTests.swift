import Foundation
import Testing

@testable import SwiftRohan

struct NewlineArrayTests {
  @Test
  static func testNewlineArray() {
    do {
      let isBlock: Array<LayoutType> = []
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trailingCount == 0)
      #expect(newlines.asBitArray == [])
      #expect(newlines.isEmpty == true)
    }

    do {
      let isBlock: Array<LayoutType> = [.hardBlock]
      let newlines = NewlineArray(isBlock)
      #expect(newlines.trailingCount == 0)
      #expect(newlines.asBitArray == [false])
      #expect(newlines.isEmpty == false)
    }

    do {
      let newlines = NewlineArray([.hardBlock, .inline, .hardBlock])
      #expect(newlines.first == true)
      #expect(newlines.last == false)

      #expect(newlines.value(before: 0, atBlockEdge: true) == false)
      #expect(newlines.value(before: 0, atBlockEdge: false) == true)
    }
  }

  @Test
  static func test_Manipulation() {
    let isBlock: Array<LayoutType> = [.inline, .inline, .hardBlock, .inline, .hardBlock, .hardBlock]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // insert empty
    newlines.insert(contentsOf: [], at: 0)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // insert collection
    newlines.insert(contentsOf: [.hardBlock, .inline], at: 1)
    // [false, ꞈ true, false, ꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // insert single
    newlines.insert(layoutType: .inline, at: 1)
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
    newlines.setValue(layoutType: .hardBlock, at: 1)
    // [ false, true, true,  false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)
  }

  @Test
  static func testSetValue() {
    let isBlock: Array<LayoutType> = [.inline, .inline, .hardBlock, .inline, .hardBlock, .hardBlock]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // set value
    newlines.setValue(layoutType: .hardBlock, at: 1)
    // [ false, true, true, false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at first position
    newlines.setValue(layoutType: .hardBlock, at: 0)
    // [ true, true, true, false, true, true  ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at last position
    newlines.setValue(layoutType: .inline, at: 5)
    // [ true, true, true, false, true, false ]
    #expect(newlines.asBitArray == [true, true, true, true, true, false])
    #expect(newlines.trailingCount == 5)

    // set value at second last position
    newlines.setValue(layoutType: .inline, at: 4)
    // [ true, true, true, false, false, false ]
    #expect(newlines.asBitArray == [true, true, true, false, false, false])
    #expect(newlines.trailingCount == 3)
  }

  @Test
  static func testReplace() {
    let isBlock: Array<LayoutType> = [.inline, .inline, .hardBlock, .inline, .hardBlock, .hardBlock]
    var newlines = NewlineArray(isBlock)
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // replace empty
    newlines.replaceSubrange(1..<1, with: [.hardBlock, .inline])
    // [false, ꞈ true, false, ꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [true, true, false, true, true, true, true, false])
    #expect(newlines.trailingCount == 6)

    // replace with empty
    newlines.replaceSubrange(1..<3, with: [])
    // [false, ꞈꞈ false, true, false, true, true]
    #expect(newlines.asBitArray == [false, true, true, true, true, false])
    #expect(newlines.trailingCount == 4)

    // replace final segment
    newlines.replaceSubrange(4..<6, with: [.hardBlock])
    // [false, false, true, true, ꞈ true ꞈ]
    #expect(newlines.asBitArray == [false, true, true, true, false])
    #expect(newlines.trailingCount == 3)

    // replace initial segment
    newlines.replaceSubrange(0..<2, with: [.inline])
    // [false, ꞈꞈ true, true, true]
    #expect(newlines.asBitArray == [true, true, true, false])
    #expect(newlines.trailingCount == 3)
  }

  @Test
  static func testRandomReplace() {
    let repeats = 10
    let count = 100
    for _ in 0..<repeats {
      let isBlock: Array<LayoutType> = randomLayoutTypes(count)
      var control = NewlineArray(isBlock)
      var test = NewlineArray(isBlock)
      //
      let range = randomRange(count)
      let placement: Array<LayoutType> = randomLayoutTypes(10)
      control.replaceSubrange(range, with: placement)
      test.replaceSubrange(range, with: placement)
      #expect(control == test)
    }
  }

  private static func randomLayoutTypes(_ count: Int) -> Array<LayoutType> {
    (0..<count).map { _ in LayoutType.allCases.randomElement()! }
  }

  private static func randomRange(_ count: Int) -> Range<Int> {
    guard count > 1 else { return 0..<0 }  // Handle edge case
    let start = Int.random(in: 0..<count)  // Random start
    let end = Int.random(in: start..<count)  // Random end (must be ≥ start)
    return start..<end
  }
}
