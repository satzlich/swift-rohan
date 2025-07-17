// Copyright 2024-2025 Lie Yan

import Foundation

struct SubjectPredicate {
  let nodeType: NodeType
  let predicate: Optional<ContentPredicate>

  init(_ nodeType: NodeType, _ predicate: ContentPredicate? = nil) {
    self.nodeType = nodeType
    self.predicate = predicate
  }

  func matches(_ contentProperty: ContentProperty) -> Bool {
    return contentProperty.nodeType == nodeType
      && (predicate?.matches(contentProperty) ?? true)
  }
}

enum ContentPredicate {
  /// True if the content tag of subject is in the given set.
  case contentTag(ContentTag)
  /// True if the content type of subject equals the given content type.
  case contentType(ContentType)

  @inlinable @inline(__always)
  func matches(_ contentProperty: ContentProperty) -> Bool {
    asObjectPredicate.matches(contentProperty)
  }

  @inlinable @inline(__always)
  var asObjectPredicate: ObjectPredicate {
    switch self {
    case .contentTag(let tag):
      return .contentTag(tag)
    case .contentType(let type):
      return .contentType(type)
    }
  }
}

enum ObjectPredicate {
  case nodeType(_ nodeType: NodeType)
  /// True if the content tag of subject is in the given set.
  case contentTag(ContentTag)
  /// True if the content type of subject equals the given content type.
  case contentType(ContentType)

  @inlinable @inline(__always)
  func matches(_ contentProperty: ContentProperty) -> Bool {
    switch self {
    case .nodeType(let nodeType):
      return contentProperty.nodeType == nodeType
    case .contentTag(let tag):
      return contentProperty.contentTag.map { tag.contains($0) } ?? false
    case .contentType(let type):
      return contentProperty.contentType == type
    }
  }
}

enum ConstraintRule {
  case canContainOnly(_ container: NodeType, _ content: ObjectPredicate)
  case mustBeContainedIn(_ content: SubjectPredicate, _ container: NodeType)
}

let contentConstaints: Array<ConstraintRule> = [
  .mustBeContainedIn(SubjectPredicate(.parList), .root),
  .mustBeContainedIn(SubjectPredicate(.heading), .root),
  .mustBeContainedIn(SubjectPredicate(.itemList), .paragraph),
  .mustBeContainedIn(SubjectPredicate(.equation, .contentType(.block)), .paragraph),
  .mustBeContainedIn(SubjectPredicate(.multiline), .paragraph),
]

let containerConstraints: Array<ConstraintRule> = [
  .canContainOnly(.heading, .contentTag([.plaintext, .formula])),
  .canContainOnly(.textStyles, .contentTag([.plaintext, .formula])),
  .canContainOnly(.textMode, .contentTag([.plaintext])),
  .canContainOnly(.itemList, .nodeType(.paragraph)),
  .canContainOnly(.parList, .nodeType(.paragraph)),
]
