// Copyright 2024-2025 Lie Yan

import Foundation

enum ConstraintRule {
  case canContainOnly(CanContainOnly)
  case mustBeInsertedInto(MustBeInsertedInto)

  func isSatisfied(_ content: ContentProperty, _ container: ContainerProperty) -> Bool {
    switch self {
    case .canContainOnly(let rule):
      return rule.isSatisfied(content, container)
    case .mustBeInsertedInto(let rule):
      return rule.isSatisfied(content, container)
    }
  }

  /// container($1) => content($0)
  struct CanContainOnly {
    let container: NodeType
    let content: ContentPredicate

    init(_ container: NodeType, _ content: ContentPredicate) {
      self.container = container
      self.content = content
    }

    func isSatisfied(_ content: ContentProperty, _ container: ContainerProperty) -> Bool {
      !(self.container == container.nodeType) || self.content.isSatisfied(content)
    }
  }

  /// content($0) => container($1)
  struct MustBeInsertedInto {
    let content: SubjectPredicate
    let container: ContainerPredicate

    init(_ content: NodeType, _ container: NodeType) {
      self.content = SubjectPredicate(content)
      self.container = .nodeType(container)
    }

    init(_ content: SubjectPredicate, _ container: ContainerPredicate) {
      self.content = content
      self.container = container
    }

    func isSatisfied(_ content: ContentProperty, _ container: ContainerProperty) -> Bool {
      !self.content.isSatisfied(content) || self.container.isSatisfied(container)
    }
  }
}
