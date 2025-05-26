// Copyright 2024-2025 Lie Yan

public struct GroupSyntax: SyntaxProtocol {
  let begin: GroupBeginningToken
  let end: GroupEndToken
  let wrapped: ContentSyntax

  init?(begin: GroupBeginningToken, end: GroupEndToken, wrapped: ContentSyntax) {
    guard begin.isPaired(with: end) else { return nil }
    self.begin = begin
    self.end = end
    self.wrapped = wrapped
  }
}
