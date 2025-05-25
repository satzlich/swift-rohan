// Copyright 2024-2025 Lie Yan

struct EscapedCharSyntax: Syntax {
  public var escapeChar: Character { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard EscapedCharSyntax.charSet.contains(char)
    else { return nil }
    self.char = char
  }

  internal static let charSet: Set<Character> =
    [
      "\\", "{", "}", "[", "]", "(", ")", "#", "$", "%", "&", "*",
    ]
}
