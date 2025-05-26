// Copyright 2024-2025 Lie Yan

public struct EscapedCharToken: TokenProtocol {
  public var escapeChar: Character { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard EscapedCharToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public static func validate(char: Character) -> Bool {
    charSet.contains(char)
  }

  private static let charSet: Set<Character> =
    [
      "\\", "{", "}", "$", "&", "#", "^", "_", "%", "~",
    ]
}
