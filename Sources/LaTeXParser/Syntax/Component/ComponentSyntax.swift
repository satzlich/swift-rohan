// Copyright 2024-2025 Lie Yan

public indirect enum ComponentSyntax: SyntaxProtocol {
  case char(CharSyntax)
  case commandChar(CommandCharSyntax)  // with no arguments
  case commandSeq(CommandSeqSyntax)  // with no arguments
  case escapedChar(EscapedCharSyntax)
  case group(GroupSyntax)

  public init(_ char: CharSyntax) { self = .char(char) }
  public init(_ commandChar: CommandCharSyntax) {
    precondition(commandChar.argument == nil)
    self = .commandChar(commandChar)
  }
  public init(_ commandSeq: CommandSeqSyntax) {
    precondition(commandSeq.arguments.isEmpty)
    self = .commandSeq(commandSeq)
  }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
}

extension ComponentSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .char(let charSyntax): charSyntax.deparse()
    case .commandChar(let commandCharSyntax): commandCharSyntax.deparse()
    case .commandSeq(let commandSeqSyntax): commandSeqSyntax.deparse()
    case .escapedChar(let escapedCharSyntax): escapedCharSyntax.deparse()
    case .group(let groupSyntax): groupSyntax.deparse()
    }
  }
}
