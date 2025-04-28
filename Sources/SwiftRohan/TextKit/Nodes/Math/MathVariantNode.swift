// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantNode: ElementNode {
  override class var type: NodeType { .mathVariant }

  let mathVariant: MathVariant

  init(_ mathVariant: MathVariant, _ children: [Node]) {
    self.mathVariant = mathVariant
    super.init(children)
  }

  internal init(deepCopyOf node: MathVariantNode) {
    self.mathVariant = node.mathVariant
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathVariant }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathVariant = try container.decode(MathVariant.self, forKey: .mathVariant)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .mathVariant)
    try super.encode(to: encoder)
  }

  override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .mathVariant)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      properties[MathProperty.variant] = .mathVariant(mathVariant)
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Content

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self(mathVariant, []) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathVariant: self, context)
  }
}
