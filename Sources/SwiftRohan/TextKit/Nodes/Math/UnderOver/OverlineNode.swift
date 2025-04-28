// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class OverlineNode: _UnderOverlineNode {
  override class var type: NodeType { .overline }

  init(_ nucleus: [Node]) {
    super.init(.overline, nucleus)
  }

  init(deepCopyOf node: OverlineNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
    super.init(.overline, nucleus)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    "overline"
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(overline: self, context)
  }
}
