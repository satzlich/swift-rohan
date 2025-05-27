// Copyright 2024-2025 Lie Yan

public enum StreamletSyntax: SyntaxProtocol {
  case arrayEnv(ArrayEnvSyntax)
  case attach(AttachSyntax)
  case commandChar(CommandCharSyntax)
  case commandSeq(CommandSeqSyntax)
  case environment(EnvironmentSyntax)
  case escapedChar(EscapedCharSyntax)
  case group(GroupSyntax)
  case math(MathSyntax)
  case newline(NewlineSyntax)
  case space(SpaceSyntax)
  case text(TextSyntax)

  public init(_ arrayEnv: ArrayEnvSyntax) { self = .arrayEnv(arrayEnv) }
  public init(_ attach: AttachSyntax) { self = .attach(attach) }
  public init(_ commandChar: CommandCharSyntax) { self = .commandChar(commandChar) }
  public init(_ commandSeq: CommandSeqSyntax) { self = .commandSeq(commandSeq) }
  public init(_ environment: EnvironmentSyntax) { self = .environment(environment) }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
  public init(_ math: MathSyntax) { self = .math(math) }
  public init(_ newline: NewlineSyntax) { self = .newline(newline) }
  public init(_ space: SpaceSyntax) { self = .space(space) }
  public init(_ text: TextSyntax) { self = .text(text) }
}

extension StreamletSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .arrayEnv(let arrayEnvSyntax): arrayEnvSyntax.deparse()
    case .attach(let attachSyntax): attachSyntax.deparse()
    case .commandChar(let commandCharSyntax): commandCharSyntax.deparse()
    case .commandSeq(let commandSeqSyntax): commandSeqSyntax.deparse()
    case .environment(let environmentSyntax): environmentSyntax.deparse()
    case .escapedChar(let escapedCharSyntax): escapedCharSyntax.deparse()
    case .group(let groupSyntax): groupSyntax.deparse()
    case .math(let mathSyntax): mathSyntax.deparse()
    case .newline(let newlineSyntax): newlineSyntax.deparse()
    case .space(let spaceSyntax): spaceSyntax.deparse()
    case .text(let textSyntax): textSyntax.deparse()
    }
  }
}
