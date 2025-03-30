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

// Miscellaneous

extension Collection<Node> {
  /// Returns the only text node in the collection, if there is exactly one.
  func getOnlyTextNode() -> TextNode? {
    guard count == 1, let node = first as? TextNode else { return nil }
    return node
  }
}
