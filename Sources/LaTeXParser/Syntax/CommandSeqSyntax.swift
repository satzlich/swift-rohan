// Copyright 2024-2025 Lie Yan

public struct CommandSeqSyntax: SyntaxProtocol {
  public let command: CommandSeqToken
  public let arguments: Array<AtomSyntax>

  public init(command: CommandSeqToken, arguments: Array<AtomSyntax>) {
    self.command = command
    self.arguments = arguments
  }
}
