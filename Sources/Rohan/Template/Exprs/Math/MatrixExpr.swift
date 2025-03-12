// Copyright 2024-2025 Lie Yan

final class MatrixExpr: RhExpr {
  override class var type: ExprType { .matrix }

  let rows: [MatrixRow]

  init(_ rows: [MatrixRow]) {
    precondition(Self.validate(rows: rows))
    self.rows = rows
    super.init()
  }

  func with(rows: [MatrixRow]) -> MatrixExpr {
    MatrixExpr(rows)
  }

  static func validate(rows: [MatrixRow]) -> Bool {
    // non empty and has the size of the first row
    !rows.isEmpty && !rows[0].isEmpty
      && rows.dropFirst().allSatisfy { row in
        row.count == rows[0].count
      }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case rows
  }

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

struct MatrixRow: Codable, Sequence {
  let elements: [ContentExpr]

  var isEmpty: Bool { elements.isEmpty }
  var count: Int { elements.count }

  init(_ elements: [[RhExpr]]) {
    self.init(elements.map(ContentExpr.init))
  }

  init(_ elements: [ContentExpr]) {
    self.elements = elements
  }

  func with(elements: [ContentExpr]) -> MatrixRow {
    MatrixRow(elements)
  }

  func makeIterator() -> IndexingIterator<[ContentExpr]> {
    elements.makeIterator()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case elements
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    elements = try container.decode([ContentExpr].self, forKey: .elements)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(elements, forKey: .elements)
  }
}
