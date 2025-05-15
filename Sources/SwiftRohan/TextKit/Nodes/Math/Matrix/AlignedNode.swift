// Copyright 2024-2025 Lie Yan

import Foundation

final class AlignedNode: ArrayNode {
  override class var type: NodeType { .aligned }

  init(_ rows: Array<ArrayNode.Row>) {
    super.init(.aligned, rows)
  }

  init(deepCopyOf node: AlignedNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(.aligned, rows)
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

  override class var storageTags: [String] {
    [MathArray.aligned.command]
  }
}
