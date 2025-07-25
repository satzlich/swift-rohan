import Foundation
import Testing

@testable import SwiftRohan

struct ExprSerdeUtilsTests {
  // This test ensures that all exprs are registered in the
  // ExprSerdeUtils.registeredExprs dictionary.
  @Test
  func registeredExprs() {
    let unregistered = ExprType.complementSet(to: ExprSerdeUtils.registeredExprs.keys)
    #expect(unregistered == ExprsTests.uncoveredExprTypes)
  }

  @Test
  func unknownExprs() throws {
    let testCases: Array<String> = [
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
  func wildExpr() throws {
    let decoder = JSONDecoder()

    // test non-existent type
    do {
      let json = """
        {"type":"nonexistent","value":1}
        """
      let wildcard = try decoder.decode(WildcardExpr.self, from: Data(json.utf8))
      #expect(wildcard.expr.type == .unknown)
    }
    // test existent but unregistered type
    do {
      let json = """
        {"type":"argument","value":1}
        """
      let wildcard = try decoder.decode(WildcardExpr.self, from: Data(json.utf8))
      #expect(wildcard.expr.type == .unknown)
    }
  }

  @Test
  func decodeListOfExprs_fallbackToUnknown() throws {
    // decode ContentNode calls `decodeListOfExprs` internally,
    let decoder = JSONDecoder()
    let json = """
      {"type": "content", 
      "children": [
        {"type": "unsupported", "command": "unsupported"},
        {"type": "argument", "children": []}
      ]}
      """
    _ = try decoder.decode(WildcardExpr.self, from: Data(json.utf8))
  }

  /// Tests that decoding known expr from input throws a `DecodingError`.
  @Test
  func decodeThrows() {
    let decoder = JSONDecoder()

    let classes = [
      AccentExpr.self,
      FractionExpr.self,
      LeftRightExpr.self,
      MatrixExpr.self,
      MathAttributesExpr.self,
      MathExpressionExpr.self,
      MathOperatorExpr.self,
      MathStylesExpr.self,
      NamedSymbolExpr.self,
      UnderOverExpr.self,
    ]
    for clazz in classes {
      #expect(throws: DecodingError.self) {
        _ = try decoder.decode(clazz, from: json(for: clazz.type))
      }
    }

    func json(for type: ExprType) -> Data {
      let json = """
        { "type": "\(type)", "command": "unsupported" }
        """
      return Data(json.utf8)
    }
  }

  @Test
  func decodeThrows_typeMismatch() {
    let json = """
      {"type":"content","children":[]}
      """
    let decoder = JSONDecoder()

    #expect(throws: DecodingError.self) {
      _ = try decoder.decode(TextStylesExpr.self, from: Data(json.utf8))
    }
  }

  /// Tests that `ArrayExpr` fails `ArrayExpr.validate()` when decoding an empty array.
  @Test
  func arrayNode_decodeThrows() {
    let json =
      """
      {"command":"pmatrix","rows":[],"type":"matrix"}
      """
    let decoder = JSONDecoder()
    #expect(throws: DecodingError.self) {
      _ = try decoder.decode(MatrixExpr.self, from: Data(json.utf8))
    }
  }

  @Test
  func compiledVariableExpr_decodeThrows() {
    let json = """
      {"type":"cVariable","argIndex":-1}
      """
    let decoder = JSONDecoder()
    #expect(throws: DecodingError.self) {
      _ = try decoder.decode(CompiledVariableExpr.self, from: Data(json.utf8))
    }
  }
}
