// Copyright 2024-2025 Lie Yan

import Foundation
import Testing
import _RopeModule

@testable import SwiftRohan

struct StringUtilsTests {
  @Test
  func splice_edgeCase() {
    let str: BigString = "abcd efgh"
    _ = StringUtils.splice(str, 4, "")
  }

  @Test
  func getNodes_fromRaw() {
    do {
      let text = "abcd efgh"
      _ = StringUtils.getNodes(fromRaw: text)
    }

    do {
      let text = "abcd \n\nefgh\n\nijk"
      _ = StringUtils.getNodes(fromRaw: text)
    }
  }

  @Test
  func wordBoundaryRange_enclosing() {
    let text: BigString = "abc def ghi"
    let range = StringUtils.wordBoundaryRange(text, enclosing: 4)
    #expect(range.lowerBound == 4)
    #expect(range.upperBound == 8)

    let range2 = StringUtils.wordBoundaryRange(text, enclosing: 0)
    #expect(range2.lowerBound == 0)
    #expect(range2.upperBound == 4)

    let range3 = StringUtils.wordBoundaryRange(text, enclosing: 11)
    #expect(range3.lowerBound == 8)
    #expect(range3.upperBound == 11)
  }

  // MARK: - Word Boundary

  @Test
  func forwardSelectionAtWordStart() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 0, direction: .forward)
    #expect(range == 0..<5)  // "Hello"
  }

  @Test
  func forwardSelectionMidWord() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 2, direction: .forward)  // 'l' in "Hello"
    #expect(range == 2..<5)  // "llo,"
  }

  @Test
  func forwardSelectionAtPunctuation() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 5, direction: .forward)  // at comma
    #expect(range == 5..<7)  // ", "
  }

  @Test
  func forwardSelectionAtLastWord() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 7, direction: .forward)  // 'w' in "world"
    #expect(range == 7..<12)  // "world"
  }

  @Test
  func forwardSelectionAtEndOfString() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 13, direction: .forward)  // at end
    #expect(range == 13..<13)  // empty range
  }

  @Test
  func forwardSelectionPastSpace() {
    let str = BigString("Hello world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 2, direction: .forward)
    #expect(range == 2..<6)  // "llo "
  }

  @Test
  func backwardSelectionAtWordEnd() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 5, direction: .backward)  // after "Hello"
    #expect(range == 0..<5)  // "Hello"
  }

  @Test
  func backwardSelectionMidWord() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 9, direction: .backward)  // 'r' in "world"
    #expect(range == 7..<9)  // "wo"
  }

  @Test
  func backwardSelectionAtPunctuation() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 6, direction: .backward)  // space after comma
    #expect(range == 5..<6)  // " "
  }

  @Test
  func backwardSelectionAtStartOfString() {
    let str = BigString("Hello, world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 0, direction: .backward)
    #expect(range == 0..<0)  // empty range
  }

  @Test
  func backwardSelectionPastSpace() {
    let str = BigString("Hello world!")
    let range = StringUtils.wordBoundaryRange(str, offset: 6, direction: .backward)
    #expect(range == 0..<6)  // "Hello "
  }

  @Test
  func emptyString() {
    let str = BigString("")
    let range = StringUtils.wordBoundaryRange(str, offset: 0, direction: .forward)
    #expect(range == 0..<0)
  }

  @Test
  func unicodeCharacters() {
    let str = BigString("ab😀cd")  // Test with emoji in string
    do {
      let range = StringUtils.wordBoundaryRange(str, offset: 3, direction: .forward)
      #expect(range == 2..<4)
    }
    do {
      let range = StringUtils.wordBoundaryRange(str, offset: 3, direction: .backward)
      #expect(range == 2..<4)
    }
  }

  @Test
  func mixedContent() {
    let str = BigString("Swift 5.9 is awesome!")
    let range1 = StringUtils.wordBoundaryRange(str, offset: 6, direction: .forward)  // at space
    #expect(range1 == 6..<7)  // " "

    let range2 = StringUtils.wordBoundaryRange(str, offset: 7, direction: .forward)  // "5.9"
    #expect(range2 == 7..<8)
  }
  
  @Test
  func wordBoundaryRange_edgeCases() async throws {
    do {
      let str = BigString("HelloWorld")
      let range1 = StringUtils.wordBoundaryRange(str, offset: 5, direction: .forward)
      #expect(range1 == 5..<10)  // "World"
    }
    do {
      let str = BigString("Hello?,;.")
      let range2 = StringUtils.wordBoundaryRange(str, offset: 5, direction: .forward)
      #expect(range2 == 5..<9)  // ","
    }
    do {
      let str = BigString("  World")
      let range3 = StringUtils.wordBoundaryRange(str, offset: 2, direction: .backward)
      #expect(range3 == 0..<2)  // "  "
    }
    do {
      let str = BigString(" ;,. World")
      let range4 = StringUtils.wordBoundaryRange(str, offset: 5, direction: .backward)
      #expect(range4 == 0..<5)  // ", "
    }
  }
}
