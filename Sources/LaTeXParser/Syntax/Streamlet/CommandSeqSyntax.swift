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
    var tokens: Array<any TokenProtocol> = [command]
    tokens.append(command)
    for (i, argument) in arguments.enumerated() {
      if i == 0 && !argument.hasOpenDelimiter {
        tokens.append(SpaceToken())
      }
      else if i > 0,
        !arguments[i - 1].hasCloseDelimiter,
        !argument.hasOpenDelimiter
      {
        tokens.append(SpaceToken())
      }
      tokens.append(contentsOf: argument.deparse())
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
