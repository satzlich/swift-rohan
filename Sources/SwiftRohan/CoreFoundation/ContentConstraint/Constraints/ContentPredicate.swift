enum ContentPredicate {
  /// True if the node type equals the given node type.
  case nodeType(NodeType)
  /// True if the content tag is in the given super tag.
  case contentTag(_ superTag: ContentTag)
  /// True if the content type equals the given content type.
  case contentType(ContentType)

  case disjunction(_ predicates: Array<ContentPredicate>)

  @inlinable @inline(__always)
  func isSatisfied(_ contentProperty: ContentProperty) -> Bool {
    switch self {
    case .nodeType(let nodeType):
      return contentProperty.nodeType == nodeType
    case .contentTag(let superTag):
      return contentProperty.contentTag?.isSubset(of: superTag) ?? false
    case .contentType(let contentType):
      return contentProperty.contentType == contentType
    case .disjunction(let predicates):
      return predicates.contains { $0.isSatisfied(contentProperty) }
    }
  }
}
