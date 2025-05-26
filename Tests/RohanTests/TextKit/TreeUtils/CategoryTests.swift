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
      (AccentNode(MathAccent.grave, nucleus: []), .mathContent),
      (AttachNode(nuc: []), .mathContent),
      (EquationNode(.block, []), .topLevelNodes),
      (EquationNode(.inline, []), .extendedText),
      (FractionNode(num: [], denom: []), .mathContent),
      (LeftRightNode(DelimiterPair.PAREN, []), .mathContent),
      (MathExpressionNode(MathExpression.colon), .mathContent),
      (MathKindNode(.mathpunct, [TextNode(":")]), .mathContent),
      (MathLimitsNode(._limits, [TextNode("world")]), .mathContent),
      (MathOperatorNode(MathOperator.min), .mathContent),
      (NamedSymbolNode(NamedSymbol.lookup("rightarrow")!), .mathText),
      (NamedSymbolNode(NamedSymbol.lookup("S")!), .universalText),
      (MathVariantNode(MathTextStyle.mathfrak, []), .mathContent),
      (
        MatrixNode(.pmatrix, [MatrixNode.Row([MatrixNode.Cell([TextNode("a")])])]),
        .mathContent
      ),
      (OverlineNode([]), .mathContent),
      (OverspreaderNode(MathSpreader.overbrace, []), .mathContent),
      (RadicalNode([], []), .mathContent),
      (TextModeNode([]), .mathContent),
      (UnderlineNode([]), .mathContent),
      (UnderspreaderNode(MathSpreader.underbrace, []), .mathContent),
      // template
      (ApplyNode(MathTemplateSamples.newtonsLaw, [])!, .mathContent),
      (VariableNode(0), nil),
    ]

    do {
      let coveredTypes = Set(testCases.map { $0.0.type })
      let uncoveredTypes = Set(NodeType.allCases).subtracting(coveredTypes)
      #expect(uncoveredTypes == [.argument, .cVariable])
    }

    for (i, (node, expected)) in testCases.enumerated() {
      let category = TreeUtils.contentCategory(of: [node])
      #expect(category == expected, "\(i) \(node.type)")
    }
  }

  @Test
  func containterCategory() {
    for category in ContainerCategory.allCases {
      _ = category.layoutMode()
    }
  }
}
