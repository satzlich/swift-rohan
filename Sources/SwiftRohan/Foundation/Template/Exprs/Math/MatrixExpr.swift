// Copyright 2024-2025 Lie Yan

final class MatrixExpr: Expr {
  override class var type: ExprType { .matrix }

  typealias Row = MatrixRow<ContentExpr>

  let rows: [Row]

  var rowCount: Int { rows.count }
  var columnCount: Int { rows.first?.count ?? 0 }

  func get(_ row: Int, _ column: Int) -> ContentExpr {
    precondition(row < rowCount && column < columnCount)
    return rows[row][column]
  }

  init(_ rows: [Row]) {
    precondition(Self.validate(rows: rows))
    self.rows = rows
    super.init()
  }

  func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(rows)
  }

  static func validate(rows: [Row]) -> Bool {
    // non empty and has the size of the first row
    !rows.isEmpty && !rows.first!.isEmpty
      && rows.dropFirst().allSatisfy { row in
        row.count == rows.first!.count
      }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rows = try container.decode([MatrixRow].self, forKey: .rows)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}

struct MatrixRow<Element: Codable>: Codable, Sequence {
  private var elements: [Element]

  var isEmpty: Bool { elements.isEmpty }

  var count: Int { elements.count }

  subscript(_ index: Int) -> Element {
    get { elements[index] }
    set { elements[index] = newValue }
  }

  init(_ elements: [Element]) {
    self.elements = elements
  }

  func with(elements: [Element]) -> MatrixRow {
    MatrixRow(elements)
  }

  func makeIterator() -> IndexingIterator<[Element]> {
    elements.makeIterator()
  }

  // MARK: - Codable

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    elements = try container.decode([Element].self)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(elements)
  }
}

extension MatrixRow<ContentExpr> {
  init(_ elements: [[Expr]]) {
    self.init(elements.map(ContentExpr.init))
  }
}
