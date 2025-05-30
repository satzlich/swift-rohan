// Copyright 2024-2025 Lie Yan

public indirect enum ComponentSyntax: SyntaxProtocol {
  /// Example: the parenthesis in `\left(`
  case char(CharSyntax)

  case controlChar(ControlCharSyntax)  // with no arguments
  case controlSeq(ControlSeqSyntax)  // with no arguments

  /// Example: the escaped character `\%`
  case escapedChar(EscapedCharSyntax)

  case group(GroupSyntax)

  public init(_ char: CharSyntax) { self = .char(char) }
  public init(_ controlChar: ControlCharSyntax) {
    if controlChar.argument == nil {
      self = .controlChar(controlChar)
    }
    else {
      self = .group(GroupSyntax([.controlChar(controlChar)]))
    }
  }
  public init(_ controlSeq: ControlSeqSyntax) {
    if controlSeq.arguments.isEmpty {
      self = .controlSeq(controlSeq)
    }
    else {
      self = .group(GroupSyntax([.controlSeq(controlSeq)]))
    }
  }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
}

extension ComponentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .char(let charSyntax): return charSyntax.deparse()
    case .controlChar(let controlCharSyntax): return controlCharSyntax.deparse()
    case .controlSeq(let controlSeqSyntax): return controlSeqSyntax.deparse()
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

      case .controlChar(let controlCharSyntax):
        return controlCharSyntax.deparse(.properGroup)

      case .controlSeq(let controlSeqSyntax):
        return controlSeqSyntax.deparse(.properGroup)

      case .escapedChar(let escapedCharSyntax):
        return escapedCharSyntax.deparse()

      case .group(let groupSyntax):
        return groupSyntax.deparse(.properGroup)
      }
    }
  }
}
