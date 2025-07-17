// Copyright 2024-2025 Lie Yan

import Foundation

struct RuleSubject {
  let nodeType: NodeType
  let predicate: Optional<NodePredicate>

  init(_ nodeType: NodeType, _ predicate: NodePredicate? = nil) {
    self.nodeType = nodeType
    self.predicate = predicate
  }
}

enum NodePredicate {
  /// True if the content tag of subject is in the given set.
  case contentTag(ContentTag)
  /// True if the node type of subject equals the given node type.
  case nodeType(NodeType)
  /// True if the content type of subject equals the given content type.
  case contentType(ContentType)
}

enum ConstraintRule {
  case canContainOnly(_ container: NodeType, _ content: NodePredicate)
  case mustBeContainedIn(_ content: RuleSubject, _ container: NodeType)
}

let contentConstaints: Array<ConstraintRule> = [
  .mustBeContainedIn(RuleSubject(.parList), .root),
  .mustBeContainedIn(RuleSubject(.heading), .root),
  .mustBeContainedIn(RuleSubject(.itemList), .paragraph),
  .mustBeContainedIn(RuleSubject(.equation, .contentType(.block)), .paragraph),
  .mustBeContainedIn(RuleSubject(.multiline), .paragraph),
]

let containerConstraints: Array<ConstraintRule> = [
  .canContainOnly(.heading, .contentTag([.plaintext, .formula])),
  .canContainOnly(.textStyles, .contentTag([.plaintext, .formula])),
  .canContainOnly(.textMode, .contentTag([.plaintext])),
  .canContainOnly(.itemList, .nodeType(.paragraph)),
  .canContainOnly(.parList, .nodeType(.paragraph)),
]
