// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesExpr: Expr {
  override class var type: ExprType { .cases }

  typealias Element = ContentExpr

  let rows: [Element]

  var rowCount: Int { rows.count }

  func get(_ index: Int) -> ContentExpr {
    precondition(index < rowCount)
    return rows[index]
  }

  static let defaultDelimiters = DelimiterPair(Delimiter("{")!, Delimiter())

  init(_ rows: [Element]) {
    self.rows = rows
    super.init()
  }

  func with(rows: [Element]) -> CasesExpr {
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
    self.rows = try container.decode([CasesExpr.Element].self, forKey: .rows)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
