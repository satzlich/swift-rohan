// Copyright 2024-2025 Lie Yan

public struct CommandCharToken: TokenProtocol {
  public var escapeChar: Character { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard CommandCharToken.validate(char: char) else { return nil }
    self.char = char
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      string.count == 2,
      let char = string.last
    else { return nil }
    self.char = char
  }

  public static func validate(char: Character) -> Bool {
    NameToken.validate(string: String(char)) == false
  }
}

extension CommandCharToken {
  public var endsWithIdentifier: Bool { true }
  public var startsWithIdentifierUnsafe: Bool { false }
}

extension CommandCharToken {
  public func deparse() -> String {
    "\(escapeChar)\(char)"
  }
}
