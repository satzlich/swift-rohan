// Copyright 2024-2025 Lie Yan

enum HeadingSubtype: String, Codable, CaseIterable {
  case sectionAst
  case subsectionAst
  case subsubsectionAst

  var level: Int {
    switch self {
    case .sectionAst: return 1
    case .subsectionAst: return 2
    case .subsubsectionAst: return 3
    }
  }

  var command: String {
    switch self {
    case .sectionAst: return "section*"
    case .subsectionAst: return "subsection*"
    case .subsubsectionAst: return "subsubsection*"
    }
  }

  static func fromCommand(_ command: String) -> HeadingSubtype? {
    switch command {
    case "section*": return .sectionAst
    case "subsection*": return .subsectionAst
    case "subsubsection*": return .subsubsectionAst
    default: return nil
    }
  }
}
