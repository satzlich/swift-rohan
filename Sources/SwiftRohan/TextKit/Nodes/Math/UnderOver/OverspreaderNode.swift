// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

final class OverspreaderNode: _UnderOverspreaderNode {
  override class var type: NodeType { .overspreader }

  init(_ spreader: Character, _ nucleus: [Node]) {
    super.init(.over, spreader, nucleus)
  }

  init(deepCopyOf node: OverspreaderNode) {
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case spreader, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let spreader = try container.decode(String.self, forKey: .spreader)

    guard spreader.count == 1
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .spreader, in: container,
        debugDescription: "spreader must be a single character")
    }

    let nucleus = try container.decode(CrampedNode.self, forKey: .nuc)
    super.init(.over, spreader.first!, nucleus)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(String(spreader), forKey: .spreader)
    try container.encode(_nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Content

  override func stringify() -> BigString {
    "overspreader"
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> Node { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(overspreader: self, context)
  }

}
