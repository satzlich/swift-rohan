// Copyright 2024-2025 Lie Yan

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
}
