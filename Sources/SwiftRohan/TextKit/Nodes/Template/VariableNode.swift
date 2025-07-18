// Copyright 2024-2025 Lie Yan

/// A variable node represents a variable in the expansion of a template call.
/// - Invariant: A variable node must be a descendant of an apply node.
final class VariableNode: ElementNodeImpl {
  // MARK: - Node

  final override class var type: NodeType { .variable }

  final override func contentProperty() -> Array<ContentProperty> {
    _children.flatMap { $0.contentProperty() }
  }

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(variable: self, context)
  }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      do {
        let key = InternalProperty.nestedLevel
        let value = key.resolveValue(current, styleSheet).integer()!
        let parity = nestedLevelDelta % 2
        let level = value + (containerType == .block ? parity : (1 - parity))
        current[key] = .integer(level)
      }

      if let textStyle = _textStyles {
        TextStylesNode.setProperties(&current, styleSheet, textStyle)
      }

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey {
    case argIndex, levelDelta, textStyles, layoutType
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .argIndex)
    _textStyles = try container.decodeIfPresent(TextStyles.self, forKey: .textStyles)
    _layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    nestedLevelDelta = try container.decode(Int.self, forKey: .levelDelta)
    super.init()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argIndex)
    try container.encodeIfPresent(_textStyles, forKey: .textStyles)
    try container.encode(_layoutType, forKey: .layoutType)
    try container.encode(nestedLevelDelta, forKey: .levelDelta)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Layout)

  final override var layoutType: LayoutType { _layoutType }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { /* emits no storage tags */ [] }

  final override func store() -> JSONValue {
    preconditionFailure("Work with apply nodes instead.")
  }

  override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    preconditionFailure("Work with apply nodes instead.")
  }

  // MARK: - ElementNode

  final override var containerType: ContainerType? { _layoutType.defaultContainerType }

  final override func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R where V: NodeVisitor<R, C>, T: GenNode, T == S.Element, S: Collection {
    visitor.visit(variable: self, context, withChildren: children)
  }

  // MARK: - VariableNode

  /// associated argument node
  private(set) weak var argumentNode: ArgumentNode?

  let argumentIndex: Int
  /// The delta of the nested level from the apply node.
  let nestedLevelDelta: Int

  private let _textStyles: TextStyles?
  private let _layoutType: LayoutType

  internal func setArgumentNode(_ argument: ArgumentNode) {
    precondition(self.argumentNode == nil)
    assert(argument.argumentIndex == argumentIndex)
    self.argumentNode = argument
  }

  internal func isAssociated(with applyNode: ApplyNode) -> Bool {
    argumentNode?.isAssociated(with: applyNode) == true
  }

  init(
    _ argumentIndex: Int,
    _ textStyles: TextStyles?,
    _ layoutType: LayoutType,
    nestedLevelDelta: Int = 0
  ) {
    self.argumentIndex = argumentIndex
    self._textStyles = textStyles
    self._layoutType = layoutType
    self.nestedLevelDelta = nestedLevelDelta
    super.init()
  }

  private init(deepCopyOf variableNode: VariableNode) {
    self.argumentIndex = variableNode.argumentIndex
    self._textStyles = variableNode._textStyles
    self._layoutType = variableNode._layoutType
    self.nestedLevelDelta = variableNode.nestedLevelDelta
    super.init(deepCopyOf: variableNode)
  }

}
