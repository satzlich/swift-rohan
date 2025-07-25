public protocol SyntaxProtocol {
  func deparse(_ context: DeparseContext) -> Array<TokenProtocol>
}
