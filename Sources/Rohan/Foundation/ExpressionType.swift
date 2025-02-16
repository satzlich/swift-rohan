// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExpressionType: Equatable, Hashable, CaseIterable, Codable {
  // Expression
  case apply
  case variable
  case namelessVariable

  // Construction Bricks
  case linebreak
  case text

  // Elements
  case content
  case emphasis
  case heading
  case paragraph
  case root
  case textMode

  // Math
  case equation
  case fraction
  case matrix
  case scripts
}

public typealias NodeType = ExpressionType

extension NodeType {
  @inline(__always)
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    Meta.matches(nodeType, .heading, .paragraph)
  }

  @inline(__always)
  static func isPivotalNode(_ nodeType: NodeType) -> Bool {
    Meta.matches(nodeType, .equation, .fraction)
  }

  @inline(__always)
  static func isOpqaueNode(_ nodeType: NodeType) -> Bool {
    !Meta.matches(nodeType, .paragraph, .text)
  }

  /** Returns true if node is allowed to be empty. */
  @inline(__always)
  static func isAllowedToBeEmpty(_ nodeType: NodeType) -> Bool {
    nodeType != .text
  }

  /**
   Returns true if the __remainders__ of lhs and rhs are mergeable.

   - Note: By __remainder__, we mean the end of the lhs and the start of the
   rhs must be cut off. The remainders of paragraphs are mergeable, but complete
   paragraphs are not.
   */
  @inline(__always)
  static func isRemainderMergeable(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    lhs == rhs && Meta.matches(lhs, .paragraph, .text) && Meta.matches(rhs, .paragraph, .text)
  }
}
