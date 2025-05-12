// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct CategoryTests {
  @Test
  static func contentCategory() {
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
      (
        AlignedNode([AlignedNode.Row([AlignedNode.Element([TextNode("a")])])]),
        .mathContent
      ),
      (AttachNode(nuc: []), .mathContent),
      (CasesNode([CasesNode.Row([CasesNode.Element([TextNode("a")])])]), .mathContent),
      (EquationNode(isBlock: false, nuc: []), .inlineContent),
      (EquationNode(isBlock: true, nuc: []), .topLevelNodes),
      (EquationNode(isBlock: false, nuc: []), .inlineContent),
      (FractionNode(num: [], denom: []), .mathContent),
      (LeftRightNode(DelimiterPair.PAREN, []), .mathContent),
      (MathOperatorNode([], false), .mathContent),
      (MathVariantNode(.frak, bold: nil, italic: nil, []), .mathContent),
      (
        MatrixNode(
          DelimiterPair.PAREN, [MatrixNode.Row([MatrixNode.Element([TextNode("a")])])]),
        .mathContent
      ),
      (OverlineNode([]), .mathContent),
      (OverspreaderNode(Chars.overBrace, []), .mathContent),
      (RadicalNode([], []), .mathContent),
      (TextModeNode([]), .mathContent),
      (UnderlineNode([]), .mathContent),
      (UnderspreaderNode(Chars.underBrace, []), .mathContent),
      // template
      (ApplyNode(CompiledSamples.newtonsLaw, [])!, .mathContent),
      (VariableNode(0), nil),
    ]

    do {
      let coveredTypes = Set(testCases.map { $0.0.type })
      let uncoveredTypes = Set(NodeType.allCases).subtracting(coveredTypes)
      #expect(uncoveredTypes == [.argument, .cVariable])
    }

    for (node, expected) in testCases {
      let category = TreeUtils.contentCategory(of: [node])
      #expect(category == expected)
    }
  }

  @Test
  func containterCategory() {
    for category in ContainerCategory.allCases {
      _ = category.layoutMode()
    }
  }
}
