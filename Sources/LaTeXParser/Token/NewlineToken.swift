// Copyright 2024-2025 Lie Yan

public struct NewlineToken: TokenProtocol {
  let char: Character

  public init(_ char: Character) {
    precondition(char.charCategory == .endOfLine)
    self.char = char
  }
}
