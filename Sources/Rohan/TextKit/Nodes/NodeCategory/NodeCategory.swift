// Copyright 2024-2025 Lie Yan

// Check node category

func isApplyNode(_ node: Node) -> Bool { node is ApplyNode }
func isArgumentNode(_ node: Node) -> Bool { node is ArgumentNode }
func isElementNode(_ node: Node) -> Bool { node is ElementNode }
func isMathNode(_ node: Node) -> Bool { node is MathNode }
func isSimpleNode(_ node: Node) -> Bool { node is _SimpleNode }
func isTextNode(_ node: Node) -> Bool { node is TextNode }

// Check specific node type

func isRootNode(_ node: Node) -> Bool { node is RootNode }
func isParagraphNode(_ node: Node) -> Bool { node is ParagraphNode }

// Check document structural kind.

/// Returns true if `node` is a top-level node.
func isTopLevelNode(_ node: Node) -> Bool { NodePolicy.isTopLevel(node.type) }

/// Returns true if given node can be used as paragraph container, that is,
/// it is either a paragraph container or a top-level container.
func isParagraphContainerLike(_ node: Node) -> Bool {
  NodePolicy.isParagraphContainerLike(node.type)
}

// Miscellaneous checks

/// Returns true if `nodes` consist of a single TextNode.
func isSingleTextNode<C>(_ nodes: C) -> Bool
where C: Collection, C.Element == Node {
  nodes.count == 1 && isTextNode(nodes.first!)
}

/// Returns the single TextNode in `nodes`, if it exists.
func getSingleTextNode<C>(_ nodes: C) -> TextNode?
where C: Collection, C.Element == Node {
  guard nodes.count == 1, let node = nodes.first as? TextNode
  else { return nil }
  return node
}

/// Returns true if two element nodes are mergeable.
func isMergeableElements(_ lhs: Node, _ rhs: Node) -> Bool {
  NodePolicy.isMergeableElements(lhs.type, rhs.type)
}

/// Returns true if the node needs special highlight to delimit its boundary.
func needsVisualDelimiter(_ node: Node) -> Bool {
  NodePolicy.needsVisualDelimiter(node.type)
}
