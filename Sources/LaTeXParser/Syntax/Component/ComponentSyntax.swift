// Copyright 2024-2025 Lie Yan

public indirect enum ComponentSyntax: SyntaxProtocol {
  case char(CharSyntax)
  case controlChar(ControlCharSyntax)  // with no arguments
  case controlSeq(ControlSeqSyntax)  // with no arguments
  case escapedChar(EscapedCharSyntax)
  case group(GroupSyntax)

  public init(_ char: CharSyntax) { self = .char(char) }
  public init(_ controlChar: ControlCharSyntax) {
    precondition(controlChar.argument == nil)
    self = .controlChar(controlChar)
  }
  public init(_ controlSeq: ControlSeqSyntax) {
    precondition(controlSeq.arguments.isEmpty)
    self = .controlSeq(controlSeq)
  }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
}

extension ComponentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .char(let charSyntax): charSyntax.deparse()
    case .controlChar(let controlCharSyntax): controlCharSyntax.deparse()
    case .controlSeq(let controlSeqSyntax): controlSeqSyntax.deparse()
    case .escapedChar(let escapedCharSyntax): escapedCharSyntax.deparse()
    case .group(let groupSyntax): groupSyntax.deparse()
    }
  }
}
