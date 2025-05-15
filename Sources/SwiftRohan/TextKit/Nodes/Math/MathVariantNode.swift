// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantNode: ElementNode {
  override class var type: NodeType { .mathVariant }

  let mathTextStyle: MathTextStyle

  init(
    _ mathTextStyle: MathTextStyle,
    _ children: [Node]
  ) {
    self.mathTextStyle = mathTextStyle
    super.init(children)
  }

  init(_ mathTextStyle: MathTextStyle, _ children: Store) {
    self.mathTextStyle = mathTextStyle
    super.init(children)
  }

  internal init(deepCopyOf node: MathVariantNode) {
    self.mathTextStyle = node.mathTextStyle
    super.init(deepCopyOf: node)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case textStyle }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathTextStyle = try container.decode(MathTextStyle.self, forKey: .textStyle)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathTextStyle, forKey: .textStyle)
    try super.encode(to: encoder)
  }

  override func encode<S: Collection<PartialNode>>(
    to encoder: any Encoder, withChildren children: S
  ) throws where S: Encodable {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathTextStyle, forKey: .textStyle)
    try super.encode(to: encoder, withChildren: children)
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let (variant, bold, italic) = mathTextStyle.tuple()

      properties[MathProperty.variant] = .mathVariant(variant)
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

  override func cloneEmpty() -> Self { Self(mathTextStyle, []) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(mathVariant: self, context)
  }

  override class var storageTags: [String] {
    MathTextStyle.predefinedCases.map { $0.command }
  }

  override func store() -> JSONValue {
    let children: [JSONValue] = getChildren_readonly().map { $0.store() }
    let json = JSONValue.array([.string(mathTextStyle.command), .array(children)])
    return json
  }

   class func loadSelf(from json: JSONValue) -> _LoadResult<MathVariantNode> {
    guard case let .array(array) = json,
      array.count == 2,
      case let .string(tag) = array[0],
      let textStyle = MathTextStyle.lookup(tag),
      case let .array(children) = array[1]
    else { return .failure(UnknownNode(json)) }
    let (nodes, corrupted) = NodeStoreUtils.loadChildren(children)
    let result = Self(textStyle, nodes)
    return corrupted ? .corrupted(result) : .success(result)
  }
  
  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    loadSelf(from: json).cast()
  }
}
