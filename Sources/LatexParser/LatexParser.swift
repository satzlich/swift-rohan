public func deparse(_ syntax: SyntaxProtocol, _ context: DeparseContext) -> String {
  syntax.deparse(context).map { $0.untokenize() }.joined()
}

/// Wraps an array of tokens in a group, adding opening and closing braces.
internal func wrapInGroup(_ tokens: Array<any TokenProtocol>) -> Array<any TokenProtocol>
{
  [GroupBeginningToken.openBrace] + tokens + [GroupEndToken.closeBrace]
}
