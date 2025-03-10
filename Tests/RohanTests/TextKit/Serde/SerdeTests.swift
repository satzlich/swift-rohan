// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct SerdeTests {
  /** This test ensures that all nodes are registered in the
    SerdeUtils.registeredNodes dictionary. */
  @Test
  static func test_registeredNodes() {
    let allNodes: Set<NodeType> = Set(NodeType.allCases)
    let registered = SerdeUtils.registeredNodes.keys
    let unregistered = allNodes.subtracting(registered)
    let expected: Set<NodeType> = [
      .linebreak,
      .matrix,
      .scripts,
      .namelessVariable,
    ]
    #expect(unregistered == expected)
  }

  @Test
  static func test_RoundTrip() throws {
    var testCases: [(Node, Node.Type, String)] = []

    testCases += [
      (
        TextNode("Hi 😄 there"), TextNode.self,
        """
        {"string":"Hi 😄 there","type":"text"}
        """
      ),
      (
        EquationNode(isBlock: true, [TextNode("a+b")]), EquationNode.self,
        """
        {"isBlock":true,\
        "nucleus":{"children":[{"string":"a+b","type":"text"}],"type":"content"},\
        "type":"equation"}
        """
      ),
      (
        FractionNode([TextNode("m-n")], [TextNode("3")], isBinomial: true), FractionNode.self,
        """
        {"denominator":{"children":[{"string":"3","type":"text"}],"type":"content"},\
        "isBinomial":true,\
        "numerator":{"children":[{"string":"m-n","type":"text"}],"type":"content"},\
        "type":"fraction"}
        """
      ),
    ]

    let elements = [NodeType.content, .emphasis, .heading, .paragraph, .root, .textMode]

    for klass in elements {
      testCases.append(elementSubclass(klass))
    }

    for (i, (node, klass, expected)) in testCases.enumerated() {
      try testRoundTrip(node, decodeFunc(for: klass), expected, #function, i)
      try testRoundTrip(node, SerdeUtils.decodeNode(from:), expected, #function, i)
    }

    // Helper functions

    func elementSubclass(_ klass: NodeType) -> (ElementNode, ElementNode.Type, String) {
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
          ],"type":"root"}
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
        case .textMode:
          return (TextModeNode(children), TextModeNode.self, json)
        default:
          fatalError("Unknown element subclass \(klass)")
        }
      }
    }
  }

  typealias DecodeFunc<T> = (Data) throws -> T where T: Node

  static func decodeFunc<T: Node>(for klass: T.Type) -> DecodeFunc<T> {
    return { data in try JSONDecoder().decode(klass.self, from: data) }
  }

  static func testRoundTrip<T: Node>(
    _ node: Node, _ decodeFunc: DecodeFunc<T>, _ expected: String,
    _ function: String, _ i: Int
  ) throws {
    let message = "\(function) Test case \(i)"

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    // encode
    let encoded = try encoder.encode(node)
    #expect(String(data: encoded, encoding: .utf8) == expected, "\(message)")
    // decode
    let decoded = try decodeFunc(encoded)
    #expect(decoded.layoutLength == node.layoutLength, "\(message)")
    // encode again
    let encodedAgain = try encoder.encode(decoded)
    #expect(String(data: encodedAgain, encoding: .utf8) == expected, "\(message)")
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
      let decoded = try SerdeUtils.decodeNode(from: Data(json.utf8))
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
    try testRoundTrip(paragraphNode, decodeFunc(for: ParagraphNode.self), expected, #function, 0)
  }
}
