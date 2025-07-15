// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct CategoryTests {
  @Test
  static func contentCategory() {
    let testCases: [(Node, ContentCategory?)] = [
      (CounterNode(.equation), .textText),
      (LinebreakNode(), .arbitraryParagraphContent),
      (TextNode("Hello"), .plaintext),
      (UnknownNode(), .arbitraryParagraphContent),
      // element
      (ContentNode([TextNode("Hello")]), .plaintext),
      (ExpansionNode([TextNode("Hello")], .inline), .plaintext),
      (HeadingNode(.sectionAst, []), .toplevelNodes),
      (ItemListNode(.enumerate, []), .toplevelParagraphContent),
      (ParagraphNode([]), .paragraphNodes),
      (ParListNode([]), .toplevelNodes),
      (RootNode([]), nil),
      (TextStylesNode(.emph, []), .arbitraryParagraphContent),
      (TextStylesNode(.textbf, []), .arbitraryParagraphContent),
      // math
      (AccentNode(MathAccent.grave, nucleus: []), .mathContent),
      (AttachNode(nuc: []), .mathContent),
      (EquationNode(.display, []), .arbitraryParagraphContent),
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
        .arbitraryParagraphContent
      ),
      (RadicalNode([], index: []), .mathContent),
      (TextModeNode([]), .mathContent),
      (UnderOverNode(MathSpreader.overbrace, []), .mathContent),
      (UnderOverNode(MathSpreader.overline, []), .mathContent),
      (UnderOverNode(MathSpreader.underbrace, []), .mathContent),
      (UnderOverNode(MathSpreader.underline, []), .mathContent),
      // template
      (ApplyNode(MathTemplateSamples.newtonsLaw, [])!, .mathContent),
      (VariableNode(0, .inline, false), nil),
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
