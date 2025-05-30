// Copyright 2024-2025 Lie Yan

public struct ControlSymbolSyntax: SyntaxProtocol {
  public let command: ControlSymbolToken
  public let argument: Optional<ComponentSyntax>

  public init(command: ControlSymbolToken, argument: Optional<ComponentSyntax> = nil) {
    self.command = command
    self.argument = argument
  }
}

extension ControlSymbolSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []
    tokens.append(command)
    if let argument = argument {
      let segment = argument.deparse()
      if let first = segment.first,
        command.endsWithIdentifier,
        first.startsWithIdSpoiler
      {
        tokens.append(SpaceToken())
      }
      tokens.append(contentsOf: segment)
    }
    return tokens
  }

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      deparse()
    case .properGroup:
      argument == nil ? deparse() : wrapInGroup(deparse())
    }
  }
}
