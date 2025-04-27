// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: _MatrixNode {
  override class var type: NodeType { .matrix }

  init(_ rows: Array<_MatrixNode.Row>, _ delimiters: DelimiterPair) {
    super.init(rows, delimiters, .center)
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    super.init(rows, delimiters, .center)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try container.encode(_delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }

  // MARK: - Edit

  func insertColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    let elements = (0..<rowCount).map { _ in Element() }

    if inStorage {
      _editLog.append(.insertColumn(at: index))
      elements.forEach { _addedNodes.insert($0.id) }
    }

    elements.forEach { $0.setParent(self) }

    for i in (0..<rowCount) {
      _rows[i].insert(elements[i], at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  func removeColumn(at index: Int, inStorage: Bool) {
    precondition(index >= 0 && index < columnCount)

    if inStorage {
      _editLog.append(.removeColumn(at: index))
    }

    for i in (0..<rowCount) {
      _ = _rows[i].remove(at: index)
    }

    self.contentDidChange(delta: .zero, inStorage: inStorage)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MatrixNode { MatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}
