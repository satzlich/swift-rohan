// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

struct ElementNodeLayoutTests {

  // MARK: - Element Nodes

  @Test
  func elementNodes_fromScratch() {
    let elements: Array<ElementNode> = ElementNodeTests.allSamples()
    let styleSheet = StyleSheetTests.testingStyleSheet()

    for element in elements {
      let context = TextLayoutContext(styleSheet)

      context.beginEditing()
      _ = element.performLayout(context, fromScratch: true)
      context.endEditing()
    }
  }

  private func elementNodesSample() -> (RootNode, TextLayoutContext) {
    let rootNode = RootNode([
      ParagraphNode([TextNode("Hello, world!")]),
      HeadingNode(level: 1, [TextNode("Mary has a little lamb.")]),
      ParagraphNode([TextNode("All I want is freedom, a world with no more night")]),
      ParagraphNode([TextNode("Veni. Vedi. Veci.")]),
    ])

    let styleSheet = StyleSheetTests.testingStyleSheet()
    let context = TextLayoutContext(styleSheet)
    do {
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: true)
      context.endEditing()
    }

    return (rootNode, context)
  }

  @Test
  func elementNodes_Full() {
    // (1) delete + dirty
    do {
      let (rootNode, context) = elementNodesSample()

      let range = RhTextRange.parse("[↓0,↓0]:6..<[↓2,↓0]:4")!
      let result = TreeUtils.removeTextRange(range, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }

    // (2) add + dirty
    do {
      let (rootNode, context) = elementNodesSample()

      let location = TextLocation.parse("[↓0,↓0]:6")!
      let nodes = [
        ParagraphNode([TextNode("abc")]),
        HeadingNode(level: 1, [TextNode("def")]),
        ParagraphNode([TextNode("ghi")]),
      ]
      let result = TreeUtils.insertBlockNodes(nodes, at: location, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }

    // (3) delete to activate placeholder
    do {
      let (rootNode, context) = elementNodesSample()
      let range = RhTextRange.parse("[↓1]:0..<[↓1]:1")!
      let result = TreeUtils.removeTextRange(range, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }

    // (4) add to activate the case of (insertNewline=false, insertNewline'=true)
    do {
      let (rootNode, context) = elementNodesSample()
      assert(rootNode.childCount == 4)
      let location = TextLocation.parse("[]:4")!

      let nodes = [ParagraphNode([TextNode("cdef")])]
      let result = TreeUtils.insertBlockNodes(nodes, at: location, rootNode)
      assert(result.isSuccess)

      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }

    // (5) delete to trigger double changes of delete range
    do {
      let (rootNode, context) = elementNodesSample()
      assert(rootNode.childCount == 4)
      do {
        let range1 = RhTextRange.parse("[]:3..<[]:4")!
        let result1 = TreeUtils.removeTextRange(range1, rootNode)
        assert(result1.isSuccess)
      }
      do {
        let range2 = RhTextRange.parse("[]:1..<[]:2")!
        let result2 = TreeUtils.removeTextRange(range2, rootNode)
        assert(result2.isSuccess)
      }

      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }

    // (6) delete to trigger double changes of delete range
    do {
      let (rootNode, context) = elementNodesSample()
      assert(rootNode.childCount == 4)
      do {
        let range1 = RhTextRange.parse("[]:3..<[]:4")!
        let result1 = TreeUtils.removeTextRange(range1, rootNode)
        assert(result1.isSuccess)
      }
      do {
        let range2 = RhTextRange.parse("[]:0..<[]:1")!
        let result2 = TreeUtils.removeTextRange(range2, rootNode)
        assert(result2.isSuccess)
      }

      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false)
      context.endEditing()
      assert(context.layoutCursor == 0)
    }
  }
}
