// Copyright 2024-2025 Lie Yan

import Foundation

struct RuleSubject {
  let nodeType: NodeType
  let predicate: Optional<RulePredicate>

  init(_ nodeType: NodeType, _ predicate: RulePredicate? = nil) {
    self.nodeType = nodeType
    self.predicate = predicate
  }
}

enum RulePredicate {
  /// True if the tag of the subject is in the given set.
  case contentTag(ContentTag)
  /// True if the node type of the subject equals the given node type.
  case nodeType(NodeType)
  /// True if the content type of the subject equals the given content type.
  case contentType(ContentType)
}

enum ConstraintRule {
  case canContainOnly(_ subject: NodeType, _ object: RulePredicate)
  case mustBeContainedIn(_ subject: RuleSubject, _ object: NodeType)
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
