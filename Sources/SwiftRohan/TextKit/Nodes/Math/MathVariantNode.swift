// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantNode: ElementNode {
  override class var type: NodeType { .mathVariant }

  let mathVariant: MathVariant?
  let bold: Bool?
  let italic: Bool?

  init(
    _ mathVariant: MathVariant?, bold: Bool? = nil, italic: Bool? = nil,
    _ children: [Node]
  ) {
    precondition(mathVariant != nil || bold != nil || italic != nil)
    self.mathVariant = mathVariant
    self.bold = bold
    self.italic = italic
    super.init(children)
  }

  internal init(deepCopyOf node: MathVariantNode) {
    self.mathVariant = node.mathVariant
    self.bold = node.bold
    self.italic = node.italic
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case variant, bold, italic }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathVariant = try container.decode(MathVariant.self, forKey: .variant)
    self.bold = try container.decodeIfPresent(Bool.self, forKey: .bold)
    self.italic = try container.decodeIfPresent(Bool.self, forKey: .italic)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .variant)
    try container.encodeIfPresent(bold, forKey: .bold)
    try container.encodeIfPresent(italic, forKey: .italic)
    try super.encode(to: encoder)
  }

  override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .variant)
    try container.encodeIfPresent(bold, forKey: .bold)
    try container.encodeIfPresent(italic, forKey: .italic)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      if let mathVariant = mathVariant {
        properties[MathProperty.variant] = .mathVariant(mathVariant)
      }
      if let bold = bold {
        properties[MathProperty.bold] = .bool(bold)
      }
      if let italic = italic {
        properties[MathProperty.italic] = .bool(italic)
      }
      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Content

  override func deepCopy() -> Self { Self(deepCopyOf: self) }

  override func cloneEmpty() -> Self { Self(mathVariant, bold: bold, italic: italic, []) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathVariant: self, context)
  }
}
