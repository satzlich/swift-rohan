// Copyright 2024-2025 Lie Yan

public struct CommandSeqSyntax: SyntaxProtocol {
  public let command: CommandSeqToken
  public let arguments: Array<AtomSyntax>
}
