// Copyright 2024-2025 Lie Yan

final class MatrixExpr: Expr {
  override class var type: ExprType { .matrix }

  typealias Element = ContentExpr
  typealias Row = _MatrixRow<ContentExpr>

  let rows: [Row]
  let delimiters: DelimiterPair

  var rowCount: Int { rows.count }
  var columnCount: Int { rows.first?.count ?? 0 }

  func get(_ row: Int, _ column: Int) -> ContentExpr {
    precondition(row < rowCount && column < columnCount)
    return rows[row][column]
  }

  init(_ rows: [Row], _ delimiters: DelimiterPair) {
    precondition(MatrixExpr.validate(rows: rows))
    self.rows = rows
    self.delimiters = delimiters
    super.init()
  }

  func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(rows, delimiters)
  }

  static func validate(rows: [Row]) -> Bool {
    if rows.isEmpty || rows[0].isEmpty { return false }
    let columnCount = rows[0].count
    return rows.dropFirst().allSatisfy { row in row.count == columnCount }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rows = try container.decode([Row].self, forKey: .rows)
    delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try container.encode(delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }
}

internal struct _MatrixRow<Element: Codable>: Codable, Sequence {
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

  func with(elements: [Element]) -> _MatrixRow {
    _MatrixRow(elements)
  }

  func makeIterator() -> IndexingIterator<[Element]> {
    elements.makeIterator()
  }

  mutating func insert(_ element: Element, at index: Int) {
    elements.insert(element, at: index)
  }

  mutating func remove(at index: Int) -> Element {
    elements.remove(at: index)
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

extension _MatrixRow<ContentExpr> {
  init(_ elements: [[Expr]]) {
    self.init(elements.map(ContentExpr.init))
  }
}
