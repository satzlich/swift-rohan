public struct CharSyntax: SyntaxProtocol {
  public let char: Character
  public let mode: LayoutMode

  public init?(_ char: Character, mode: LayoutMode) {
    guard TextSyntax.validate(text: String(char), mode: mode)
    else { return nil }
    self.char = char
    self.mode = mode
  }
}

extension CharSyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    [TextToken(String(char), mode: mode)!]
  }
}
