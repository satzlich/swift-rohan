import AppKit
import Foundation
import Testing

@testable import SwiftRohan

struct ElementNodeLayoutTests {

  // MARK: - From Scratch

  @Test
  func elementNodes_fromScratch() {
    let elements: Array<ElementNode> = ElementNodeTests.allSamples()
    let styleSheet = StyleSheetTests.testingStyleSheet()

    for element in elements {
      let context = TextLayoutContext(styleSheet)

      context.beginEditing()
      _ = element.performLayout(context, fromScratch: true, atBlockEdge: true)
      context.endEditing()
    }
  }

  // MARK: - Full Layout

  private func _createExample(_ rootNode: RootNode) -> (RootNode, TextLayoutContext) {
    let styleSheet = StyleSheetTests.testingStyleSheet()
    let context = TextLayoutContext(styleSheet)
    do {
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: true, atBlockEdge: true)
      context.endEditing()
    }
    return (rootNode, context)
  }

  private func _makeElementNodeExample() -> (RootNode, TextLayoutContext) {
    let rootNode = RootNode([
      ParagraphNode([TextNode("Hello, world!")]),
      HeadingNode(.sectionAst, [TextNode("Mary has a little lamb.")]),
      ParagraphNode([TextNode("All I want is freedom, a world with no more night")]),
      ParagraphNode([TextNode("Veni. Vedi. Veci.")]),
    ])
    return _createExample(rootNode)
  }

  @Test
  func elementNodes_Full() {
    // (1) delete + dirty
    do {
      let (rootNode, context) = _makeElementNodeExample()

      let range = RhTextRange.parse("[↓0,↓0]:6..<[↓2,↓0]:4")!
      let result = TreeUtils.removeTextRange(range, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }

    // (2) add + dirty
    do {
      let (rootNode, context) = _makeElementNodeExample()

      let location = TextLocation.parse("[↓0,↓0]:6")!
      let nodes = [
        ParagraphNode([TextNode("abc")]),
        HeadingNode(.sectionAst, [TextNode("def")]),
        ParagraphNode([TextNode("ghi")]),
      ]
      let result = TreeUtils.insertBlockNodes(nodes, at: location, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }

    // (3) delete to activate placeholder
    do {
      let (rootNode, context) = _makeElementNodeExample()
      let range = RhTextRange.parse("[↓1]:0..<[↓1]:1")!
      let result = TreeUtils.removeTextRange(range, rootNode)
      assert(result.isSuccess)

      //
      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }

    // (4) add to activate the case of (insertNewline=false, insertNewline'=true)
    do {
      let (rootNode, context) = _makeElementNodeExample()
      assert(rootNode.childCount == 4)
      let location = TextLocation.parse("[]:4")!

      let nodes = [ParagraphNode([TextNode("cdef")])]
      let result = TreeUtils.insertBlockNodes(nodes, at: location, rootNode)
      assert(result.isSuccess)

      context.resetCursor()
      context.beginEditing()
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }

    // (5) delete to trigger double changes of delete range
    do {
      let (rootNode, context) = _makeElementNodeExample()
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
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }

    // (6) delete to trigger double changes of delete range
    do {
      let (rootNode, context) = _makeElementNodeExample()
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
      _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
      context.endEditing()
      assert(context.layoutCursor == rootNode.layoutLength())
    }
  }

  // MARK: - Equation In ItemList

  private func _makeEquationInItemListExample() -> (RootNode, TextLayoutContext) {
    let rootNode = RootNode([
      ParagraphNode([
        ItemListNode(
          .itemize,
          [
            ParagraphNode([
              EquationNode(.equation, [TextNode("a=b+c")])
            ])
          ])
      ])
    ])
    return _createExample(rootNode)
  }

  /// Edge case where a single equation lies in an item list.
  @Test
  func equationInItemList() {
    let (rootNode, context) = _makeEquationInItemListExample()
    assert(rootNode.childCount == 1)
    let location = TextLocation.parse("[↓0,↓0,↓0]:0")!
    let result = TreeUtils.insertString("x", at: location, rootNode)
    assert(result.isSuccess)

    context.resetCursor()
    context.beginEditing()
    _ = rootNode.performLayout(context, fromScratch: false, atBlockEdge: true)
    context.endEditing()
    assert(context.layoutCursor == rootNode.layoutLength())
  }
}
