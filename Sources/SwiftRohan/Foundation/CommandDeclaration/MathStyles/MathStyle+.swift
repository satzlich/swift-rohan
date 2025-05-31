// Copyright 2024-2025 Lie Yan

import LaTeXParser

extension MathStyle: CommandDeclarationProtocol {
  var command: String {
    switch self {
    case .display: return "displaystyle"
    case .text: return "textstyle"
    case .script: return "scriptstyle"
    case .scriptScript: return "scriptscriptstyle"
    }
  }

  var genre: CommandGenre { .other }
  var source: CommandSource { .builtIn }
  static var allCommands: [MathStyle] { MathStyle.allCases }
}
