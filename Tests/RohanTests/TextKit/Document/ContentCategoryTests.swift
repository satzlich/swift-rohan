// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ContentCategoryTests {
  @Test
  static func testSingleNode() {
    let testCases: [(Node, ContentCategory?)] = [
      (LinebreakNode(), .inlineContent),
      (TextNode("Hello"), .plaintext),
      (UnknownNode(), .inlineContent),
      (ContentNode([TextNode("Hello")]), .plaintext),
      (EmphasisNode([]), .inlineContent),
      (HeadingNode(level: 1, []), .topLevelNodes),
      (ParagraphNode([]), .paragraphNodes),
      (RootNode([]), nil),
      (StrongNode([]), .inlineContent),
      (EquationNode(isBlock: false, nucleus: []), .inlineContent),
      (EquationNode(isBlock: true, nucleus: []), .containsBlock),
      (FractionNode(numerator: [], denominator: []), .mathContent),
      (TextModeNode([]), .mathContent),
      (ApplyNode(CompiledSamples.newtonsLaw, [])!, .mathContent),
      (VariableNode(0), nil),
    ]

    #expect(testCases.count - NodeType.allCases.count == -3)

    for (node, expected) in testCases {
      let category = TreeUtils.contentCategory(of: [node])
      #expect(category == expected)
    }
  }
}
