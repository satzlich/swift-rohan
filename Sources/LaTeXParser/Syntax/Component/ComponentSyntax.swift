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
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    switch self {
    case .char(let charSyntax): return charSyntax.deparse(context)
    case .controlSymbol(let controlSymbolSyntax):
      return controlSymbolSyntax.deparse(context)
    case .controlWord(let controlWordSyntax): return controlWordSyntax.deparse(context)
    case .escapedChar(let escapedCharSyntax): return escapedCharSyntax.deparse(context)
    case .group(let groupSyntax): return groupSyntax.deparse(context)
    }
  }

  public func deparse(
    _ preference: DeparsePreference, _ context: DeparseContext
  ) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return self.deparse(context)

    case .properGroup, .wrapNonSymbol:
      switch self {
      case .char(let charSyntax):
        return charSyntax.deparse(context)

      case .controlSymbol(let controlSymbolSyntax):
        return controlSymbolSyntax.deparse(.properGroup, context)

      case .controlWord(let controlWordSyntax):
        return controlWordSyntax.deparse(.properGroup, context)

      case .escapedChar(let escapedCharSyntax):
        return escapedCharSyntax.deparse(context)

      case .group(let groupSyntax):
        return groupSyntax.deparse(.properGroup, context)
      }
    }
  }
}
