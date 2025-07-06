// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import Testing

@testable import SwiftRohan

/// Test the counter maintenance logic in the node tree.
struct CounterMaintenanceTests {
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

  private func _takeChildrenExample() -> (RootNode, TextStylesNode) {
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

  private func _replaceChildExample() -> (RootNode, ParagraphNode) {
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

  private func _insertChildrenExample() -> RootNode {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("Plaintext")
      ]),
      ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("a=b+c")]),
        TextNode("Plaintext"),
      ]),
      ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("a=b+c")]),
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("d=e+f")]),
      ]),
    ])
    return rootNode
  }

  @Test
  func insertChildren() {

    func createChildren() -> Array<Node> {
      [
        EquationNode(.equation, [TextNode("x=y+z")]),
        TextNode("More plaintext"),
        EquationNode(.equation, [TextNode("p=q+r")]),
      ]
    }

    // insert into empty
    do {
      let rootNode = _insertChildrenExample()
      #expect(rootNode.counterSegment?.holderCount() == 3)
      let paragraphNode = rootNode.getChild(0) as! ParagraphNode
      paragraphNode.insertChildren(contentsOf: createChildren(), at: 0, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 5)
    }

    // insert to the left
    do {
      let rootNode = _insertChildrenExample()
      #expect(rootNode.counterSegment?.holderCount() == 3)
      let paragraphNode = rootNode.getChild(1) as! ParagraphNode
      paragraphNode.insertChildren(contentsOf: createChildren(), at: 0, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 5)
    }

    // insert to the right
    do {
      let rootNode = _insertChildrenExample()
      #expect(rootNode.counterSegment?.holderCount() == 3)
      let paragraphNode = rootNode.getChild(1) as! ParagraphNode
      paragraphNode.insertChildren(contentsOf: createChildren(), at: 2, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 5)
    }

    // insert to the interior
    do {
      let rootNode = _insertChildrenExample()
      #expect(rootNode.counterSegment?.holderCount() == 3)
      let paragraphNode = rootNode.getChild(2) as! ParagraphNode
      paragraphNode.insertChildren(contentsOf: createChildren(), at: 2, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 5)
    }
  }

  private func _removeSubrangeExample() -> (RootNode, ParagraphNode) {
    let paragraphNode = ParagraphNode([
      TextNode("abc"),
      EquationNode(.equation, [TextNode("a=b+c")]),
      TextNode("def"),
      EquationNode(.equation, [TextNode("d=e+f")]),
      TextNode("ghi"),
      EquationNode(.equation, [TextNode("g=h+i")]),
      TextNode("jkl"),
    ])
    let rootNode = RootNode([
      paragraphNode,
      HeadingNode(.section, [TextNode("Heading")]),
    ])
    return (rootNode, paragraphNode)
  }

  @Test
  func removeSubrange() {
    // remove all
    do {
      let (rootNode, paragraphNode) = _removeSubrangeExample()
      #expect(rootNode.counterSegment?.holderCount() == 4)
      paragraphNode.removeSubrange(1..<6, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 1)
    }
    // remove left
    do {
      let (rootNode, paragraphNode) = _removeSubrangeExample()
      #expect(rootNode.counterSegment?.holderCount() == 4)
      paragraphNode.removeSubrange(1..<4, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }
    // remove right
    do {
      let (rootNode, paragraphNode) = _removeSubrangeExample()
      #expect(rootNode.counterSegment?.holderCount() == 4)
      paragraphNode.removeSubrange(3..<6, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }
    // remove interior
    do {
      let (rootNode, paragraphNode) = _removeSubrangeExample()
      #expect(rootNode.counterSegment?.holderCount() == 4)
      paragraphNode.removeSubrange(3..<4, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 3)
    }
  }

  @Test
  func contentDidChange_newAdded() {
    // add new to empty with propagation
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext")
      ])
      let rootNode = RootNode([
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ])
      ])
      #expect(rootNode.counterSegment?.holderCount() == nil)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 1)
    }

    // previous is empty
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext")
      ])
      let rootNode = RootNode([
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ]),
        HeadingNode(.subsection, [TextNode("Subsection")]),
      ])
      #expect(rootNode.counterSegment?.holderCount() == 1)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }

    // next is empty
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext")
      ])
      let rootNode = RootNode([
        HeadingNode(.section, [TextNode("section")]),
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ]),
      ])
      #expect(rootNode.counterSegment?.holderCount() == 1)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }

    // previous, next are non-empty
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext")
      ])
      let rootNode = RootNode([
        HeadingNode(.section, [TextNode("section")]),
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ]),
        HeadingNode(.section, [TextNode("section")]),
      ])
      #expect(rootNode.counterSegment?.holderCount() == 2)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 3)
    }
  }

  @Test
  func contentDidChange_leftAdded_rightAdded() {
    func testingExample1() -> (RootNode, ParagraphNode) {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("a=b+c")]),
        TextNode("Plaintext"),
      ])
      let rootNode = RootNode([
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ])
      ])
      return (rootNode, paragraphNode)
    }

    // left added
    do {
      let (rootNode, paragraphNode) = testingExample1()
      #expect(rootNode.counterSegment?.holderCount() == 1)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }

    // right added
    do {
      let (rootNode, paragraphNode) = testingExample1()
      #expect(rootNode.counterSegment?.holderCount() == 1)
      paragraphNode.insertChild(EquationNode(.equation), at: 2, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 2)
    }

    // left added -> interior modified
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("a=b+c")]),
        TextNode("Plaintext"),
      ])
      let rootNode = RootNode([
        HeadingNode(.section, [TextNode("section")]),
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ]),
      ])
      #expect(rootNode.counterSegment?.holderCount() == 2)
      paragraphNode.insertChild(EquationNode(.equation), at: 1, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 3)
    }

    // right added -> interior modified
    do {
      let paragraphNode = ParagraphNode([
        TextNode("Plaintext"),
        EquationNode(.equation, [TextNode("a=b+c")]),
        TextNode("Plaintext"),
      ])
      let rootNode = RootNode([
        ParagraphNode([
          ItemListNode(
            .itemize,
            [
              paragraphNode
            ])
        ]),
        HeadingNode(.section, [TextNode("section")]),
      ])
      #expect(rootNode.counterSegment?.holderCount() == 2)
      paragraphNode.insertChild(EquationNode(.equation), at: 2, inStorage: true)
      #expect(rootNode.counterSegment?.holderCount() == 3)
    }
  }
  
  @Test
  func contentDidChange_allRemoved() {
    
  }
}
