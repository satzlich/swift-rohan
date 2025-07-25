enum EquationSubtype: String, Codable {
  /// Inline equation.
  case inline
  /// Display equation without numbering.
  case display
  /// Display equation with numbering.
  case equation

  var isBlock: Bool {
    switch self {
    case .inline: false
    case .display: true
    case .equation: true
    }
  }

  var layoutType: LayoutType {
    switch self {
    case .inline: .inline
    case .display: .hardBlock
    case .equation: .hardBlock
    }
  }

  var shouldProvideCounter: Bool {
    switch self {
    case .inline: false
    case .display: false
    case .equation: true
    }
  }
}
