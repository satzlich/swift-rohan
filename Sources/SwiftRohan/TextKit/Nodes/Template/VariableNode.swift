// Copyright 2024-2025 Lie Yan

/// A variable node represents a variable in the expansion of a template call.
/// - Invariant: A variable node must be a descendant of an apply node.
final class VariableNode: ElementNode {
  /// associated argument node
  private(set) weak var argumentNode: ArgumentNode?

  let argumentIndex: Int
  /// The delta of the nested level from the apply node.
  let nestedLevelDelta: Int

  internal func setArgumentNode(_ argument: ArgumentNode) {
    precondition(self.argumentNode == nil)
    assert(argument.argumentIndex == argumentIndex)
    self.argumentNode = argument
  }

  internal func isAssociated(with applyNode: ApplyNode) -> Bool {
    argumentNode?.isAssociated(with: applyNode) == true
  }

  init(_ argumentIndex: Int, nestedLevelDelta: Int = 0) {
    self.argumentIndex = argumentIndex
    self.nestedLevelDelta = nestedLevelDelta
    super.init()
  }

  internal init(deepCopyOf variableNode: VariableNode) {
    self.argumentIndex = variableNode.argumentIndex
    self.nestedLevelDelta = variableNode.nestedLevelDelta
    super.init(deepCopyOf: variableNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case argIndex, levelDelta }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .argIndex)
    nestedLevelDelta = try container.decode(Int.self, forKey: .levelDelta)
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argIndex)
    try container.encode(nestedLevelDelta, forKey: .levelDelta)
    try super.encode(to: encoder)
  }

  override class var type: NodeType { .variable }

  override func deepCopy() -> VariableNode { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(variable: self, context)
  }

  override func accept<R, C, V, T, S>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R where V: NodeVisitor<R, C>, T: NodeLike, T == S.Element, S: Collection {
    visitor.visit(variable: self, context, withChildren: children)
  }

  // MARK: - Storage

  override class var storageTags: [String] {
    // variable node emits no storage tags
    []
  }

  override func store() -> JSONValue {
    preconditionFailure("should not be called. Work with apply nodes instead.")
  }

  override class func load(from json: JSONValue) -> _LoadResult<Node> {
    preconditionFailure("should not be called. Work with apply nodes instead.")
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)
      let key = InternalProperty.nestedLevel
      let value = key.resolve(properties, styleSheet).integer()!
      // adjust the nested level
      let level = value + (1 - nestedLevelDelta % 2)
      properties[key] = .integer(level)
      //cache
      _cachedProperties = properties
    }
    return _cachedProperties!
  }
}
