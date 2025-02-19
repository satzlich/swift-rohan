// Copyright 2024-2025 Lie Yan

import Foundation
import Testing
import _RopeModule

@testable import Rohan

struct StringTests {
  @Test
  static func testNewlineCharacter() {
    let a = "\r"
    let b = "\n"
    let c = "\r\n"
    let d = "\n\r"
    #expect(a.count == 1)
    #expect(b.count == 1)
    #expect(c.count == 1)
    #expect(d.count == 2)
  }

  @Test
  static func testCombiningCharacter() {
    do {
      let circumflex = "\u{0302}"  // combining circumflex
      #expect(circumflex.count == 1)
      let space = " "
      #expect(space.count == 1)

      let combined = space + circumflex
      #expect(combined.count == 1)
      #expect(combined.utf16.count == 2)
    }

    do {
      let a = "a"
      let circumflex = "\u{0302}"  // combining circumflex
      let combined = "a\u{0302}"
      #expect(a.count == 1)
      #expect(circumflex.count == 1)
      #expect(combined.count == 1)
    }
  }
  
  @Test
  static func testMathClass() {
    let div = UnicodeScalar("/")
    #expect(div.mathClass == .Binary)
  }
}
