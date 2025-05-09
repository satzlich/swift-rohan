// Copyright 2024-2025 Lie Yan

import Foundation

final class AlignedNode: _GridNode {
  override class var type: NodeType { .aligned }

  init(_ rows: Array<_GridNode.Row>) {
    super.init(DelimiterPair.NONE, rows)
  }

  init(deepCopyOf node: AlignedNode) {
    super.init(deepCopyOf: node)
  }

  override func getColumnAlignments() -> any ColumnAlignmentProvider {
    AlternateColumnAlignmentProvider()
  }

  override func getColumnGapProvider() -> ColumnGapProvider.Type {
    AlignedColumnGapProvider.self
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(DelimiterPair.NONE, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> AlignedNode { AlignedNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(aligned: self, context)
  }
}
