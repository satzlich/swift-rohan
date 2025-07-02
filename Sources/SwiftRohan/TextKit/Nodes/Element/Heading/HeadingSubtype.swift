// Copyright 2024-2025 Lie Yan

enum HeadingSubtype: String, Codable, CaseIterable {
  case sectionAst
  case subsectionAst
  case subsubsectionAst
  case section
  case subsection
  case subsubsection

  var level: Int {
    switch self {
    case .sectionAst: return 1
    case .subsectionAst: return 2
    case .subsubsectionAst: return 3
    case .section: return 1
    case .subsection: return 2
    case .subsubsection: return 3
    }
  }

  var command: String {
    switch self {
    case .sectionAst: return "section*"
    case .subsectionAst: return "subsection*"
    case .subsubsectionAst: return "subsubsection*"
    case .section: return "section"
    case .subsection: return "subsection"
    case .subsubsection: return "subsubsection"
    }
  }

  static func fromCommand(_ command: String) -> HeadingSubtype? {
    switch command {
    case "section*": return .sectionAst
    case "subsection*": return .subsectionAst
    case "subsubsection*": return .subsubsectionAst
    case "section": return .section
    case "subsection": return .subsection
    case "subsubsection": return .subsubsection
    default: return nil
    }
  }

  /// Returns a new instance of `CountHolder` for this heading subtype.
  func createCountHolder() -> CountHolder? {
    switch self {
    case .sectionAst: return nil
    case .subsectionAst: return nil
    case .subsubsectionAst: return nil
    case .section: return BasicCountHolder(.section)
    case .subsection: return BasicCountHolder(.subsection)
    case .subsubsection: return BasicCountHolder(.subsubsection)
    }
  }
}
