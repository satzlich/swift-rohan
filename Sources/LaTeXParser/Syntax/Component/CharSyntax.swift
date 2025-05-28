// Copyright 2024-2025 Lie Yan

public struct CharSyntax: SyntaxProtocol {
  public let char: Character

  public init(_ char: Character) {
    self.char = char
  }
}

extension CharSyntax {
  public func deparse() -> Array<any TokenProtocol> {
    [TextToken(String(char))]
  }
}
