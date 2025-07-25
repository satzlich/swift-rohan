public typealias NewlineSyntax = NewlineToken

extension NewlineSyntax: SyntaxProtocol {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    return [self]
  }
}
