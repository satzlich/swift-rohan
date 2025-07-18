// Copyright 2024-2025 Lie Yan

import Foundation

struct ConstraintEngine {

  nonisolated(unsafe) static let shared = ConstraintEngine()

  internal func isCompatible(
    _ content: ContentProperty, _ container: ContainerProperty
  ) -> Bool {
    content.contentMode.isCompatible(with: container.containerMode)
      && content.contentType.isCompatible(with: container.containerType)
      && _checkConstraint(content, container)
  }

  internal func _checkConstraint(
    _ content: ContentProperty, _ container: ContainerProperty
  ) -> Bool {
    if let contentConstraint = _contentConstraints[content.nodeType] {
      for rule in contentConstraint {
        if !rule.isSatisfied(content, container) {
          return false
        }
      }
    }

    if let containerConstraint = _containerConstraints[container.nodeType] {
      for rule in containerConstraint {
        if !rule.isSatisfied(content, container) {
          return false
        }
      }
    }

    return true
  }

  // MARK: - State

  private let _contentConstraints:
    Dictionary<NodeType, Array<ConstraintRule.MustBeContainedIn>>

  private let _containerConstraints:
    Dictionary<NodeType, Array<ConstraintRule.CanContainOnly>>

  init() {
    _contentConstraints = Self._contentConstraints.reduce(into: [:]) { dict, rule in
      dict[rule.content.nodeType, default: []].append(rule)
    }

    _containerConstraints = Self._containerConstraints.reduce(into: [:]) { dict, rule in
      dict[rule.container, default: []].append(rule)
    }
  }

  nonisolated(unsafe) static let _contentConstraints:
    Array<ConstraintRule.MustBeContainedIn> = [
      .init(
        SubjectPredicate(.heading),
        .disjunction([
          .nodeType(.root),
          .conjunction([.nodeType(.paragraph), .parentType(.root)]),
        ])),
      .init(
        SubjectPredicate(.parList),
        .disjunction([
          .nodeType(.root),
          .conjunction([.nodeType(.paragraph), .parentType(.root)]),
        ])),
      .init(
        SubjectPredicate(.itemList),
        .conjunction([.nodeType(.paragraph), .negation(.parentType(.itemList))])),
      .init(SubjectPredicate(.equation, .contentType(.block)), .nodeType(.paragraph)),
      .init(.multiline, .paragraph),
    ]

  static let _containerConstraints: Array<ConstraintRule.CanContainOnly> = [
    .init(.heading, .contentTag([.plaintext, .formula, .styledText])),
    .init(.textStyles, .contentTag([.plaintext, .formula])),
    .init(.textMode, .contentTag([.plaintext])),
    .init(.itemList, .nodeType(.paragraph)),
    .init(.parList, .nodeType(.paragraph)),
  ]
}
