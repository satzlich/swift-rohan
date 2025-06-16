// Copyright 2024-2025 Lie Yan

/// Superclass for {align, aligned, cases, gather, gathered, multline} environments,
///  and various kinds of matrices.
/// - Invariant: Rows and columns are non-empty.
internal class ArrayExpr: Expr {
  typealias Cell = ContentExpr
  typealias Row = GridRow<ContentExpr>

  let subtype: MathArray
  let rows: Array<Row>

  final var rowCount: Int { rows.count }
  final var columnCount: Int { rows.first?.count ?? 0 }

  final func get(_ row: Int, _ column: Int) -> Cell {
    precondition(row < rowCount && column < columnCount)
    return rows[row][column]
  }

  required init(_ subtype: MathArray, _ rows: Array<Row>) {
    precondition(ArrayExpr.validate(rows: rows))
    self.subtype = subtype
    self.rows = rows
    super.init()
  }

  final func with(rows: Array<Row>) -> Self {
    Self.init(subtype, rows)
  }

  static func validate(rows: Array<Row>) -> Bool {
    if rows.isEmpty || rows[0].isEmpty { return false }
    let columnCount = rows[0].count
    return rows.dropFirst().allSatisfy { row in row.count == columnCount }
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, command }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = MathArray.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid matrix subtype: \(command)")
    }
    let rows = try container.decode(Array<Row>.self, forKey: .rows)

    guard Self.validate(rows: rows) else {
      throw DecodingError.dataCorruptedError(
        forKey: .rows, in: container,
        debugDescription: "Invalid matrix rows")
    }

    self.subtype = subtype
    self.rows = rows
    super.init()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
