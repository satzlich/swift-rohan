// Copyright 2024-2025 Lie Yan

public struct CharSyntax: SyntaxProtocol {
  public let char: Character

  public init(char: Character) {
    self.char = char
  }

  public init?(_ string: String) {
    guard string.count == 1,
      let char = string.first
    else { return nil }
    self.char = char
  }
}
