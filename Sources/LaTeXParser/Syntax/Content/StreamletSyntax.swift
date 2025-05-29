// Copyright 2024-2025 Lie Yan

public enum StreamletSyntax: SyntaxProtocol {
  case arrayEnv(ArrayEnvSyntax)
  case attach(AttachSyntax)
  case controlChar(ControlCharSyntax)
  case controlSeq(ControlSeqSyntax)
  case environment(EnvironmentSyntax)
  case escapedChar(EscapedCharSyntax)
  case group(GroupSyntax)
  case math(MathSyntax)
  case newline(NewlineSyntax)
  case space(SpaceSyntax)
  case text(TextSyntax)

  public init(_ arrayEnv: ArrayEnvSyntax) { self = .arrayEnv(arrayEnv) }
  public init(_ attach: AttachSyntax) { self = .attach(attach) }
  public init(_ controlChar: ControlCharSyntax) { self = .controlChar(controlChar) }
  public init(_ controlSeq: ControlSeqSyntax) { self = .controlSeq(controlSeq) }
  public init(_ environment: EnvironmentSyntax) { self = .environment(environment) }
  public init(_ escapedChar: EscapedCharSyntax) { self = .escapedChar(escapedChar) }
  public init(_ group: GroupSyntax) { self = .group(group) }
  public init(_ math: MathSyntax) { self = .math(math) }
  public init(_ newline: NewlineSyntax) { self = .newline(newline) }
  public init(_ space: SpaceSyntax) { self = .space(space) }
  public init(_ text: TextSyntax) { self = .text(text) }

  var isAttach: Bool {
    if case .attach = self { return true }
    return false
  }
}

extension StreamletSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    switch self {
    case .arrayEnv(let arrayEnvSyntax): arrayEnvSyntax.deparse()
    case .attach(let attachSyntax): attachSyntax.deparse()
    case .controlChar(let controlCharSyntax): controlCharSyntax.deparse()
    case .controlSeq(let controlSeqSyntax): controlSeqSyntax.deparse()
    case .environment(let environmentSyntax): environmentSyntax.deparse()
    case .escapedChar(let escapedCharSyntax): escapedCharSyntax.deparse()
    case .group(let groupSyntax): groupSyntax.deparse()
    case .math(let mathSyntax): mathSyntax.deparse()
    case .newline(let newlineSyntax): newlineSyntax.deparse()
    case .space(let spaceSyntax): spaceSyntax.deparse()
    case .text(let textSyntax): textSyntax.deparse()
    }
  }

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse()

    case .properGroup:
      switch self {
      case .arrayEnv(let arrayEnvSyntax):
        return wrapInGroup(arrayEnvSyntax.deparse())

      case .attach(let attachSyntax):
        return wrapInGroup(attachSyntax.deparse())

      case .controlChar(let controlCharSyntax):
        return controlCharSyntax.deparse(.properGroup)

      case .controlSeq(let controlSeqSyntax):
        return controlSeqSyntax.deparse(.properGroup)

      case .environment(let environmentSyntax):
        return wrapInGroup(environmentSyntax.deparse())

      case .escapedChar(let escapedCharSyntax):
        return escapedCharSyntax.deparse()

      case .group(let groupSyntax):
        return groupSyntax.deparse(.properGroup)

      case .math(let mathSyntax):
        return wrapInGroup(mathSyntax.deparse())

      case .newline(let newlineSyntax):
        return wrapInGroup(newlineSyntax.deparse())

      case .space(let spaceSyntax):
        return wrapInGroup(spaceSyntax.deparse())

      case .text(let textSyntax):
        return textSyntax.deparse(.properGroup)
      }
    }
  }
}
