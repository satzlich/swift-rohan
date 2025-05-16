// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct VisualDelimiterTests {
  @Test
  func coverage() {
    let tree = RootNode([
      ParagraphNode([
        EmphasisNode([TextNode("Hello")]),
        TextNode(" "),
        StrongNode([]),
      ])
    ])

    let styleSheet = StyleSheetTests.sampleStyleSheet()

    do {
      // paragraph -> emphasis -> text -> <offset>
      let location = TextLocation.parse("[↓0,↓0,↓0]:3")!
      guard
        let (range, level) =
          TreeUtils.visualDelimiterRange(for: location, tree, styleSheet)
      else {
        Issue.record("Failed to get visual delimiter range")
        return
      }
      #expect(range.description == "[↓0,↓0]:0..<[↓0,↓0]:1")
      #expect(level == 1)
    }

    do {
      // paragraph -> emphasis -> <offset>
      let location = TextLocation.parse("[↓0,↓0]:0")!
      guard
        let (range, level) =
          TreeUtils.visualDelimiterRange(for: location, tree, styleSheet)
      else {
        Issue.record("Failed to get visual delimiter range")
        return
      }
      #expect(range.description == "[↓0,↓0]:0..<[↓0,↓0]:1")
      #expect(level == 1)
    }

    do {
      // to emphasis
      let location = TextLocation.parse("[↓0]:0")!
      let result = TreeUtils.visualDelimiterRange(for: location, tree, styleSheet)
      #expect(result == nil)
    }

    do {
      // to strong (empty)
      let location = TextLocation.parse("[↓0,↓2]:0")!
      let result = TreeUtils.visualDelimiterRange(for: location, tree, styleSheet)
      #expect(result == nil)
    }

    do {
      // invalid
      let location = TextLocation.parse("[↓0]:8")!
      let result = TreeUtils.visualDelimiterRange(for: location, tree, styleSheet)
      #expect(result == nil)
    }
  }
}
