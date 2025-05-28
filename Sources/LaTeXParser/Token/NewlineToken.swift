// Copyright 2024-2025 Lie Yan

public struct NewlineToken: TokenProtocol {
  let char: Character

  public init(_ char: Character = "\n") {
    precondition(char.charCategory == .endOfLine)
    self.char = char
  }
}

extension NewlineToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdentifierUnsafe: Bool { false }
}

extension NewlineToken {
  public func deparse() -> String {
    "\(char)"
  }
}
