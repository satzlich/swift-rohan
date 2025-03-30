// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct ExprSerdeTests {
  typealias LocalUtils = SerdeTestsUtils<Expr>

  // This test ensures that all exprs are registered in the
  // ExprSerdeUtils.registeredExprs dictionary.
  @Test
  static func test_registeredExprs() {
    let unregistered = complementSet(for: ExprSerdeUtils.registeredExprs.keys)
    #expect(
      unregistered == [
        .argument,
        .linebreak,
        .textMode,
        .root,
      ])
  }

  @Test
  static func test_RoundTrip() throws {
    var testCases: [(Expr, Expr.Type, String)] = []

    testCases += [
      (
        TextExpr("Hi 😄 there"), TextExpr.self,
        """
        {"string":"Hi 😄 there","type":"text"}
        """
      ),
      (
        EquationExpr(isBlock: true, nucleus: [TextExpr("a+b")]), EquationExpr.self,
        """
        {"isBlock":true,\
        "nucleus":{"children":[{"string":"a+b","type":"text"}],"type":"content"},\
        "type":"equation"}
        """
      ),
      (
        FractionExpr(
          numerator: [TextExpr("m-n")], denominator: [TextExpr("3")], isBinomial: true),
        FractionExpr.self,
        """
        {"denominator":{"children":[{"string":"3","type":"text"}],"type":"content"},\
        "isBinomial":true,\
        "numerator":{"children":[{"string":"m-n","type":"text"}],"type":"content"},\
        "type":"fraction"}
        """
      ),
      (
        MatrixExpr([
          MatrixRow([[TextExpr("a")], [TextExpr("b")]]),
          MatrixRow([[TextExpr("c")], [TextExpr("d")]]),
        ]),
        MatrixExpr.self,
        """
        {"rows":[{"elements":[{"children":[{"string":"a","type":"text"}],"type":"content"},{"children":[{"string":"b","type":"text"}],"type":"content"}]},{"elements":[{"children":[{"string":"c","type":"text"}],"type":"content"},{"children":[{"string":"d","type":"text"}],"type":"content"}]}],"type":"matrix"}
        """
      ),
      (
        ScriptsExpr(subScript: [TextExpr("3")], superScript: [TextExpr("2")]),
        ScriptsExpr.self,
        """
        {"subScript":{"children":[{"string":"3","type":"text"}],"type":"content"},"superScript":{"children":[{"string":"2","type":"text"}],"type":"content"},"type":"scripts"}
        """
      ),
    ]

    let elements = [NodeType.content, .emphasis, .heading, .paragraph]

    for klass in elements {
      testCases.append(testCase(forElement: klass))
    }

    for (i, (node, klass, expected)) in testCases.enumerated() {
      let message = "\(#function) Test case \(i)"
      try LocalUtils.testRoundTrip(
        node, LocalUtils.decodeFunc(for: klass), expected, message)
      try LocalUtils.testRoundTrip(
        node, ExprSerdeUtils.decodeExpr(from:), expected, message)
    }

    let uncoveredTypes = complementSet(for: testCases.map(\.0.type))
    #expect(
      uncoveredTypes == [
        //
        .linebreak,
        .unknown,
        // Template
        .apply,
        .argument,
        .cVariable,
        .variable,
        // Element
        .root,
        .textMode,
      ])

    // Helper functions

    func testCase(forElement klass: ExprType) -> (ElementExpr, ElementExpr.Type, String) {
      if klass == .heading {
        let children: [Expr] = []
        let json = """
          {"children":[],"level":1,"type":"heading"}
          """
        return (HeadingExpr(level: 1, children), HeadingExpr.self, json)
      }
      else {
        let children: [Expr] = [TextExpr("abc")]
        let json = """
          {"children":[{"string":"abc","type":"text"}],"type":"\(klass.rawValue)"}
          """
        switch klass {
        case .content:
          return (ContentExpr(children), ContentExpr.self, json)
        case .emphasis:
          return (EmphasisExpr(children), EmphasisExpr.self, json)
        case .paragraph:
          return (ParagraphExpr(children), ParagraphExpr.self, json)
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
      """
      {"type":"root","value":1}
      """,
      """
      {"type":"unsupported","value":1}
      """,
    ]

    for (i, json) in testCases.enumerated() {
      try testRoundTrip(json, i)
    }

    func testRoundTrip(_ json: String, _ i: Int) throws {
      // decode
      let decoded = try ExprSerdeUtils.decodeExpr(from: Data(json.utf8))
      #expect(decoded is UnknownExpr, "Test case \(i)")
      // encode
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      let encoded = try encoder.encode(decoded)
      #expect(String(data: encoded, encoding: .utf8) == json, "Test case \(i)")
    }
  }

  @Test
  static func test_ElementWithUnknown() throws {
    let paragraphExpr = ParagraphExpr([
      TextExpr("abc"),
      UnknownExpr(.string("unknown")),
      UnknownExpr(
        .object([
          "type": .string("root"),
          "value": .number(1),
        ])),
      UnknownExpr(
        .object([
          "type": .string("unsupported"),
          "value": .number(1),
        ])),
    ])
    let expected: String =
      """
      {"children":\
      [{"string":"abc","type":"text"},\
      "unknown",\
      {"type":"root","value":1},\
      {"type":"unsupported","value":1}],\
      "type":"paragraph"}
      """
    try SerdeTestsUtils.testRoundTrip(paragraphExpr, expected)
  }
}
