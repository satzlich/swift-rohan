// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TemplateExprTests {
  @Test
  func coverage() throws {
    let exprs: [Expr] = TemplateExprTests.allSamples()
    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
    }
  }

  @Test
  func serialization() throws {
    do {
      let apply = ApplyExpr("test", arguments: [[TextExpr("x")]])
      try TemplateExprTests.testCodable(apply)
    }
    do {
      let cVariable = CompiledVariableExpr(1)
      try TemplateExprTests.testCodable(cVariable)
    }
    do {
      let variable = VariableExpr("z")
      try TemplateExprTests.testCodable(variable)
    }
  }

  static func allSamples() -> Array<Expr> {
    [
      ApplyExpr("test", arguments: [[TextExpr("x")]]),
      CompiledVariableExpr(1),
      VariableExpr("z"),
    ]
  }

  static func testCodable<T: Codable>(_ codable: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let decoder = JSONDecoder()

    let data = try encoder.encode(codable)
    let decoded = try decoder.decode(T.self, from: data)
    let data2 = try encoder.encode(decoded)
    #expect(data == data2)
  }
}
