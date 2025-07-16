// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

/// Ensure synchronization between Expr and Node.
final class ExprNodeSyncTests {
  private var exprTypes: Set<ExprType> = []
  private var nodeTypes: Set<NodeType> = []

  @Test
  func serializedTest() throws {
    // (1) testExprNodeSync
    do {
      try testExprNodeSync()
      let uncoveredTypes = Set(ExprType.allCases).subtracting(self.nodeTypes)
      #expect(
        uncoveredTypes == [
          .apply,
          .argument,
          .cVariable,
          .expansion,
          .variable,
        ])
    }
    // (2) testNodeSerde
    do {
      try testNodeSerde()
      let uncoveredTypes = Set(NodeType.allCases).subtracting(self.nodeTypes)
      #expect(uncoveredTypes == NodesTests.uncoveredNodeTypes)
    }

    try testElementWithUnknown()
  }

  private func testExprNodeSync() throws {
    // Element
    do {
      let content = ContentExpr([TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"type":"content"}
        """
      try testSerdeSync(content, ContentNode.self, json)
    }
    do {
      let heading = HeadingExpr(.sectionAst, [TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"subtype":"sectionAst","type":"heading"}
        """
      try testSerdeSync(heading, HeadingNode.self, json)
    }
    do {
      let itemList = ItemListExpr(
        .enumerate,
        [
          ParagraphExpr([TextExpr("abc")]),
          ParagraphExpr([TextExpr("def")]),
        ])
      let json = """
        {"children":[{"children":[{"string":"abc","type":"text"}],"type":"paragraph"},{"children":[{"string":"def","type":"text"}],"type":"paragraph"}],"subtype":"enumerate","type":"itemList"}
        """
      try testSerdeSync(itemList, ItemListNode.self, json)
    }
    do {
      let paragraph = ParagraphExpr([TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"type":"paragraph"}
        """
      try testSerdeSync(paragraph, ParagraphNode.self, json)
    }
    do {
      let parList = ParListExpr([ParagraphExpr([TextExpr("abc")])])
      let json =
        """
        {"children":[{"children":[{"string":"abc","type":"text"}],"type":"paragraph"}],"type":"parList"}
        """
      try testSerdeSync(parList, ParListNode.self, json)
    }
    do {
      let root = RootExpr([ParagraphExpr()])
      let json =
        """
        {"children":[{"children":[],"type":"paragraph"}],"type":"root"}
        """
      try testSerdeSync(root, RootNode.self, json)
    }
    // text styles (emph)
    do {
      let emphasis = TextStylesExpr(.emph, [TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"command":"emph","type":"textStyles"}
        """
      try testSerdeSync(emphasis, TextStylesNode.self, json)
    }
    // text styles (textbf)
    do {
      let strong = TextStylesExpr(.textbf, [TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"command":"textbf","type":"textStyles"}
        """
      try testSerdeSync(strong, TextStylesNode.self, json)
    }
    // Matrix
    do {
      let matrix = MatrixExpr(
        .Bmatrix,
        [
          MatrixExpr.Row([
            MatrixExpr.Cell([TextExpr("abc")]),
            MatrixExpr.Cell([TextExpr("def")]),
          ]),
          MatrixExpr.Row([
            MatrixExpr.Cell([TextExpr("ghi")]),
            MatrixExpr.Cell([TextExpr("jkl")]),
          ]),
        ])
      let json =
        """
        {"command":"Bmatrix","rows":[[[{"children":[{"string":"abc","type":"text"}],"type":"content"},{"children":[{"string":"def","type":"text"}],"type":"content"}]],[[{"children":[{"string":"ghi","type":"text"}],"type":"content"},{"children":[{"string":"jkl","type":"text"}],"type":"content"}]]],"type":"matrix"}
        """
      try testSerdeSync(matrix, MatrixNode.self, json)
    }
    // Multiline
    do {
      let multiline = MultilineExpr(
        .multlineAst,
        [
          MultilineExpr.Row([
            MultilineExpr.Cell([TextExpr("abc")])
          ]),
          MultilineExpr.Row([
            MultilineExpr.Cell([TextExpr("def")])
          ]),
        ])
      let json =
        """
        {"command":"multline*","rows":[[[{"children":[{"string":"abc","type":"text"}],"type":"content"}]],[[{"children":[{"string":"def","type":"text"}],"type":"content"}]]],"type":"multiline"}
        """
      try testSerdeSync(multiline, MultilineNode.self, json)
    }

    // Math
    do {
      let accent = AccentExpr(MathAccent.dot, [TextExpr("x")])
      let json =
        """
        {"command":"dot","nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},"type":"accent"}
        """
      try testSerdeSync(accent, AccentNode.self, json)
    }
    do {
      let attach = AttachExpr(
        nuc: [TextExpr("a")], lsub: [TextExpr("1")], lsup: [TextExpr("2")],
        sub: [TextExpr("3")], sup: [TextExpr("4")])
      let json =
        """
        {"lsub":{"children":[{"string":"1","type":"text"}],"type":"content"},"lsup":{"children":[{"string":"2","type":"text"}],"type":"content"},"nuc":{"children":[{"string":"a","type":"text"}],"type":"content"},"sub":{"children":[{"string":"3","type":"text"}],"type":"content"},"sup":{"children":[{"string":"4","type":"text"}],"type":"content"},"type":"attach"}
        """
      try testSerdeSync(attach, AttachNode.self, json)
    }
    do {
      let equation = EquationExpr(.inline, [TextExpr("x")])
      let json =
        """
        {"nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},"subtype":"inline","type":"equation"}
        """
      try testSerdeSync(equation, EquationNode.self, json)
    }
    do {
      let fraction = FractionExpr(
        num: [TextExpr("x")], denom: [TextExpr("y")], genfrac: .binom)
      let json =
        """
        {"command":"binom","denom":{"children":[{"string":"y","type":"text"}],"type":"content"},"num":{"children":[{"string":"x","type":"text"}],"type":"content"},"type":"fraction"}
        """
      try testSerdeSync(fraction, FractionNode.self, json)
    }
    do {
      let leftRight = LeftRightExpr(DelimiterPair.BRACE, [TextExpr("x")])
      let json =
        """
        {"delim":{"close":{"char":{"_0":"}"}},"open":{"char":{"_0":"{"}}},"nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},"type":"leftRight"}
        """
      try testSerdeSync(leftRight, LeftRightNode.self, json)
    }
    do {
      let mathAttributes = MathAttributesExpr(.mathLimits(.limits), [TextExpr("world")])
      let json =
        """
        {"command":"limits","nuc":{"children":[{"string":"world","type":"text"}],"type":"content"},"type":"mathAttributes"}
        """
      try testSerdeSync(mathAttributes, MathAttributesNode.self, json)
    }
    do {
      let mathExpression = MathExpressionExpr(MathExpression.colon)
      let json =
        """
        {"command":"colon","type":"mathExpression"}
        """
      try testSerdeSync(mathExpression, MathExpressionNode.self, json)
    }
    do {
      let mathOp = MathOperatorExpr(MathOperator.max)
      let json =
        """
        {"command":"max","type":"mathOperator"}
        """
      try testSerdeSync(mathOp, MathOperatorNode.self, json)
    }
    do {
      let mathSymbol = NamedSymbolExpr(NamedSymbol("rightarrow", "→"))
      let json =
        """
        {"command":"rightarrow","type":"namedSymbol"}
        """
      try testSerdeSync(mathSymbol, NamedSymbolNode.self, json)
    }
    do {
      let overbrace = UnderOverExpr(MathSpreader.overbrace, [TextExpr("abc")])
      let json =
        """
        {"command":"overbrace","nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"type":"underOver"}
        """
      try testSerdeSync(overbrace, UnderOverNode.self, json)
    }
    do {
      let variant = MathStylesExpr(.mathfrak, [TextExpr("F")])
      let json =
        """
        {"command":"mathfrak","nuc":{"children":[{"string":"F","type":"text"}],"type":"content"},"type":"mathStyles"}
        """
      try testSerdeSync(variant, MathStylesNode.self, json)
    }
    do {
      let radical = RadicalExpr([TextExpr("x")], index: [TextExpr("y")])
      let json =
        """
        {"index":{"children":[{"string":"y","type":"text"}],"type":"content"},\
        "radicand":{"children":[{"string":"x","type":"text"}],"type":"content"},\
        "type":"radical"}
        """
      try testSerdeSync(radical, RadicalNode.self, json)
    }
    do {
      let textMode = TextModeExpr([TextExpr("abc")])
      let json =
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"type":"textMode"}
        """
      try testSerdeSync(textMode, TextModeNode.self, json)
    }
    do {
      _ = ApplyExpr("test", arguments: [])
      // skip
    }
    do {
      _ = CompiledVariableExpr(2, .inline, false)
      // skip
    }
    do {
      _ = VariableExpr("test", .inline, false)
      // skip
    }
    // misc
    do {
      let counter = CounterExpr(.equation)
      let json =
        """
        {"counterName":"equation","type":"counter"}
        """
      try testSerdeSync(counter, CounterNode.self, json)
    }
    do {
      let linebreak = LinebreakExpr()
      let json =
        """
        {"type":"linebreak"}
        """
      try testSerdeSync(linebreak, LinebreakNode.self, json)
    }
    do {
      let text = TextExpr("abc")
      let json =
        """
        {"string":"abc","type":"text"}
        """
      try testSerdeSync(text, TextNode.self, json)
    }
    do {
      let unknown = UnknownExpr(JSONValue.number(13))
      let json =
        """
        13
        """
      try testSerdeSync(unknown, UnknownNode.self, json)
    }
  }

  func testNodeSerde() throws {
    do {
      let linebreak = LinebreakNode()
      let json =
        """
        {"type":"linebreak"}
        """
      try testRoundTrip(linebreak, json)
    }
    do {
      let root = RootNode([ParagraphNode([TextNode("abc")])])
      let json =
        """
        {"children":[{"children":[{"string":"abc","type":"text"}],"type":"paragraph"}],"type":"root"}
        """
      try testRoundTrip(root, json)
    }
    do {
      let variable = VariableNode(1, .textit, .inline, false)
      let json =
        """
        {"argIndex":1,"children":[],"isBlockContainer":false,"layoutType":0,"levelDelta":0,"textStyles":"textit","type":"variable"}
        """
      try testRoundTrip(variable, json)
    }
    do {
      let applyNode = ApplyNode(MathTemplate.pmod, [[]])!
      let json =
        """
        {"arguments":[[]],"template":{"command":"pmod"},"type":"apply"}
        """
      try testRoundTrip(applyNode, json)
    }
  }

  func testElementWithUnknown() throws {
    let paragraphExpr = ParagraphExpr([
      TextExpr("abc"),
      UnknownExpr(.string("unknown")),
      UnknownExpr(
        .object([
          "type": .string("unsupported"),
          "value": .number(1),
        ])),
    ])
    let expected: String =
      """
      {"children":[{"string":"abc","type":"text"},\
      "unknown",{"type":"unsupported","value":1}],"type":"paragraph"}
      """
    try testSerdeSync(paragraphExpr, ParagraphNode.self, expected)
  }

  private func testSerdeSync<T: Expr, U: Node>(
    _ expr: T, _ dummy: U.Type, _ json: String
  ) throws {
    self.exprTypes.insert(expr.type)
    self.nodeTypes.insert(dummy.type)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let decoder = JSONDecoder()

    // expr -> data -> node -> data2 -> expr -> data3
    let data = try encoder.encode(expr)
    #expect(String(data: data, encoding: .utf8) == json)
    do {
      let decodedNode = try decoder.decode(U.self, from: data)
      let data2 = try encoder.encode(decodedNode)
      #expect(data2 == data)
      let redecodedExpr = try decoder.decode(T.self, from: data2)
      let data3 = try encoder.encode(redecodedExpr)
      #expect(data3 == data)
    }

    // expr -> node -> data4
    do {
      guard let node = (NodeUtils.convertExprs([expr]) as Array).getOnlyElement()
      else {
        Issue.record("Cannot convert expr to node")
        return
      }
      let data4 = try encoder.encode(node)
      #expect(data4 == data)
    }
  }

  private func testRoundTrip<T: Node>(_ node: T, _ json: String) throws {
    self.nodeTypes.insert(node.type)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let decoder = JSONDecoder()

    // node -> data -> node2 -> data2
    let data = try encoder.encode(node)
    #expect(String(data: data, encoding: .utf8) == json)
    let decodedNode = try decoder.decode(T.self, from: data)
    let data2 = try encoder.encode(decodedNode)
    #expect(data2 == data)
  }
}
