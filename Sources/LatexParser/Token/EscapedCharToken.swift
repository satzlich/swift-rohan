public struct EscapedCharToken: TokenProtocol {
  public var escapeChar: Character { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard EscapedCharToken.isEscapeable(char)
    else { return nil }
    self.char = char
  }

  public static func isEscapeable(_ char: Character) -> Bool {
    charSet.contains(char)
  }

  private static let charSet: Set<Character> =
    [
      "\\", "{", "}", "$", "&", "#", "^", "_", "%", "~",
    ]
}

extension EscapedCharToken {
  public static let backslash = EscapedCharToken(char: "\\")!
}

extension EscapedCharToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension EscapedCharToken {
  public func untokenize() -> String {
    "\(escapeChar)\(char)"
  }
}
