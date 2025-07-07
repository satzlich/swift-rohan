// Copyright 2024-2025 Lie Yan

enum HeadingSubtype: String, Codable, CaseIterable {
  case sectionAst
  case subsectionAst
  case subsubsectionAst
  case section
  case subsection
  case subsubsection

  @inlinable @inline(__always)
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

  @inlinable @inline(__always)
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

  @inlinable @inline(__always)
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
  @inlinable @inline(__always)
  func createCountHolder() -> CountHolder? {
    switch self {
    case .sectionAst: return nil
    case .subsectionAst: return nil
    case .subsubsectionAst: return nil
    case .section: return CountHolder(.section)
    case .subsection: return CountHolder(.subsection)
    case .subsubsection: return CountHolder(.subsubsection)
    }
  }

  func computePreamble(_ countHolder: CountHolder?) -> String {
    let defaultPreamble = "\u{200B}"  // Zero-width space

    switch self {
    case .sectionAst: return defaultPreamble
    case .subsectionAst: return defaultPreamble
    case .subsubsectionAst: return defaultPreamble

    case .section:
      guard let countHolder = countHolder else { return defaultPreamble }
      let section = countHolder.value(forName: .section)
      return "\(section) "

    case .subsection:
      guard let countHolder = countHolder else { return defaultPreamble }
      let section = countHolder.value(forName: .section)
      let subsection = countHolder.value(forName: .subsection)
      return "\(section).\(subsection) "

    case .subsubsection:
      guard let countHolder = countHolder else { return defaultPreamble }
      let section = countHolder.value(forName: .section)
      let subsection = countHolder.value(forName: .subsection)
      let subsubsection = countHolder.value(forName: .subsubsection)
      return "\(section).\(subsection).\(subsubsection) "
    }
  }
}
