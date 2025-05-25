// Copyright 2024-2025 Lie Yan

/// Content group delimited by left and right delimiters (usually paired braces
/// or brackets).
public struct GroupSyntax: Syntax {
  let openDelimiter: OpenDelimiterToken
  let closeDelimiter: CloseDelimiterToken
  let content: ContentSyntax

  init?(
    openDelimiter: OpenDelimiterToken, closeDelimiter: CloseDelimiterToken,
    content: ContentSyntax
  ) {
    guard openDelimiter.isPaired(with: closeDelimiter) else { return nil }
    self.openDelimiter = openDelimiter
    self.closeDelimiter = closeDelimiter
    self.content = content
  }
}
