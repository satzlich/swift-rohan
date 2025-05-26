// Copyright 2024-2025 Lie Yan

public indirect enum AtomSyntax: SyntaxProtocol {
  case char(CharSyntax)
  case commandChar(CommandCharSyntax)  // with no arguments
  case commandSeq(CommandSeqSyntax)  // with no arguments
  case group(GroupSyntax)
}
