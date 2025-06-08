// Copyright 2024-2025 Lie Yan

/// A variable node represents a variable in the expansion of a template call.
/// - Invariant: A variable node must be a descendant of an apply node.
final class VariableNode: ElementNode {
  // MARK: - Node

  final override func deepCopy() -> Self { Self(deepCopyOf: self) }

  final override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(variable: self, context)
  }

  final override class var type: NodeType { .variable }

  final override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var current = super.getProperties(styleSheet)

      let key = InternalProperty.nestedLevel
      let value = key.resolveValue(current, styleSheet).integer()!
      let level = value + (1 - nestedLevelDelta % 2)
      current[key] = .integer(level)

      _cachedProperties = current
    }
    return _cachedProperties!
  }

  // MARK: - Node(Codable)

  private enum CodingKeys: CodingKey { case argIndex, levelDelta }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .argIndex)
    nestedLevelDelta = try container.decode(Int.self, forKey: .levelDelta)
    super.init()
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argIndex)
    try container.encode(nestedLevelDelta, forKey: .levelDelta)
    try super.encode(to: encoder)
  }

  // MARK: - Node(Storage)

  final override class var storageTags: Array<String> { /* emits no storage tags */ [] }

  final override func store() -> JSONValue {
    preconditionFailure("Work with apply nodes instead.")
  }

  override class func load(from json: JSONValue) -> NodeLoaded<Node> {
    preconditionFailure("Work with apply nodes instead.")
  }

  // MARK: - ElementNode

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

  private init(deepCopyOf variableNode: VariableNode) {
    self.argumentIndex = variableNode.argumentIndex
    self.nestedLevelDelta = variableNode.nestedLevelDelta
    super.init(deepCopyOf: variableNode)
  }

}
