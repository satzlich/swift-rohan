// Copyright 2024-2025 Lie Yan

import LatexParser

enum TextStyles: String, CaseIterable, CommandDeclarationProtocol {
  case emph
  case textbf
  case textit
  case texttt

  var command: String { rawValue }
  var source: CommandSource { .preBuilt }
  var tag: CommandTag { .null }

  static var allCommands: Array<TextStyles> { allCases }
}

extension TextStyles {
  static func lookup(_ command: String) -> TextStyles? {
    TextStyles(rawValue: command)
  }
}
