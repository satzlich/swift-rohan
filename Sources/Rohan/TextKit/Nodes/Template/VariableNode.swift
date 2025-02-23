// Copyright 2024-2025 Lie Yan

final class VariableNode: ElementNode {
  private(set) weak var argument: ArgumentNode?

  func setArgument(_ argument: ArgumentNode) {
    self.argument = argument
  }

  override class var nodeType: NodeType { .variable }

  override func deepCopy() -> VariableNode { Self(deepCopyOf: self) }

  override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    visitor.visit(variable: self, context)
  }
}
