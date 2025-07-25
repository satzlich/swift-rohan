public struct NewlineToken: TokenProtocol {
  let char: Character

  public init(_ char: Character = "\n") {
    precondition(char.charCategory == .endOfLine)
    self.char = char
  }
}

extension NewlineToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension NewlineToken {
  public func untokenize() -> String {
    "\(char)"
  }
}
