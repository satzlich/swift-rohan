public typealias EscapedCharSyntax = EscapedCharToken

extension EscapedCharSyntax: SyntaxProtocol {

  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    [self]
  }
}
