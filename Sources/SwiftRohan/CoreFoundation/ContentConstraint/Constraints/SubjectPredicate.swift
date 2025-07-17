// Copyright 2024-2025 Lie Yan

struct SubjectPredicate {
  let nodeType: NodeType
  let predicate: Optional<ContentPredicate>

  init(_ nodeType: NodeType, _ predicate: ContentPredicate? = nil) {
    self.nodeType = nodeType
    self.predicate = predicate
  }

  func isSatisfied(_ contentProperty: ContentProperty) -> Bool {
    contentProperty.nodeType == nodeType
      && (predicate?.isSatisfied(contentProperty) ?? true)
  }
}
