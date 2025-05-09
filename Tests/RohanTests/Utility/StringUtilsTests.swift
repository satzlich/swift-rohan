// Copyright 2024-2025 Lie Yan

import Foundation
import Testing
import _RopeModule

@testable import SwiftRohan

struct StringUtilsTests {
  
  @Test
  func getNodes_fromRaw() {
    do {
      let text = "abcd efgh"
      let nodes = StringUtils.getNodes(fromRaw: text)
    }
    
    do {
      let text = "abcd \n\nefgh\n\nijk"
      let nodes = StringUtils.getNodes(fromRaw: text)
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
}
