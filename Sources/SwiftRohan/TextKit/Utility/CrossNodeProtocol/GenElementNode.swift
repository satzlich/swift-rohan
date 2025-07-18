// Copyright 2024-2025 Lie Yan

/// Common interface for nodes that can have linear children.
protocol GenElementNode: Node {
  var containerType: ContainerType? { get }

  /// The number of child nodes.
  var childCount: Int { get }

  /// Returns the child node at the specified index.
  /// - Precondition: `index` must be within the bounds of the children.
  func getChild(_ index: Int) -> Node

  /// Accepts a visitor to visit the given children in the manner of this node.
  func accept<R, C, V: NodeVisitor<R, C>, T: GenNode, S: Collection<T>>(
    _ visitor: V, _ context: C, withChildren children: S
  ) -> R
}

extension ElementNode: GenElementNode {}

extension ArgumentNode: GenElementNode {}
