// Copyright 2024-2025 Lie Yan

public enum CommandArgumentSyntax: SyntaxProtocol {
  case char(CharSyntax)
  case group(GroupSyntax)
}
