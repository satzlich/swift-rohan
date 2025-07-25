final class ExpansionNode: ElementNodeImpl {
  // MARK: - Node

  final override class var type: NodeType { .expansion }

  final override func contentProperty() -> Array<ContentProperty> {
    _children.flatMap { $0.contentProperty() }
  }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(expansion: self, context)
  }

  // MARK: - Node(Layout)

  final override var layoutType: LayoutType { _layoutType }

  // MARK: - Node(Codable)

  private enum CodingKeys: String, CodingKey {
    case layoutType
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    _layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_layoutType, forKey: .layoutType)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { [] }

  final override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    preconditionFailure("should not be called")
  }

  final override func store() -> JSONValue {
    preconditionFailure("should not be called")
  }

  // MARK: - ElementNode

  final override func encode<S: Collection<PartialNode> & Encodable>(
    to encoder: any Encoder, withChildren children: S
  ) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_layoutType, forKey: .layoutType)
    try super.encode(to: encoder, withChildren: children)
  }

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R {
    visitor.visit(expansion: self, context, withChildren: children)
  }

  final override func cloneEmpty() -> Self { Self([], _layoutType) }

  // MARK: - ExpansionNode

  private let _layoutType: LayoutType

  init(_ children: ElementStore, _ layoutType: LayoutType) {
    self._layoutType = layoutType
    super.init(children)
  }

  required init(deepCopyOf node: ExpansionNode) {
    self._layoutType = node._layoutType
    super.init(deepCopyOf: node)
  }
}
