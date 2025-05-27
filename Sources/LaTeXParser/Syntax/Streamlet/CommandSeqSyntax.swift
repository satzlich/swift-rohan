// Copyright 2024-2025 Lie Yan

public struct CommandSeqSyntax: SyntaxProtocol {
  public let command: CommandSeqToken
  public let arguments: Array<ComponentSyntax>

  public init(command: CommandSeqToken, arguments: Array<ComponentSyntax>) {
    self.command = command
    self.arguments = arguments
  }
}

extension CommandSeqSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    var tokens: Array<any TokenProtocol> = []

    tokens.append(command)
    var endsWithIdentifier = command.endsWithIdentifier

    for argument in arguments {
      let segment = argument.deparse()
      if let first = segment.first {
        if endsWithIdentifier && first.startsWithIdentifierUnsafe {
          tokens.append(SpaceToken())
        }
        endsWithIdentifier = segment.last!.endsWithIdentifier
      }
      tokens.append(contentsOf: segment)
    }
    return tokens
  }
}

extension CommandSeqSyntax {
  public static func unaryCall(
    command: CommandSeqToken, argument: TextSyntax
  ) -> CommandSeqSyntax {
    CommandSeqSyntax(
      command: command,
      arguments: [
        ComponentSyntax(
          GroupSyntax(StreamSyntax([StreamletSyntax(argument)])))
      ])
  }
}
