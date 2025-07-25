public struct ControlSymbolToken: TokenProtocol {
  public var escapeChar: Character { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard ControlSymbolToken.validate(char: char) else { return nil }
    self.char = char
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      string.count == 2,
      let char = string.last,
      ControlSymbolToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public static func validate(char: Character) -> Bool {
    NameToken.validate(string: String(char)) == false
  }
}

extension ControlSymbolToken {
  public static let space: ControlSymbolToken = ControlSymbolToken(char: " ")!
}

extension ControlSymbolToken {
  public var endsWithIdentifier: Bool { true }
  public var startsWithIdSpoiler: Bool { false }
}

extension ControlSymbolToken {
  public func untokenize() -> String {
    "\(escapeChar)\(char)"
  }
}
