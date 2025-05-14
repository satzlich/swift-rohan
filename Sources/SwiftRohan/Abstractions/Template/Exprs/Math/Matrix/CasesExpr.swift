// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesExpr: ArrayExpr {
  override class var type: ExprType { .cases }

  init(_ rows: [Row]) {
    super.init(MathArray.cases, rows)
  }

  override func with(rows: [Row]) -> CasesExpr {
    CasesExpr(rows)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(cases: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(MathArray.cases, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
