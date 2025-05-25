// Copyright 2024-2025 Lie Yan

public struct NewlineToken: Token {
  let char: Character

  public init(_ char: Character) {
    precondition(char.isNewline)
    self.char = char
  }
}
