// Copyright 2024-2025 Lie Yan

final class VariableNode: ElementNode {
  /** associated argument node */
  private weak var argumentNode: ArgumentNode?

  func setArgumentNode(_ argument: ArgumentNode) {
    precondition(self.argumentNode == nil)
    self.argumentNode = argument
  }

  func getArgumentIndex() -> Int? {
    argumentNode?.argumentIndex
  }

  func isAssociated(with applyNode: ApplyNode) -> Bool {
    argumentNode?.isAssociated(with: applyNode) == true
  }

  override class var nodeType: NodeType { .variable }

  override func deepCopy() -> VariableNode { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(variable: self, context)
  }
}
