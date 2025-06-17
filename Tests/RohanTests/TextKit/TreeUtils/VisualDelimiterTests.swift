// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class VisualDelimiterTests: TextKitTestsBase {
  private var styleSheet: StyleSheet = StyleSheetTests.testingStyleSheet()

  @Test
  func treeUtils() {
    let tree = RootNode([
      ParagraphNode([
        TextStylesNode(.emph, [TextNode("Hello")]),
        TextNode(" "),
        TextStylesNode(.textbf, []),
      ])
    ])

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
      // to textStyles (empty)
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

  @Test
  func documentManager() {
    let rootNode = RootNode([
      EquationNode(
        .inline,
        [
          ApplyNode(.pmod, [[TextNode("a")]])!
        ])
    ])

    let location = TextLocation.parse("[↓0,nuc,↓0,⇒0]:0")!
    guard
      let (range, level) = TreeUtils.visualDelimiterRange(
        for: location, rootNode, styleSheet)
    else {
      Issue.record("Failed to get visual delimiter range")
      return
    }
    #expect("\(range)" == "[↓0,nuc,↓0,⇒0]:0..<[↓0,nuc,↓0,⇒0]:1")
    #expect(level == 4)
  }
}
