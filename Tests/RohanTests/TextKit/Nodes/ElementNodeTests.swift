// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ElementNodeTests {
  @Test
  static func test_getProperties() {
    let styleSheet = ElementNodeTests.sampleStyleSheet()

    do {
      let emphasis = EmphasisNode([TextNode("ab😀")])
      let heading = HeadingNode(level: 1, [emphasis])
      do {
        let properties = heading.getProperties(styleSheet)
        #expect(properties[TextProperty.style] == .fontStyle(.italic))
      }
      do {
        let properties = emphasis.getProperties(styleSheet)
        #expect(properties[TextProperty.style] == .fontStyle(.normal))
      }
    }

    do {
      let emphasis = EmphasisNode([TextNode("cd😀")])
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
  static func test_stringify() {
    let root = RootNode([
      HeadingNode(level: 1, [TextNode("abc😀")]),
      ParagraphNode([TextNode("def")]),
    ])

    #expect(root.stringify() == "abc😀\ndef")
  }

  @Test
  static func test_isBlock() {
    let heading = HeadingNode(level: 1, [TextNode("abc")])
    #expect(heading.isBlock == true)

    let paragraph = ParagraphNode([TextNode("abc")])
    #expect(paragraph.isBlock == true)
  }

  /// intrinsic length, extrinsic length, and layout length
  @Test
  static func testLength() {
    let emphasis = EmphasisNode([
      TextNode("a😀b"),
      EquationNode(isBlock: true, nuc: [TextNode("a+b")]),
    ])
    #expect(emphasis.layoutLength() == 6)

    let heading = HeadingNode(
      level: 1,
      [
        TextNode("a😀b"),
        EquationNode(isBlock: true, nuc: [TextNode("a+b")]),
      ])
    #expect(heading.layoutLength() == 7)

    let paragraph = ParagraphNode([
      TextNode("a😀b"),
      EquationNode(isBlock: false, nuc: [TextNode("a+b")]),
    ])
    #expect(paragraph.layoutLength() == 6)

    let root = RootNode([
      ParagraphNode([
        TextNode("a😀b"),
        EquationNode(isBlock: false, nuc: [TextNode("a+b")]),
      ]),
      ParagraphNode([TextNode("def")]),
    ])
    #expect(root.layoutLength() == 12)
  }

  @Test
  static func test_getLayoutOffset() {
    let root = RootNode([
      HeadingNode(level: 1, [TextNode("abc😀")]),
      ParagraphNode([TextNode("def")]),
    ])

    #expect(
      root.layoutLengthSynopsis() == """
        root 12
        ├ heading 6
        │ └ text 5
        └ paragraph 4
          └ text 3
        """)

    #expect(root.getLayoutOffset(.index(1)) == 8)
  }

  static func sampleStyleSheet() -> StyleSheet {
    let h1Font = "Latin Modern Sans"
    let textFont = "Latin Modern Roman"
    let mathFont = "Latin Modern Math"

    let styleRules: StyleRules = [
      // H1
      HeadingNode.selector(level: 1): [
        TextProperty.font: .string(h1Font),
        TextProperty.size: .fontSize(FontSize(20)),
        TextProperty.style: .fontStyle(.italic),
        TextProperty.foregroundColor: .color(.blue),
      ]
    ]

    let defaultProperties: PropertyMapping =
      [
        // text
        TextProperty.font: .string(textFont),
        TextProperty.size: .fontSize(FontSize(12)),
        TextProperty.stretch: .fontStretch(.normal),
        TextProperty.style: .fontStyle(.normal),
        TextProperty.weight: .fontWeight(.regular),
        TextProperty.foregroundColor: .color(.black),
        // equation
        MathProperty.font: .string(mathFont),
        MathProperty.bold: .bool(false),
        MathProperty.italic: .none,
        MathProperty.cramped: .bool(false),
        MathProperty.style: .mathStyle(.display),
        MathProperty.variant: .mathVariant(.serif),
        // paragraph
        ParagraphProperty.textAlignment: .textAlignment(.justified),
        // page (a4)
        PageProperty.width: .absLength(.mm(210)),
        PageProperty.height: .absLength(.mm(297)),
        PageProperty.topMargin: .absLength(.mm(25)),
        PageProperty.bottomMargin: .absLength(.mm(25)),
        PageProperty.leftMargin: .absLength(.mm(25)),
        PageProperty.rightMargin: .absLength(.mm(25)),
      ]

    return StyleSheet(styleRules, defaultProperties)
  }
}
