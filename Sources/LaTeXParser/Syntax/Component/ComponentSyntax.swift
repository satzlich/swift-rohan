// Copyright 2024-2025 Lie Yan

public indirect enum ComponentSyntax: SyntaxProtocol {
  /// Example: the parenthesis in `\left(`
  case char(CharSyntax)

  case controlSymbol(ControlSymbolSyntax)  // with no arguments
  case controlWord(ControlWordSyntax)  // with no arguments

  /// Example: the escaped character `\%`
  case escapedChar(EscapedCharSyntax)

  case group(GroupSyntax)

  public init(_ char: CharSyntax) { self = .char(char) }
  public init(_ controlSymbol: ControlSymbolSyntax) {
    if controlSymbol.argument == nil {
      self = .controlSymbol(controlSymbol)
    }
    else {
      self = .group(GroupSyntax([.controlSymbol(controlSymbol)]))
    }
  }
  public init(_ controlWord: ControlWordSyntax) {
    if controlWord.arguments.isEmpty {
      self = .controlWord(controlWord)
    }
    else {
      self = .group(GroupSyntax([.controlWord(controlWord)]))
    }
  }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
}

extension ComponentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .char(let charSyntax): return charSyntax.deparse()
    case .controlSymbol(let controlSymbolSyntax): return controlSymbolSyntax.deparse()
    case .controlWord(let controlWordSyntax): return controlWordSyntax.deparse()
    case .escapedChar(let escapedCharSyntax): return escapedCharSyntax.deparse()
    case .group(let groupSyntax): return groupSyntax.deparse()
    }
  }

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return self.deparse()

    case .properGroup:
      switch self {
      case .char(let charSyntax):
        return charSyntax.deparse()

      case .controlSymbol(let controlSymbolSyntax):
        return controlSymbolSyntax.deparse(.properGroup)

      case .controlWord(let controlWordSyntax):
        return controlWordSyntax.deparse(.properGroup)

      case .escapedChar(let escapedCharSyntax):
        return escapedCharSyntax.deparse()

      case .group(let groupSyntax):
        return groupSyntax.deparse(.properGroup)
      }
    }
  }
}
