// Copyright 2024-2025 Lie Yan

public struct CharSyntax: SyntaxProtocol {
  public let char: Character
  public let mode: LayoutMode

  public init(_ char: Character, mode: LayoutMode) {
    self.char = char
    self.mode = mode
  }
}

extension CharSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    [TextToken(String(char), mode: mode)]
  }
}
