// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesExpr: Expr {
  override class var type: ExprType { .cases }

  static let defaultDelimiters = DelimiterPair(Delimiter("{")!, Delimiter())

  typealias Element = ContentExpr

  let rows: [Element]
  let delimiters: DelimiterPair

  var rowCount: Int { rows.count }

  func get(_ index: Int) -> ContentExpr {
    precondition(index < rowCount)
    return rows[index]
  }

  init(_ rows: [Element]) {
    self.rows = rows
    self.delimiters = CasesExpr.defaultDelimiters
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

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let rows = try container.decode([MatrixExpr.Row].self, forKey: .rows)
    self.rows = rows.map { $0[0] }

    delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    let rows = self.rows.map { MatrixExpr.Row([$0]) }
    try container.encode(rows, forKey: .rows)

    try container.encode(delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }
}
