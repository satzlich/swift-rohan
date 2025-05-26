// Copyright 2024-2025 Lie Yan

public enum StreamletSyntax: SyntaxProtocol {
  case commandChar(CommandCharSyntax)
  case commandSeq(CommandSeqSyntax)
  case environment(EnvironmentSyntax)
  case escapedChar(EscapedCharSyntax)
  case math(MathSyntax)
  case newline(NewlineSyntax)
  case space(SpaceSyntax)
  case text(TextSyntax)
}
