// Copyright 2024-2025 Lie Yan

public struct ControlSeqSyntax: SyntaxProtocol {
  public let command: ControlSeqToken
  public let arguments: Array<ComponentSyntax>

  public init(command: ControlSeqToken, arguments: Array<ComponentSyntax>) {
    self.command = command
    self.arguments = arguments
  }

  public init(command: ControlSeqToken) {
    self.command = command
    self.arguments = []
  }
}

extension ControlSeqSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    tokens.append(command)
    var endsWithIdentifier = command.endsWithIdentifier

    for argument in arguments {
      let segment = argument.deparse()
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

  public func deparse(_ preference: DeparsePreference) -> Array<any TokenProtocol> {
    switch preference {
    case .unmodified:
      return deparse()
    case .properGroup:
      // TODO: if the command has no arguments, and corresponds to a symbol,
      //    we can return the command directly
      return wrapInGroup(deparse())
    }
  }
}

extension ControlSeqSyntax {
  public static func unaryCall(
    command: ControlSeqToken, argument: TextSyntax
  ) -> ControlSeqSyntax {
    ControlSeqSyntax(
      command: command,
      arguments: [
        ComponentSyntax(GroupSyntax(StreamSyntax([StreamletSyntax(argument)])))
      ])
  }
}
