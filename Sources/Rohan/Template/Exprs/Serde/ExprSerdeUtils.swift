// Copyright 2024-2025 Lie Yan

import Foundation

enum ExprSerdeUtils {
  static let registeredExprs: [ExprType: Expr.Type] = [
    .text: TextExpr.self,
    .unknown: UnknownExpr.self,
    // Template
    .apply: ApplyExpr.self,
    .cVariable: CompiledVariableExpr.self,
    .variable: VariableExpr.self,
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

  static func decodeListOfExprs<Store>(
    from container: inout UnkeyedDecodingContainer
  ) throws -> Store
  where Store: RangeReplaceableCollection, Store.Element == Expr {

    var store: Store = .init()
    if let count = container.count {
      store.reserveCapacity(count)
    }
    while !container.isAtEnd {
      store.append(try decodeExpr(from: &container))
    }
    return store
  }

  /** Decode a node from an _unkeyed decoding container_. */
  private static func decodeExpr(from container: inout UnkeyedDecodingContainer) throws -> Expr {
    let currentIndex = container.currentIndex
    // peek node type
    var containerCopy = container  // use copy to peek
    guard let nodeContainer = try? containerCopy.nestedContainer(keyedBy: Expr.CodingKeys.self),
      let rawValue = try? nodeContainer.decode(ExprType.RawValue.self, forKey: .type)
    else {
      assert(currentIndex == container.currentIndex)
      let expr = try UnknownExpr(from: try container.superDecoder())
      assert(currentIndex + 1 == container.currentIndex)
      return expr
    }
    let exprType = ExprType(rawValue: rawValue) ?? .unknown
    // get node class
    let klass = registeredExprs[exprType] ?? UnknownExpr.self
    // decode expr
    assert(currentIndex == container.currentIndex)
    let expr = try klass.init(from: try container.superDecoder())
    assert(currentIndex + 1 == container.currentIndex)
    return expr
  }

  /** Decode a node from json */
  static func decodeExpr(from json: Data) throws -> Expr {
    try JSONDecoder().decode(WildcardExpr.self, from: json).expr
  }
}

private struct WildcardExpr: Decodable {
  let expr: Expr

  init(from decoder: any Decoder) throws {
    guard let container = try? decoder.container(keyedBy: Expr.CodingKeys.self),
      let rawValue = try? container.decode(ExprType.RawValue.self, forKey: .type)
    else {
      expr = try UnknownExpr(from: decoder)
      return
    }
    let exprType = ExprType(rawValue: rawValue) ?? .unknown
    // get expr class
    let klass = ExprSerdeUtils.registeredExprs[exprType] ?? UnknownExpr.self
    // decode expr
    expr = try klass.init(from: decoder)
  }
}
