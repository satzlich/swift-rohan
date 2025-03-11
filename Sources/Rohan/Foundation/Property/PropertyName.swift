// Copyright 2024-2025 Lie Yan

import Foundation

public enum PropertyName: Equatable, Hashable, Codable, Sendable {
  // font
  case fontFamily
  case fontSize
  case fontStretch
  case fontStyle
  case fontWeight
  case foregroundColor

  // math
  case bold
  case italic
  case autoItalic
  case cramped
  case mathStyle
  case mathVariant

  // equation
  case isBlock

  // heading
  case level

  // paragraph
  case topMargin
  case bottomMargin
  case topPadding
  case bottomPadding
}
