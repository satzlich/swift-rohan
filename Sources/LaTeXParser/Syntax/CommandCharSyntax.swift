// Copyright 2024-2025 Lie Yan

public struct CommandCharSyntax: SyntaxProtocol {
  public let command: CommandCharToken
  public let argument: Optional<AtomSyntax>
}
