public enum StreamletSyntax: SyntaxProtocol {
  case arrayEnv(ArrayEnvSyntax)
  case attach(AttachSyntax)
  case controlSymbol(ControlSymbolSyntax)
  case controlWord(ControlWordSyntax)
  case environment(EnvironmentSyntax)
  case escapedChar(EscapedCharSyntax)
  case group(GroupSyntax)
  case math(MathSyntax)
  case newline(NewlineSyntax)
  case space(SpaceSyntax)
  case text(TextSyntax)

  public init(_ arrayEnv: ArrayEnvSyntax) { self = .arrayEnv(arrayEnv) }
  public init(_ attach: AttachSyntax) { self = .attach(attach) }

  public init(_ controlSymbol: ControlSymbolSyntax) {
    self = .controlSymbol(controlSymbol)
  }

  public init(_ controlWord: ControlWordSyntax) { self = .controlWord(controlWord) }
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
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    switch self {
    case .arrayEnv(let arrayEnvSyntax): arrayEnvSyntax.deparse(context)
    case .attach(let attachSyntax): attachSyntax.deparse(context)
    case .controlSymbol(let controlSymbolSyntax): controlSymbolSyntax.deparse(context)
    case .controlWord(let controlWordSyntax): controlWordSyntax.deparse(context)
    case .environment(let environmentSyntax): environmentSyntax.deparse(context)
    case .escapedChar(let escapedCharSyntax): escapedCharSyntax.deparse(context)
    case .group(let groupSyntax): groupSyntax.deparse(context)
    case .math(let mathSyntax): mathSyntax.deparse(context)
    case .newline(let newlineSyntax): newlineSyntax.deparse(context)
    case .space(let spaceSyntax): spaceSyntax.deparse(context)
    case .text(let textSyntax): textSyntax.deparse(context)
    }
  }

  internal func deparse(
    _ preference: DeparsePreference, _ context: DeparseContext
  ) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse(context)

    case .minGroup, .wrapNonSymbol:
      switch self {
      case .arrayEnv(let arrayEnvSyntax):
        return wrapInGroup(arrayEnvSyntax.deparse(context))

      case .attach(let attachSyntax):
        return wrapInGroup(attachSyntax.deparse(context))

      case .controlSymbol(let controlSymbolSyntax):
        return controlSymbolSyntax.deparse(.minGroup, context)

      case .controlWord(let controlWordSyntax):
        return controlWordSyntax.deparse(preference, context)

      case .environment(let environmentSyntax):
        return wrapInGroup(environmentSyntax.deparse(context))

      case .escapedChar(let escapedCharSyntax):
        return escapedCharSyntax.deparse(context)

      case .group(let groupSyntax):
        return groupSyntax.deparse(preference, context)

      case .math(let mathSyntax):
        return wrapInGroup(mathSyntax.deparse(context))

      case .newline(let newlineSyntax):
        return wrapInGroup(newlineSyntax.deparse(context))

      case .space(let spaceSyntax):
        return wrapInGroup(spaceSyntax.deparse(context))

      case .text(let textSyntax):
        return textSyntax.deparse(.minGroup, context)
      }
    }
  }
}
