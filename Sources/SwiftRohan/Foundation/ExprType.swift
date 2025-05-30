// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExprType: String, CaseIterable, Codable, Sendable {
  // Misc
  case linebreak
  case namedSymbol
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
  case leftRight
  case mathAttributes
  case mathExpression  // Simple but Math only
  case mathOperator  // Simple but Math only
  case mathVariant  // Element but Math only
  case matrix
  case radical
  case textMode
  case underOver

  // Template
  case apply
  case argument
  case cVariable
  case variable
}

public typealias NodeType = ExprType
