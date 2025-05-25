// Copyright 2024-2025 Lie Yan

/// Content group delimited by left and right delimiters (usually paired braces
/// or brackets).
public struct GroupSyntax: Syntax {
  let leftDelimiter: GroupDelimiterSyntax
  let rightDelimiter: GroupDelimiterSyntax
  let content: ContentSyntax

  init?(
    leftDelimiter: GroupDelimiterSyntax,
    rightDelimiter: GroupDelimiterSyntax,
    content: ContentSyntax
  ) {
    guard leftDelimiter.isPaired(with: rightDelimiter) else { return nil }
    self.leftDelimiter = leftDelimiter
    self.rightDelimiter = rightDelimiter
    self.content = content
  }
}
