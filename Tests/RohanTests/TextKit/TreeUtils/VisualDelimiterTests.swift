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

    do {
      // paragraph -> emphasis -> text -> <offset>
      let location = TextLocation.parse("[↓0,↓0,↓0]:3")!
      let range = TreeUtils.visualDelimiterRange(for: location, tree)
      #expect(range != nil)

      #expect(range?.description == "[↓0,↓0]:0..<[↓0,↓0]:1")
    }

    do {
      // paragraph -> emphasis -> <offset>
      let location = TextLocation.parse("[↓0,↓0]:0")!
      let range = TreeUtils.visualDelimiterRange(for: location, tree)
      #expect(range?.description == "[↓0,↓0]:0..<[↓0,↓0]:1")
    }

    do {
      // to emphasis
      let location = TextLocation.parse("[↓0]:0")!
      let range = TreeUtils.visualDelimiterRange(for: location, tree)
      #expect(range == nil)
    }

    do {
      // to strong (empty)
      let location = TextLocation.parse("[↓0,↓2]:0")!
      let range = TreeUtils.visualDelimiterRange(for: location, tree)
      #expect(range == nil)
    }

    do {
      // invalid
      let location = TextLocation.parse("[↓0]:8")!
      let range = TreeUtils.visualDelimiterRange(for: location, tree)
      #expect(range == nil)
    }
  }
}
