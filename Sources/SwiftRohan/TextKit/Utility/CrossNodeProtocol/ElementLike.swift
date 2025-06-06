// Copyright 2024-2025 Lie Yan

/// Common interface for nodes that can have linear children.
protocol ElementLike: Node {
  var childCount: Int { get }
  func getChild(_ index: Int) -> Node

  func accept<R, C, V: NodeVisitor<R, C>, T: NodeLike, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R
}

extension ElementNode: ElementLike {}

extension ArgumentNode: ElementLike {}
