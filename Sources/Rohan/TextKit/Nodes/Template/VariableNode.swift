// Copyright 2024-2025 Lie Yan

/**
 A variable node represents a variable in the expansion of a template call.
 - Invariant: A variable node must be a descendant of an apply node.
 */
final class VariableNode: ElementNode {
  /** associated argument node */
  private weak var argumentNode: ArgumentNode?

  let argumentIndex: Int

  init(_ argumentIndex: Int) {
    self.argumentIndex = argumentIndex
    super.init()
  }

  internal init(deepCopyOf variableNode: VariableNode) {
    self.argumentIndex = variableNode.argumentIndex
    super.init(deepCopyOf: variableNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case argumentIndex }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .argumentIndex)
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argumentIndex)
    try super.encode(to: encoder)
  }

  func setArgumentNode(_ argument: ArgumentNode) {
    precondition(self.argumentNode == nil)
    assert(argument.argumentIndex == argumentIndex)
    self.argumentNode = argument
  }

  func isAssociated(with applyNode: ApplyNode) -> Bool {
    argumentNode?.isAssociated(with: applyNode) == true
  }

  override class var type: NodeType { .variable }

  override func deepCopy() -> VariableNode { Self(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(variable: self, context)
  }
}
