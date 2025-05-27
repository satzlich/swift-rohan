// Copyright 2024-2025 Lie Yan

public struct CommandCharSyntax: SyntaxProtocol {
  public let command: CommandCharToken
  public let argument: Optional<ComponentSyntax>
}

extension CommandCharSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: [any TokenProtocol] = []
    tokens.append(command)
    if let argument = argument {
      let segment = argument.deparse()
      if let first = segment.first,
        command.endsWithIdentifier,
        first.startsWithIdentifierUnsafe
      {
        tokens.append(SpaceToken())
      }
      tokens.append(contentsOf: segment)
    }
    return tokens
  }
}
