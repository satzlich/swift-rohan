import Foundation
import Testing

@testable import SwiftRohan

struct PathTests {
  @Test
  func getNode() {
    let textNode = TextNode("Hello")

    let tree = RootNode([
      ParagraphNode([
        textNode
      ])
    ])

    do {
      let valid = TextLocation.parse("[↓0]:0")!
      #expect(TreeUtils.getNode(at: valid, tree) === textNode)
      #expect(TreeUtils.getNode(at: valid.asArray, tree) === textNode)
    }

    do {
      // valid but to a character instead of a node
      let valid = TextLocation.parse("[↓0,↓0]:3")!
      #expect(TreeUtils.getNode(at: valid, tree) == nil)
      #expect(TreeUtils.getNode(at: valid.asArray, tree) == nil)
    }

    do {
      let invalid = TextLocation.parse("[↓0,↓0,↓0]:3")!
      #expect(TreeUtils.getNode(at: invalid, tree) == nil)
      #expect(TreeUtils.getNode(at: invalid.asArray, tree) == nil)
    }

    // Boundary case
    do {
      #expect(TreeUtils.getNode(at: [], tree) === tree)
    }
  }

  @Test
  func computeLayoutOffset() {
    let tree = RootNode([
      ParagraphNode([
        TextNode("Hello")
      ])
    ])

    do {
      let valid = TextLocation.parse("[↓0,↓0]:3")!
      let layoutOffset =
        TreeUtils.computeLayoutOffset(for: valid.asArraySlice, isFinal: true, tree)
      #expect(layoutOffset == 3)
    }

    do {
      let invalid = TextLocation.parse("[↓0,↓0]:100")!
      let layoutOffset =
        TreeUtils.computeLayoutOffset(for: invalid.asArraySlice, isFinal: true, tree)
      #expect(layoutOffset == nil)
    }

    do {
      let invalid = TextLocation.parse("[↓0,↓0,↓0]:4")!
      let layoutOffset =
        TreeUtils.computeLayoutOffset(for: invalid.asArraySlice, isFinal: true, tree)
      #expect(layoutOffset == nil)
    }
  }
}
