// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct NodeSerdeTests {
  typealias LocalUtils = SerdeTestsUtils<Node>

  // This test ensures that all nodes are registered in the
  // NodeSerdeUtils.registeredNodes dictionary.
  @Test
  static func test_registeredNodes() {
    let unregistered = NodeType.complementSet(to: NodeSerdeUtils.registeredNodes.keys)
    #expect(
      unregistered == [
        .cVariable,
        .linebreak,
      ])
  }

  @Test
  static func test_RoundTrip() throws {
    var testCases: [(Node, Node.Type, String)] = []

    // text
    testCases += [
      (
        TextNode("Hi 😄 there"), TextNode.self,
        """
        {"string":"Hi 😄 there","type":"text"}
        """
      )
    ]

    // element nodes
    let elements = [
      NodeType.content, .emphasis, .heading, .paragraph, .root, .strong,
    ]
    for klass in elements {
      testCases.append(testCase(forElement: klass))
    }

    // math nodes
    testCases += [
      (
        AccentNode(accent: "\u{0303}", nucleus: []),
        AccentNode.self,
        """
        {"accent":"̃","nuc":{"children":[],"type":"content"},"type":"accent"}
        """
      ),
      (
        AttachNode(nuc: [TextNode("a+b")], sub: [TextNode("c")], sup: [TextNode("d")]),
        AttachNode.self,
        """
        {"nuc":{"children":[{"string":"a+b","type":"text"}],"type":"content"},"sub":{"children":[{"string":"c","type":"text"}],"type":"content"},"sup":{"children":[{"string":"d","type":"text"}],"type":"content"},"type":"attach"}
        """
      ),
      (
        CasesNode([[TextNode("a")], [TextNode("b")]]),
        CasesNode.self,
        """
        {"rows":[{"children":[{"string":"a","type":"text"}],"type":"content"},{"children":[{"string":"b","type":"text"}],"type":"content"}],\
        "type":"cases"}
        """
      ),
      (
        EquationNode(isBlock: true, nuc: [TextNode("a+b")]), EquationNode.self,
        """
        {"isBlock":true,\
        "nuc":{"children":[{"string":"a+b","type":"text"}],"type":"content"},\
        "type":"equation"}
        """
      ),
      (
        FractionNode(
          num: [TextNode("m-n")], denom: [TextNode("3")], isBinomial: true),
        FractionNode.self,
        """
        {"denom":{"children":[{"string":"3","type":"text"}],"type":"content"},\
        "isBinom":true,\
        "num":{"children":[{"string":"m-n","type":"text"}],"type":"content"},\
        "type":"fraction"}
        """
      ),
      (
        LeftRightNode(DelimiterPair.PAREN, [TextNode("a")]),
        LeftRightNode.self,
        """
        {"delim":{"close":")","open":"("},"nuc":{"children":[{"string":"a","type":"text"}],"type":"content"},"type":"leftRight"}
        """
      ),
      (
        MathOperatorNode([TextNode("min")], true),
        MathOperatorNode.self,
        """
        {"content":{"children":[{"string":"min","type":"text"}],"type":"content"},\
        "limits":true,"type":"mathOperator"}
        """
      ),
      (
        MathVariantNode(.bb, bold: false, [TextNode("F")]),
        MathVariantNode.self,
        """
        {"bold":false,"children":[{"string":"F","type":"text"}],\
        "type":"mathVariant","variant":{"bb":{}}}
        """
      ),
      (
        MatrixNode(
          [
            MatrixNode.Row([
              [TextNode("a")], [TextNode("b")],
            ]),
            MatrixNode.Row([
              [TextNode("c")], [TextNode("d")],
            ]),
          ],
          DelimiterPair.PAREN),
        MatrixNode.self,
        """
        {"delimiters":{"close":")","open":"("},\
        "rows":[[[{"children":[{"string":"a","type":"text"}],"type":"content"},{"children":[{"string":"b","type":"text"}],"type":"content"}]],[[{"children":[{"string":"c","type":"text"}],"type":"content"},{"children":[{"string":"d","type":"text"}],"type":"content"}]]],\
        "type":"matrix"}
        """
      ),
      (
        OverlineNode([TextNode("abc")]),
        OverlineNode.self,
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},"type":"overline"}
        """
      ),
      (
        OverspreaderNode(Characters.overBrace, [TextNode("abc")]),
        OverspreaderNode.self,
        """
        {"nuc":{"children":[{"string":"abc","type":"text"}],"type":"content"},\
        "spreader":"⏞","type":"overspreader"}
        """
      ),
      (
        RadicalNode([TextNode("n")], [TextNode("3")]),
        RadicalNode.self,
        """
        {"index":{"children":[{"string":"3","type":"text"}],"type":"content"},\
        "radicand":{"children":[{"string":"n","type":"text"}],"type":"content"},\
        "type":"radical"}
        """
      ),
      (
        UnderlineNode([TextNode("wxyz")]),
        UnderlineNode.self,
        """
        {"nuc":{"children":[{"string":"wxyz","type":"text"}],"type":"content"},"type":"underline"}
        """
      ),
      (
        UnderspreaderNode(Characters.underBrace, [TextNode("wxyz")]),
        UnderspreaderNode.self,
        """
        {"nuc":{"children":[{"string":"wxyz","type":"text"}],"type":"content"},\
        "spreader":"⏟","type":"underspreader"}
        """
      ),
    ]

    // apply

    testCases += [
      (
        ApplyNode(
          CompiledSamples.doubleText,
          [[ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]])!,
        ApplyNode.self,
        """
        {"arguments":[[{\
        "arguments":[[{"string":"fox","type":"text"}]],\
        "template":{\
        "body":[{"string":"{","type":"text"},{"index":0,"type":"cVariable"},{"string":" and ","type":"text"},{"children":[{"index":0,"type":"cVariable"}],"type":"emphasis"},{"string":"}","type":"text"}],\
        "lookup":[[[{"index":{"_0":1}}],[{"index":{"_0":3}},{"index":{"_0":0}}]]],\
        "name":"doubleText"},\
        "type":"apply"}]],\
        "template":{\
        "body":[{"string":"{","type":"text"},{"index":0,"type":"cVariable"},{"string":" and ","type":"text"},{"children":[{"index":0,"type":"cVariable"}],"type":"emphasis"},{"string":"}","type":"text"}],\
        "lookup":[[[{"index":{"_0":1}}],[{"index":{"_0":3}},{"index":{"_0":0}}]]],\
        "name":"doubleText"},\
        "type":"apply"}
        """
      )
    ]

    for (i, (node, klass, expected)) in testCases.enumerated() {
      let message = "\(#function) Test case \(i)"
      try LocalUtils.testRoundTrip(
        node, LocalUtils.decodeFunc(for: klass), expected, message)
      try LocalUtils.testRoundTrip(
        node, NodeSerdeUtils.decodeNode(from:), expected, message)
    }

    let uncoveredTypes = NodeType.complementSet(to: testCases.map(\.0.type))
    #expect(
      uncoveredTypes == [
        .linebreak,
        .unknown,
        // Template
        .argument,
        .cVariable,
        .variable,
      ])

    // Helper functions

    func testCase(forElement klass: NodeType) -> (ElementNode, ElementNode.Type, String) {
      if klass == .root {
        let children: [Node] = [
          ParagraphNode([TextNode("abc"), TextNode("x")]),
          HeadingNode(level: 1, [TextNode("def")]),
        ]
        let json = """
          {"children":[\
          {"children":[{"string":"abc","type":"text"},{"string":"x","type":"text"}],\
          "type":"paragraph"},\
          {"children":[{"string":"def","type":"text"}],"level":1,"type":"heading"}\
          ],"type":"root","version":"1.0.0"}
          """
        return (RootNode(children), RootNode.self, json)
      }
      else if klass == .heading {
        let children: [Node] = []
        let json = """
          {"children":[],"level":1,"type":"heading"}
          """
        return (HeadingNode(level: 1, children), HeadingNode.self, json)
      }
      else {
        let children: [Node] = [TextNode("abc")]
        let json = """
          {"children":[{"string":"abc","type":"text"}],"type":"\(klass.rawValue)"}
          """
        switch klass {
        case .content:
          return (ContentNode(children), ContentNode.self, json)
        case .emphasis:
          return (EmphasisNode(children), EmphasisNode.self, json)
        case .paragraph:
          return (ParagraphNode(children), ParagraphNode.self, json)
        case .strong:
          return (StrongNode(children), StrongNode.self, json)
        default:
          fatalError("Unknown element subclass \(klass)")
        }
      }
    }
  }

  @Test
  static func test_Unknown() throws {
    let testCases: [String] = [
      "null",
      "true",
      "false",
      "1",
      "1.1",
      """
      [1,2,3]
      """,
      """
      {"a":1,"c":1.1}
      """,
    ]

    for (i, json) in testCases.enumerated() {
      try testRoundTrip(json, i)
    }

    func testRoundTrip(_ json: String, _ i: Int) throws {
      // decode
      let decoded = try NodeSerdeUtils.decodeNode(from: Data(json.utf8))
      #expect(decoded is UnknownNode, "Test case \(i)")
      // encode
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      let encoded = try encoder.encode(decoded)
      #expect(String(data: encoded, encoding: .utf8) == json, "Test case \(i)")
    }
  }

  @Test
  static func test_ElementWithUnknown() throws {
    let paragraphNode = ParagraphNode([
      TextNode("abc"),
      UnknownNode(.string("unknown")),
      UnknownNode(
        .object([
          "type": .string("random-unknown"),
          "value": .number(1),
        ])),
    ])
    let expected: String =
      """
      {"children":\
      [{"string":"abc","type":"text"},\
      "unknown",\
      {"type":"random-unknown","value":1}],\
      "type":"paragraph"}
      """
    try SerdeTestsUtils.testRoundTrip(paragraphNode, expected)
  }

  @Test
  static func test_ListOfListsOfNodes() throws {
    let json = """
      [[{"string":"a","type":"text"}],[{"string":"b","type":"text"}]]
      """
    let decoded: [[Node]] =
      try NodeSerdeUtils.decodeListOfListsOfNodes(from: Data(json.utf8))

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let encoded = try encoder.encode(decoded)
    #expect(String(data: encoded, encoding: .utf8) == json)
  }
}
