// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct CategoryTests {
  @Test
  static func contentCategory() {
    let testCases: [(Node, ContentCategory?)] = [
      (LinebreakNode(), .paragraphContent),
      (TextNode("Hello"), .plaintext),
      (UnknownNode(), .paragraphContent),
      // element
      (ContentNode([TextNode("Hello")]), .plaintext),
      (HeadingNode(.sectionAst, []), .topLevelNodes),
      (ItemListNode(.enumerate, []), .paragraphContent),
      (ParagraphNode([]), .paragraphNodes),
      (RootNode([]), nil),
      (TextStylesNode(.emph, []), .paragraphContent),
      (TextStylesNode(.textbf, []), .paragraphContent),
      // math
      (AccentNode(MathAccent.grave, nucleus: []), .mathContent),
      (AttachNode(nuc: []), .mathContent),
      (EquationNode(.block, []), .paragraphContent),
      (EquationNode(.inline, []), .extendedText),
      (FractionNode(num: [], denom: []), .mathContent),
      (LeftRightNode(DelimiterPair.PAREN, []), .mathContent),
      (MathAttributesNode(.mathLimits(.limits), [TextNode("world")]), .mathContent),
      (MathExpressionNode(MathExpression.colon), .mathContent),
      (MathOperatorNode(MathOperator.min), .mathContent),
      (NamedSymbolNode(NamedSymbol.lookup("rightarrow")!), .mathText),
      (NamedSymbolNode(NamedSymbol.lookup("S")!), .universalText),
      (MathStylesNode(MathStyles.mathfrak, []), .mathContent),
      (
        MatrixNode(.pmatrix, [MatrixNode.Row([MatrixNode.Cell([TextNode("a")])])]),
        .mathContent
      ),
      (
        MultilineNode(
          .multlineAst,
          [
            MultilineNode.Row([MultilineNode.Cell([TextNode("a")])])
          ]),
        .paragraphContent
      ),
      (RadicalNode([], index: []), .mathContent),
      (TextModeNode([]), .mathContent),
      (UnderOverNode(MathSpreader.overbrace, []), .mathContent),
      (UnderOverNode(MathSpreader.overline, []), .mathContent),
      (UnderOverNode(MathSpreader.underbrace, []), .mathContent),
      (UnderOverNode(MathSpreader.underline, []), .mathContent),
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
