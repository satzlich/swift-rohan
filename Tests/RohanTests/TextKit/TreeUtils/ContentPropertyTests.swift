// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct ContentPropertyTests {
  @Test
  static func contentProperty() {
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
        nodeType: .equation, contentMode: .text, contentType: .block, contentTag: .formula
      )
      testCases.append((node, [content]))
    }
    // EquationNode
    do {
      let node = EquationNode(.inline, [])
      let content = ContentProperty(
        nodeType: .equation, contentMode: .text, contentType: .inline,
        contentTag: .formula)
      testCases.append((node, [content]))
    }
    // FractionNode
    do {
      let node = FractionNode(num: [], denom: [])
      let content = ContentProperty(
        nodeType: .fraction, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // LeftRightNode
    do {
      let node = LeftRightNode(DelimiterPair.PAREN, [])
      let content = ContentProperty(
        nodeType: .leftRight, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // MathAttributesNode
    do {
      let node = MathAttributesNode(.mathLimits(.limits), [TextNode("world")])
      let content = ContentProperty(
        nodeType: .mathAttributes, contentMode: .math, contentType: .inline,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // MathExpressionNode
    do {
      let node = MathExpressionNode(MathExpression.colon)
      let content = ContentProperty(
        nodeType: .mathExpression, contentMode: .math, contentType: .inline,
        contentTag: nil)
      testCases.append((node, [content]))
    }
    // MathOperatorNode
    do {
      let node = MathOperatorNode(MathOperator.min)
      let content = ContentProperty(
        nodeType: .mathOperator, contentMode: .math, contentType: .inline, contentTag: nil
      )
      testCases.append((node, [content]))
    }
    // NamedSymbolNode
    do {
      let node = NamedSymbolNode(NamedSymbol.lookup("rightarrow")!)
      let content = ContentProperty(
        nodeType: .namedSymbol, contentMode: .math, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // NamedSymbolNode
    do {
      let node = NamedSymbolNode(NamedSymbol.lookup("S")!)
      let content = ContentProperty(
        nodeType: .namedSymbol, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }
    // MathStyles
    do {
      let node = MathStylesNode(MathStyles.mathfrak, [])
      let content = ContentProperty(
        nodeType: .mathStyles, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // MatrixNode
    do {
      let node = MatrixNode(
        .pmatrix, [MatrixNode.Row([MatrixNode.Cell([TextNode("a")])])])
      let content = ContentProperty(
        nodeType: .matrix, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // MultilineNode
    do {
      let node = MultilineNode(
        .multlineAst, [MultilineNode.Row([MultilineNode.Cell([TextNode("a")])])])
      let content = ContentProperty(
        nodeType: .multiline, contentMode: .text, contentType: .block,
        contentTag: .formula)
      testCases.append((node, [content]))
    }
    // RadicalNode
    do {
      let node = RadicalNode([], index: [])
      let content = ContentProperty(
        nodeType: .radical, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // TextModeNode
    do {
      let node = TextModeNode([TextNode("Hello")])
      let content = ContentProperty(
        nodeType: .textMode, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content]))
    }
    // UnderOverNode
    do {
      let node1 = UnderOverNode(MathSpreader.overbrace, [])
      let node2 = UnderOverNode(MathSpreader.overline, [])
      let node3 = UnderOverNode(MathSpreader.underbrace, [])
      let node4 = UnderOverNode(MathSpreader.underline, [])
      let content = ContentProperty(
        nodeType: .underOver, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node1, [content]))
      testCases.append((node2, [content]))
      testCases.append((node3, [content]))
      testCases.append((node4, [content]))
    }

    /* Template */

    // ApplyNode
    do {
      let node = ApplyNode(MathTemplateSamples.newtonsLaw, [])!
      let content1 = ContentProperty(
        nodeType: .text, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      let content2 = ContentProperty(
        nodeType: .fraction, contentMode: .math, contentType: .inline, contentTag: nil)
      testCases.append((node, [content1, content2]))
    }
    // VariableNode
    do {
      let node = VariableNode(0, .textit, .inline, false)
      node.insertChild(TextNode("Hello"), at: 0, inStorage: true)
      let content = ContentProperty(
        nodeType: .text, contentMode: .universal, contentType: .inline,
        contentTag: .plaintext)
      testCases.append((node, [content]))
    }

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
}
