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
      // element
      (ContentNode([TextNode("Hello")]), .plaintext),
      (EmphasisNode([]), .inlineContent),
      (HeadingNode(level: 1, []), .topLevelNodes),
      (ParagraphNode([]), .paragraphNodes),
      (RootNode([]), nil),
      (StrongNode([]), .inlineContent),
      // math
      (AccentNode(accent: "`", nucleus: []), .mathContent),
      (AttachNode(nuc: []), .mathContent),
      (CasesNode([] as Array<CasesNode.Row>), .mathContent),
      (EquationNode(isBlock: false, nuc: []), .inlineContent),
      (EquationNode(isBlock: true, nuc: []), .topLevelNodes),
      (EquationNode(isBlock: false, nuc: []), .inlineContent),
      (FractionNode(num: [], denom: []), .mathContent),
      (LeftRightNode(DelimiterPair.PAREN, []), .mathContent),
      (MathOperatorNode([], false), .mathContent),
      (MathVariantNode(.frak, bold: nil, italic: nil, []), .mathContent),
      (MatrixNode([], DelimiterPair.PAREN), .mathContent),
      (OverlineNode([]), .mathContent),
      (OverspreaderNode(Characters.overBrace, []), .mathContent),
      (RadicalNode([], []), .mathContent),
      (TextModeNode([]), .mathContent),
      (UnderlineNode([]), .mathContent),
      (UnderspreaderNode(Characters.underBrace, []), .mathContent),
      // template
      (ApplyNode(CompiledSamples.newtonsLaw, [])!, .mathContent),
      (VariableNode(0), nil),
    ]

    #expect(testCases.count - NodeType.allCases.count == 0)

    for (node, expected) in testCases {
      let category = TreeUtils.contentCategory(of: [node])
      #expect(category == expected)
    }
  }
}
