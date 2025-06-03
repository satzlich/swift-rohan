// Copyright 2024-2025 Lie Yan

// Check node category

@inline(__always) func isApplyNode(_ node: Node) -> Bool { node is ApplyNode }
@inline(__always) func isArgumentNode(_ node: Node) -> Bool { node is ArgumentNode }
@inline(__always) func isElementNode(_ node: Node) -> Bool { node is ElementNode }
@inline(__always) func isMathNode(_ node: Node) -> Bool { node is MathNode }
@inline(__always) func isArrayNode(_ node: Node) -> Bool { node is ArrayNode }
@inline(__always) func isSimpleNode(_ node: Node) -> Bool { node is SimpleNode }
@inline(__always) func isTextNode(_ node: Node) -> Bool { node is TextNode }

// Check specific node type

@inline(__always) func isContentNode(_ node: Node) -> Bool { node is ContentNode }
@inline(__always) func isParagraphNode(_ node: Node) -> Bool { node is ParagraphNode }
@inline(__always) func isRootNode(_ node: Node) -> Bool { node is RootNode }

@inline(__always) func isAttachNode(_ node: Node) -> Bool { node is AttachNode }
@inline(__always) func isEquationNode(_ node: Node) -> Bool { node is EquationNode }
@inline(__always) func isRadicalNode(_ node: Node) -> Bool { node is RadicalNode }

@inline(__always) func isLinebreakNode(_ node: Node) -> Bool { node is LinebreakNode }
@inline(__always) func isNamedSymbolNode(_ node: Node) -> Bool { node is NamedSymbolNode }

// Check node type and cast

/// Cast node to ElementNode where VariableNode is used as proxy for ArgumentNode.
/// - Returns `nil` if the node is not an ElementNode or ArgumentNode.
func castElementOrArgumentNode(_ node: Node) -> ElementNode? {
  switch node {
  case let node as ElementNode: return node
  case let node as ArgumentNode: return node.variableNodes[0]
  default: return nil
  }
}
