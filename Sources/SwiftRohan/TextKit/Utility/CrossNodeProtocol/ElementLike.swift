// Copyright 2024-2025 Lie Yan

/// Common interface for nodes that can have linear children.
protocol ElementLike: Node {
  func getChild(_ index: Int) -> Node
}

extension ElementNode: ElementLike {}

extension ArgumentNode: ElementLike {}
