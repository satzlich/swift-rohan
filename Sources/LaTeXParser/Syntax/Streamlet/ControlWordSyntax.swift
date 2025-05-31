// Copyright 2024-2025 Lie Yan

public struct ControlWordSyntax: SyntaxProtocol {
  public let command: ControlWordToken
  public let arguments: Array<ComponentSyntax>

  public init(command: ControlWordToken, arguments: Array<ComponentSyntax>) {
    self.command = command
    self.arguments = arguments
  }

  public init(command: ControlWordToken) {
    self.command = command
    self.arguments = []
  }
}

extension ControlWordSyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    tokens.append(command)
    var endsWithIdentifier = command.endsWithIdentifier

    for argument in arguments {
      let segment = argument.deparse(context)
      if let first = segment.first {
        if endsWithIdentifier && first.startsWithIdSpoiler {
          tokens.append(SpaceToken())
        }
        endsWithIdentifier = segment.last!.endsWithIdentifier
      }
      tokens.append(contentsOf: segment)
    }
    return tokens
  }

  public func deparse(
    _ preference: DeparsePreference, _ context: DeparseContext
  ) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse(context)
    case .properGroup:
      if context.registry.commandGenre(for: command) == .namedSymbol,
        arguments.isEmpty
      {
        return deparse(context)
      }
      else {
        return wrapInGroup(deparse(context))
      }
    }
  }
}

extension ControlWordSyntax {
  public static func unaryCall(
    command: ControlWordToken, argument: TextSyntax
  ) -> ControlWordSyntax {
    ControlWordSyntax(
      command: command,
      arguments: [
        ComponentSyntax(GroupSyntax(StreamSyntax([StreamletSyntax(argument)])))
      ])
  }
}
