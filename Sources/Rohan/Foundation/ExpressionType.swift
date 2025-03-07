// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExpressionType: Equatable, Hashable, CaseIterable, Codable {
  // Template
  case apply
  case argument
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
  /**
   Returns true if the __remainders__ of lhs and rhs are mergeable.

   - Note: By __remainder__, we mean the end of the lhs and the start of the
   rhs must be cut off. The remainders of paragraphs are mergeable, but complete
   paragraphs are not.
   */
  static func isRemainderMergeable(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    let mergeableElements: [NodeType] = [.heading, .paragraph]
    return mergeableElements.contains(lhs) && mergeableElements.contains(rhs)
      || (lhs == .text && rhs == .text)
  }
}
