// Copyright 2024-2025 Lie Yan

import Foundation

enum ExprSerdeUtils {
  static let registeredExprs: [ExprType: RhExpr.Type] = [
    .text: TextExpr.self,
    .unknown: UnknownExpr.self,
    // Template
    .apply: ApplyExpr.self,
    .variable: VariableExpr.self,
    .cVariable: CompiledVariableExpr.self,
    // Element
    .content: ContentExpr.self,
    .emphasis: EmphasisExpr.self,
    .heading: HeadingExpr.self,
    .paragraph: ParagraphExpr.self,
    // Math
    .equation: EquationExpr.self,
    .fraction: FractionExpr.self,
    .matrix: MatrixExpr.self,
    .scripts: ScriptsExpr.self,
  ]

  static func decodeExprs(from container: inout UnkeyedDecodingContainer) throws -> [RhExpr] {
    var exprs: [RhExpr] = []
    while !container.isAtEnd {
      exprs.append(try decodeExpr(from: &container))
    }
    return exprs
  }

  /** Decode a node from an _unkeyed decoding container_. */
  private static func decodeExpr(from container: inout UnkeyedDecodingContainer) throws -> RhExpr {
    var containerCopy = container
    let currentIndex = container.currentIndex
    // peek node type
    guard let nodeContainer = try? containerCopy.nestedContainer(keyedBy: RhExpr.CodingKeys.self),
      let rawValue = try? nodeContainer.decode(ExprType.RawValue.self, forKey: .type)
    else {
      assert(currentIndex == container.currentIndex)
      let decoder = try container.superDecoder()
      let expr = try UnknownExpr(from: decoder)
      assert(currentIndex + 1 == container.currentIndex)
      return expr
    }
    let nodeType = ExprType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = registeredExprs[nodeType] ?? UnknownExpr.self
    // decode node
    assert(currentIndex == container.currentIndex)
    let decoder = try container.superDecoder()
    let expr = try klass.init(from: decoder)
    assert(currentIndex + 1 == container.currentIndex)
    return expr
  }

  /** Decode a node from json */
  static func decodeExpr(from json: Data) throws -> RhExpr {
    let decoder = JSONDecoder()
    return try decoder.decode(WildcardExpr.self, from: json).expr
  }
}

private struct WildcardExpr: Decodable {
  let expr: RhExpr

  init(from decoder: any Decoder) throws {
    guard let container = try? decoder.container(keyedBy: RhExpr.CodingKeys.self),
      let rawValue = try? container.decode(ExprType.RawValue.self, forKey: .type)
    else {
      expr = try UnknownExpr(from: decoder)
      return
    }
    let exprType = ExprType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = ExprSerdeUtils.registeredExprs[exprType] ?? UnknownExpr.self
    // decode node
    expr = try klass.init(from: decoder)
  }
}
