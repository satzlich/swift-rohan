// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import Testing

@testable import SwiftRohan

struct CounterTests {
  @Test
  func construction() {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("Plaintext")
      ]),
      HeadingNode(
        .section,
        [
          TextNode("Emit HeadingNode")
        ]),
      ParagraphNode([
        TextNode("Plaintext")
      ]),
      HeadingNode(
        .subsection,
        [
          TextNode("Emit HeadingNode with subsection")
        ]),
      ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(
          .equation,
          [
            TextNode("a=b+c")
          ]),
      ]),
    ])

    guard let counterSegment = rootNode.counterSegment else {
      Issue.record("Counter segment is nil")
      return
    }

    do {
      let begin = counterSegment.begin
      let end = counterSegment.end
      #expect(CountHolder.countSubrange(begin, inclusive: end) == 3)
      #expect(begin.value(forName: .section) == 1)
      #expect(begin.value(forName: .subsection) == 0)
      #expect(begin.value(forName: .equation) == 0)
      #expect(end.value(forName: .section) == 1)
      #expect(end.value(forName: .subsection) == 1)
      #expect(end.value(forName: .equation) == 1)
    }
  }

  private func _takeChildrenExample() -> (RootNode, ElementNode) {
    let emphasisNode = TextStylesNode(
      .emph,
      [
        TextNode("Emphasis"),
        NamedSymbolNode(.lookup("dag")!),
      ])
    let rootNode = RootNode([
      ParagraphNode([emphasisNode]),
      HeadingNode(.section, [TextNode("Heading")]),
    ])
    return (rootNode, emphasisNode)
  }

  @Test
  func takeChildren() {
    let (rootNode, emphasisNode) = _takeChildrenExample()
    #expect(rootNode.counterSegment?.holderCount() == 1)
    _ = emphasisNode.takeChildren(inStorage: true)
    #expect(rootNode.counterSegment?.holderCount() == 1)
    _ = rootNode.takeChildren(inStorage: true)
    #expect(rootNode.counterSegment?.holderCount() == nil)
  }

  @Test
  func takeSubrange() {
    do {
      let (rootNode, emphasisNode) = _takeChildrenExample()
      withExtendedLifetime(rootNode) {
        _ = emphasisNode.takeSubrange(1..<1, inStorage: true)
        _ = emphasisNode.takeSubrange(0..<2, inStorage: true)
      }
    }
    do {
      let (rootNode, emphasisNode) = _takeChildrenExample()
      withExtendedLifetime(rootNode) {
        _ = emphasisNode.takeSubrange(0..<1, inStorage: true)
      }
    }
    do {
      let (rootNode, _) = _takeChildrenExample()
      #expect(rootNode.counterSegment?.holderCount() == 1)
      _ = rootNode.takeSubrange(1..<2, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == nil)
    }
  }

  private func _replaceChildExample() -> (RootNode, ElementNode) {
    let paragraphNode = ParagraphNode([TextNode("Plaintext")])
    let rootNode = RootNode([
      paragraphNode,
      HeadingNode(.section, [TextNode("Heading")]),
    ])
    return (rootNode, paragraphNode)
  }

  @Test
  func replaceChild() {
    let (rootNode, paragraphNode) = _replaceChildExample()

    #expect(rootNode.counterSegment?.holderCount() == 1)
    #expect(paragraphNode.counterSegment?.holderCount() == nil)

    paragraphNode.replaceChild(EquationNode(.equation), at: 0, inStorage: true)

    #expect(rootNode.counterSegment?.holderCount() == 2)
    #expect(paragraphNode.counterSegment?.holderCount() == 1)

    rootNode.replaceChild(
      HeadingNode(.subsection, [TextNode("subsection")]), at: 1, inStorage: true)

    #expect(rootNode.counterSegment?.holderCount() == 2)
    #expect(paragraphNode.counterSegment?.holderCount() == 1)

    paragraphNode.replaceChild(TextNode("plaintext"), at: 0, inStorage: true)

    #expect(rootNode.counterSegment?.holderCount() == 1)
    #expect(paragraphNode.counterSegment?.holderCount() == nil)
  }

  @Test
  func insertChildren() {

  }

  @Test
  func removeSubrange() {

  }
}
