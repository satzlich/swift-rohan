// Copyright 2024-2025 Lie Yan

import Foundation

internal enum PropertyName: Equatable, Hashable, Codable, Sendable {
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
  case textAlignment
  case paragraphSpacing

  // root
  case width
  case height
  case topMargin
  case bottomMargin
  case leftMargin
  case rightMargin
  /// nested level of nodes that requires visual delimiter. Internal use only.
  case _nestedLevel
}
