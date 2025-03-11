// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExprType: String, Equatable, Hashable, CaseIterable, Codable, Sendable {
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
  case unnamedVariable

  // Misc
  case unknown
}

public typealias NodeType = ExprType
