// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct CategoryTests {
  @Test
  static func contentCategory() {
    var testCases: Array<(Node, Array<ContentProperty>)> = []

    /* Misc */

    // CounterNode
    do {
      let node = CounterNode(.equation)
      let content = ContentProperty(
        nodeType: .counter, contentMode: .text, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // LinebreakNode
    do {
      let node = LinebreakNode()
      let content = ContentProperty(
        nodeType: .linebreak, contentMode: .text, contentType: .inline,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // TextNode
    do {
      let node = TextNode("Hello")
      let content = ContentProperty(
        nodeType: .text, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // UnknownNode
    do {
      let node = UnknownNode(.bool(false))
      let content = ContentProperty(
        nodeType: .unknown, contentMode: .universal, contentType: .inline,
        contentTag: nil)
      testCases.append((node, [content]))
    }

    /* Element */
    // ContentNode
    do {
      let node = ContentNode([TextNode("Hello")])
      let content = ContentProperty(
        nodeType: .text, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // ExpansionNode
    do {
      let node = ExpansionNode([TextNode("Hello")], .softBlock)
      let content = ContentProperty(
        nodeType: .text, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // HeadingNode
    do {
      let node = HeadingNode(.sectionAst, [])
      let content = ContentProperty(
        nodeType: .heading, contentMode: .text, contentType: .block,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // ItemListNode
    do {
      let node = ItemListNode(.enumerate, [])
      let content = ContentProperty(
        nodeType: .itemList, contentMode: .text, contentType: .block,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // ParagraphNode
    do {
      let node = ParagraphNode([])
      let content = ContentProperty(
        nodeType: .paragraph, contentMode: .text, contentType: .block,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // ParListNode
    do {
      let node = ParListNode([])
      let content = ContentProperty(
        nodeType: .parList, contentMode: .text, contentType: .block,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // RootNode
    do {
      let node = RootNode([])
      let content = ContentProperty(
        nodeType: .root, contentMode: .text, contentType: .block,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // TextStylesNode
    do {
      let node = TextStylesNode(.emph, [])
      let content = ContentProperty(
        nodeType: .textStyles, contentMode: .text, contentType: .inline,
        contentTag: .styledText)
      testCases.append((node, [content]))
    }

    /* Math */

    // AccentNode
    do {
      let node = AccentNode(MathAccent.grave, nucleus: [])
      let content = ContentProperty(
        nodeType: .accent, contentMode: .math, contentType: .inline,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // AttachNode
    do {
      let node = AttachNode(nuc: [])
      let content = ContentProperty(
        nodeType: .attach, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // EquationNode
    do {
      let node = EquationNode(.display, [])
      let content = ContentProperty(
        nodeType: .equation, contentMode: .text, contentType: .block, contentTag: .formula)
      testCases.append((node, [content]))
    }
    // EquationNode
    do {
      let node = EquationNode(.inline, [])
      let content = ContentProperty(
        nodeType: .equation, contentMode: .text, contentType: .inline, contentTag: .formula)
      testCases.append((node, [content]))
    }

    /*
    let testCases: [(Node, ContentProperty?)] = [
    
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
      (VariableNode(0, .textit, .inline, false), nil),
    ]
    
     */

    do {
      let coveredTypes = Set(testCases.map { $0.0.type })
      let uncoveredTypes = Set(NodeType.allCases).subtracting(coveredTypes)
      #expect(uncoveredTypes == [.argument, .cVariable])
    }

    for (i, (node, expected)) in testCases.enumerated() {
      let category = TreeUtils.contentProperty(of: [node])
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
