indirect enum ContainerPredicate {
  /// True if the node type equals the given node type.
  case nodeType(_ nodeType: NodeType)
  /// True if the parent type equals the given parent type.
  case parentType(_ parentType: NodeType)
  /// True if the container tag is in the supertag.
  case containerTag(_ superTag: ContainerTag)

  case negation(_ predicate: ContainerPredicate)
  case conjunction(_ predicates: Array<ContainerPredicate>)
  case disjunction(_ predicates: Array<ContainerPredicate>)

  @inlinable @inline(__always)
  func isSatisfied(_ containerProperty: ContainerProperty) -> Bool {
    switch self {
    case .nodeType(let nodeType):
      return containerProperty.nodeType == nodeType
    case .parentType(let parentType):
      return containerProperty.parentType == parentType
    case .containerTag(let superTag):
      return containerProperty.containerTag?.isSubset(of: superTag) ?? false
    case .negation(let predicate):
      return !predicate.isSatisfied(containerProperty)
    case .conjunction(let predicates):
      return predicates.allSatisfy { $0.isSatisfied(containerProperty) }
    case .disjunction(let predicates):
      return predicates.contains { $0.isSatisfied(containerProperty) }
    }
  }
}
