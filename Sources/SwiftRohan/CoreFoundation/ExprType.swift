// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExprType: String, CaseIterable, Codable, Sendable {
  // Misc
  case counter
  case linebreak
  case namedSymbol
  case text
  case unknown

  // Elements
  case content
  case expansion
  case heading
  case itemList
  case paragraph
  case parList
  case root
  case textStyles

  // Math
  case accent
  case attach
  case equation
  case fraction
  case leftRight
  case mathAttributes
  case mathExpression  // Simple but Math only
  case mathOperator  // Simple but Math only
  case mathStyles
  case matrix
  case multiline  // align, gather, multiline, etc.
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
