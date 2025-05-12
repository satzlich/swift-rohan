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
          .root,
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
      let emphasis = EmphasisExpr([TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"type":"emphasis"}
        """
      try testSerdeSync(emphasis, EmphasisNode.self, json)
    }
    do {
      let heading = HeadingExpr(level: 1, [TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"level":1,"type":"heading"}
        """
      try testSerdeSync(heading, HeadingNode.self, json)
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
      let strong = StrongExpr([TextExpr("abc")])
      let json =
        """
        {"children":[{"string":"abc","type":"text"}],"type":"strong"}
        """
      try testSerdeSync(strong, StrongNode.self, json)
    }
    // Matrix
    do {
      let aligned = AlignedExpr([
        AlignedExpr.Row([
          AlignedExpr.Element([TextExpr("abc")]),
          AlignedExpr.Element([TextExpr("def")]),
        ]),
        AlignedExpr.Row([
          AlignedExpr.Element([TextExpr("ghi")]),
          AlignedExpr.Element([TextExpr("jkl")]),
        ]),
      ])
      let json =
        """
        {"rows":[[[{"children":[{"string":"abc","type":"text"}],"type":"content"},{"children":[{"string":"def","type":"text"}],"type":"content"}]],[[{"children":[{"string":"ghi","type":"text"}],"type":"content"},{"children":[{"string":"jkl","type":"text"}],"type":"content"}]]],"type":"aligned"}
        """
      try testSerdeSync(aligned, AlignedNode.self, json)
    }
    do {
      let cases = CasesExpr([
        CasesExpr.Row([
          CasesExpr.Element([TextExpr("abc")]),
          CasesExpr.Element([TextExpr("def")]),
        ]),
        CasesExpr.Row([
          CasesExpr.Element([TextExpr("ghi")]),
          CasesExpr.Element([TextExpr("jkl")]),
        ]),
      ])
      let json =
        """
        {"rows":[[[{"children":[{"string":"abc","type":"text"}],"type":"content"},{"children":[{"string":"def","type":"text"}],"type":"content"}]],[[{"children":[{"string":"ghi","type":"text"}],"type":"content"},{"children":[{"string":"jkl","type":"text"}],"type":"content"}]]],"type":"cases"}
        """
      try testSerdeSync(cases, CasesNode.self, json)
    }
    do {
      let matrix = MatrixExpr(
        DelimiterPair.BRACE,
        [
          MatrixExpr.Row([
            MatrixExpr.Element([TextExpr("abc")]),
            MatrixExpr.Element([TextExpr("def")]),
          ]),
          MatrixExpr.Row([
            MatrixExpr.Element([TextExpr("ghi")]),
            MatrixExpr.Element([TextExpr("jkl")]),
          ]),
        ])
      let json =
        """
        {"delimiters":{"close":"}","open":"{"},"rows":[[[{"children":[{"string":"abc","type":"text"}],"type":"content"},{"children":[{"string":"def","type":"text"}],"type":"content"}]],[[{"children":[{"string":"ghi","type":"text"}],"type":"content"},{"children":[{"string":"jkl","type":"text"}],"type":"content"}]]],"type":"matrix"}
        """
      try testSerdeSync(matrix, MatrixNode.self, json)
    }
    // UnderOver
    do {
      let overline = OverlineExpr([TextExpr("abc")])
      let json =
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"type":"overline"}
        """
      try testSerdeSync(overline, OverlineNode.self, json)
    }
    do {
      let underline = UnderlineExpr([TextExpr("abc")])
      let json =
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"type":"underline"}
        """
      try testSerdeSync(underline, UnderlineNode.self, json)
    }
    do {
      let overbrace = OverspreaderExpr(Chars.overBrace, [TextExpr("abc")])
      let json =
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"spreader":"⏞","type":"overspreader"}
        """
      try testSerdeSync(overbrace, OverspreaderNode.self, json)
    }
    do {
      let underbrace = UnderspreaderExpr(Chars.underBrace, [TextExpr("abc")])
      let json =
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"spreader":"⏟","type":"underspreader"}
        """
      try testSerdeSync(underbrace, UnderspreaderNode.self, json)
    }
    // Math
    do {
      let accent = AccentExpr(Chars.dotAbove, [TextExpr("x")])
      let json =
        """
        {"accent":"̇","nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},"type":"accent"}
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
      let equation = EquationExpr(isBlock: false, [TextExpr("x")])
      let json =
        """
        {"isBlock":false,"nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},"type":"equation"}
        """
      try testSerdeSync(equation, EquationNode.self, json)
    }
    do {
      let fraction = FractionExpr(
        num: [TextExpr("x")], denom: [TextExpr("y")], subtype: .binomial)
      let json =
        """
        {"denom":{"children":[{"string":"y","type":"text"}],"type":"content"},"num":{"children":[{"string":"x","type":"text"}],"type":"content"},"subtype":{"binomial":{}},"type":"fraction"}
        """
      try testSerdeSync(fraction, FractionNode.self, json)
    }
    do {
      let leftRight = LeftRightExpr(DelimiterPair.BRACE, [TextExpr("x")])
      let json =
        """
        {"delim":{"close":"}","open":"{"},\
        "nuc":{"children":[{"string":"x","type":"text"}],"type":"content"},\
        "type":"leftRight"}
        """
      try testSerdeSync(leftRight, LeftRightNode.self, json)
    }
    do {
      let mathOp = MathOperatorExpr([TextExpr("max")], true)
      let json =
        """
        {"content":{"children":[{"string":"max","type":"text"}],"type":"content"},"limits":true,"type":"mathOperator"}
        """
      try testSerdeSync(mathOp, MathOperatorNode.self, json)
    }
    do {
      let variant = MathVariantExpr(.frak, [TextExpr("F")])
      let json =
        """
        {"children":[{"string":"F","type":"text"}],"type":"mathVariant","variant":{"frak":{}}}
        """
      try testSerdeSync(variant, MathVariantNode.self, json)
    }
    do {
      let radical = RadicalExpr([TextExpr("x")], [TextExpr("y")])
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
      _ = CompiledVariableExpr(2)
      // skip
    }
    do {
      _ = VariableExpr("test")
      // skip
    }
    // misc
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
      let variable = VariableNode(1)
      let json =
        """
        {"argumentIndex":1,"children":[],"type":"variable"}
        """
      try testRoundTrip(variable, json)
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
      guard let node = NodeUtils.convertExprs([expr]).getOnlyElement()
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
