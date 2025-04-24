// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExprType: String, CaseIterable, Codable, Sendable {
  // Misc
  case linebreak
  case text
  case unknown

  // Elements
  case content
  case emphasis
  case heading
  case paragraph
  case root
  case strong

  // Math
  case accent
  case attach
  case equation
  case fraction
  case matrix
  case textMode

  // Template
  case apply
  case argument
  case cVariable
  case variable
}

public typealias NodeType = ExprType
