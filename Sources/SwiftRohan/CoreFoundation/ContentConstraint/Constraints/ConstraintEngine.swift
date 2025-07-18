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
    Dictionary<NodeType, Array<ConstraintRule.MustBeInsertedInto>>

  private let _containerConstraints:
    Dictionary<NodeType, Array<ConstraintRule.CanInsertOnly>>

  init() {
    _contentConstraints = Self._contentConstraints.reduce(into: [:]) { dict, rule in
      dict[rule.content.nodeType, default: []].append(rule)
    }

    _containerConstraints = Self._containerConstraints.reduce(into: [:]) { dict, rule in
      dict[rule.container, default: []].append(rule)
    }
  }

  nonisolated(unsafe) static let _contentConstraints:
    Array<ConstraintRule.MustBeInsertedInto> = [
      // heading must be inserted into a root node or a paragraph whose parent is a root node.
      .init(
        SubjectPredicate(.heading),
        .disjunction([
          .nodeType(.root),
          .conjunction([.nodeType(.paragraph), .parentType(.root)]),
        ])),
      // parList must be inserted into a root node or a paragraph whose parent is a root node.
      .init(
        SubjectPredicate(.parList),
        .disjunction([
          .nodeType(.root),
          .conjunction([.nodeType(.paragraph), .parentType(.root)]),
        ])),
      // itemList must be inserted into a paragraph whose parent is not an itemList.
      .init(
        SubjectPredicate(.itemList),
        .conjunction([.nodeType(.paragraph), .negation(.parentType(.itemList))])),
      // block equation must be inserted into a paragraph.
      .init(
        SubjectPredicate(.equation, .contentType(.block)),
        .disjunction([.nodeType(.paragraph), .containerTag(.paragraphContainer)])),
      // multiline must be inserted into a paragraph.
      .init(
        SubjectPredicate(.multiline),
        .disjunction([.nodeType(.paragraph), .containerTag(.paragraphContainer)])),
    ]

  static let _containerConstraints: Array<ConstraintRule.CanInsertOnly> = [
    // heading can contain only "plaintext", "formula", and "styledText".
    .init(.heading, .contentTag([.plaintext, .formula, .styledText])),
    // textStyles can contain only "plaintext", "formula".
    .init(.textStyles, .contentTag([.plaintext, .formula])),
    // textMode can contain only "plaintext".
    .init(.textMode, .contentTag([.plaintext])),
    // itemList can contain only "paragraph"s.
    .init(
      .itemList,
      .disjunction([
        .nodeType(.paragraph), .contentTag([.plaintext, .formula, .styledText]),
      ])),
    // parList can contain only "paragraph"s.
    .init(
      .parList,
      .disjunction([
        .nodeType(.paragraph), .contentTag([.plaintext, .formula, .styledText]),
      ])),
  ]
}
