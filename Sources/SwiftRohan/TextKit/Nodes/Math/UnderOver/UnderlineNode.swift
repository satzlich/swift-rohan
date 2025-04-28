// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class UnderlineNode: _UnderOverlineNode {
  override class var type: NodeType { .underline }

  init(_ nucleus: [Node]) {
    super.init(.underline, nucleus)
  }

  init(deepCopyOf node: UnderlineNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // nucleus is un-cramped
    let nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    super.init(.underline, nucleus)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    "underline"
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(underline: self, context)
  }
}
