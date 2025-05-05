// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesExpr: Expr {
  override class var type: ExprType { .cases }

  typealias Element = ContentExpr
  typealias Row = _MatrixRow<ContentExpr>

  static let defaultDelimiters = DelimiterPair(Delimiter("{")!, Delimiter())
  let rows: [Row]

  var rowCount: Int { rows.count }
  var columnCount: Int { rows.first?.count ?? 0 }

  func get(_ row: Int, _ column: Int) -> ContentExpr {
    precondition(row < rowCount && column < columnCount)
    return rows[row][column]
  }

  init(_ rows: [Row]) {
    precondition(MatrixExpr.validate(rows: rows))
    self.rows = rows
    super.init()
  }

  func with(rows: [Row]) -> CasesExpr {
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
    rows = try container.decode([Row].self, forKey: .rows)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
