// Copyright 2024-2025 Lie Yan

internal class ArrayExpr: Expr {
  typealias Element = ContentExpr
  typealias Row = GridRow<ContentExpr>

  let subtype: MathArray
  let rows: Array<Row>

  var rowCount: Int { rows.count }
  var columnCount: Int { rows.first?.count ?? 0 }

  func get(_ row: Int, _ column: Int) -> Element {
    precondition(row < rowCount && column < columnCount)
    return rows[row][column]
  }

  required init(_ subtype: MathArray, _ rows: Array<Row>) {
    precondition(ArrayExpr.validate(rows: rows))
    self.subtype = subtype
    self.rows = rows
    super.init()
  }

  func with(rows: Array<Row>) -> Self {
    preconditionFailure("This method should be overridden")
  }

  static func validate(rows: Array<Row>) -> Bool {
    if rows.isEmpty || rows[0].isEmpty { return false }
    let columnCount = rows[0].count
    return rows.dropFirst().allSatisfy { row in row.count == columnCount }
  }

  // MARK: - Codable

  required init(from decoder: any Decoder) throws {
    preconditionFailure("should be overridden and should not be called")
  }
}
