// Copyright 2024-2025 Lie Yan

extension MathStyle: CommandDeclarationProtocol {
  var command: String {
    switch self {
    case .display: return "displaystyle"
    case .text: return "textstyle"
    case .script: return "scriptstyle"
    case .scriptScript: return "scriptscriptstyle"
    }
  }

  static var allCommands: [MathStyle] { MathStyle.allCases }
}
