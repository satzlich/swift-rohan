// Copyright 2024-2025 Lie Yan

indirect enum ContainerPredicate {
  /// True if the node type equals the given node type.
  case nodeType(_ nodeType: NodeType)
  /// True if the parent type equals the given parent type.
  case parentType(_ parentType: NodeType)

  case negation(_ predicate: ContainerPredicate)
  case conjunction(_ predicates: Array<ContainerPredicate>)

  @inlinable @inline(__always)
  func isSatisfied(_ containerProperty: ContainerProperty) -> Bool {
    switch self {
    case .nodeType(let nodeType):
      return containerProperty.nodeType == nodeType
    case .parentType(let parentType):
      return containerProperty.parentType == parentType
    case .negation(let predicate):
      return !predicate.isSatisfied(containerProperty)
    case .conjunction(let predicates):
      return predicates.allSatisfy { $0.isSatisfied(containerProperty) }
    }
  }
}
