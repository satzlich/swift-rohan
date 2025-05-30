// Copyright 2024-2025 Lie Yan

public func deparse(_ syntax: SyntaxProtocol) -> String {
  syntax.deparse().map { $0.untokenize() }.joined()
}

/// Wraps an array of tokens in a group, adding opening and closing braces.
internal func wrapInGroup(_ tokens: Array<any TokenProtocol>) -> Array<any TokenProtocol>
{
  [GroupBeginningToken.openBrace] + tokens + [GroupEndToken.closeBrace]
}
