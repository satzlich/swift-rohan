// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ElementNodeTests {
  @Test
  func coverage() {
    let elements: Array<ElementNode> = ElementNodeTests.allSamples()

    for element in elements {
      _ = element.cloneEmpty()
      _ = element.createSuccessor()
    }
  }

  static func allSamples() -> Array<ElementNode> {
    [
      RootNode([ParagraphNode([TextNode("abc")])]),
      //
      ContentNode([TextNode("abc")]),
      CrampedNode([TextNode("abc")]),
      DegreeNode([TextNode("abc")]),
      DenominatorNode([TextNode("abc")]),
      NumeratorNode([TextNode("abc")]),
      SubscriptNode([TextNode("abc")]),
      SuperscriptNode([TextNode("abc")]),
      //
      StrongNode(.emph, [TextNode("abc")]),
      HeadingNode(level: 1, [TextNode("abc")]),
      ParagraphNode([TextNode("abc")]),
      StrongNode(.textbf, [TextNode("abc")]),
    ]
  }

  // MARK: - Legacy

  @Test
  static func getProperties() {
    let styleSheet = StyleSheetTests.testingStyleSheet()

    do {
      let emphasis = StrongNode(.emph, [TextNode("ab😀")])
      let heading = HeadingNode(level: 1, [emphasis])
      do {
        let properties = heading.getProperties(styleSheet)
        #expect(properties[TextProperty.style] == nil)
      }
      do {
        let properties = emphasis.getProperties(styleSheet)
        #expect(properties[TextProperty.style] == .fontStyle(.italic))
      }
    }

    do {
      let emphasis = StrongNode(.emph, [TextNode("cd😀")])
      let paragraph = ParagraphNode([emphasis])
      do {
        let properties = emphasis.getProperties(styleSheet)
        #expect(properties[TextProperty.font] == nil)
        #expect(properties[TextProperty.style] == .fontStyle(.italic))
      }
      do {
        let properties = paragraph.getProperties(styleSheet)
        #expect(properties.isEmpty)
      }
    }
  }

  @Test
  func layoutLength() {
    let emphasis = StrongNode(
      .emph,
      [
        TextNode("a😀b"),
        EquationNode(.block, [TextNode("a+b")]),
      ])
    TestUtils.updateLayoutLength(emphasis)
    #expect(emphasis.layoutLength() == 6)

    let heading = HeadingNode(
      level: 1,
      [
        TextNode("a😀b"),
        EquationNode(.block, [TextNode("a+b")]),
      ])
    TestUtils.updateLayoutLength(heading)
    #expect(heading.layoutLength() == 6)

    let paragraph = ParagraphNode([
      TextNode("a😀b"),
      EquationNode(.inline, [TextNode("a+b")]),
    ])
    TestUtils.updateLayoutLength(paragraph)
    if NodePolicy.isInlineMathReflowEnabled {
      #expect(paragraph.layoutLength() == 6)
    }
    else {
      #expect(paragraph.layoutLength() == 5)
    }

    let root = RootNode([
      ParagraphNode([
        TextNode("a😀b"),
        EquationNode(.inline, [TextNode("a+b")]),
      ]),
      ParagraphNode([TextNode("def")]),
    ])
    TestUtils.updateLayoutLength(root)
    do {
      let expected = NodePolicy.isInlineMathReflowEnabled ? 11 : 10
      #expect(root.layoutLength() == expected)
    }
  }

  @Test
  func getLayoutOffset() {
    let root = RootNode([
      HeadingNode(level: 1, [TextNode("abc😀")]),
      ParagraphNode([TextNode("def")]),
    ])

    TestUtils.updateLayoutLength(root)

    #expect(
      root.layoutLengthSynopsis() == """
        root 10
        ├ heading 5
        │ └ text 5
        └ paragraph 3
          └ text 3
        """)

    #expect(root.getLayoutOffset(.index(1)) == 6)
  }
}
