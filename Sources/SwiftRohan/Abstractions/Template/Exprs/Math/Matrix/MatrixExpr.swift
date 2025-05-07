// Copyright 2024-2025 Lie Yan

final class MatrixExpr: _MatrixExpr {
  override class var type: ExprType { .matrix }

  override init(_ rows: [_MatrixExpr.Row], _ delimiters: DelimiterPair) {
    super.init(rows, delimiters)
  }

  override func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(rows, delimiters)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    super.init(rows, delimiters)
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
