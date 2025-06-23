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

  // multiline
  // Not a typo. The name `{multline}` is a LaTeX math environment.
  case isMultline

  // heading
  case level

  // paragraph
  case firstLineHeadIndent
  case headIndent
  case paragraphSpacing
  case textAlignment

  // root
  case width
  case height
  case topMargin
  case bottomMargin
  case leftMargin
  case rightMargin

  // strong
  case command

  /// nested level of nodes that requires visual delimiter. Internal use only.
  case _nestedLevel
}
