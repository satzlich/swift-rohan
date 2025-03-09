// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExpressionType: String, Equatable, Hashable, CaseIterable, Codable {
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

  // Template
  case apply
  case argument
  case variable
  case namelessVariable

  // Misc
  case unknown
}

public typealias NodeType = ExpressionType
