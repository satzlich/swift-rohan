// Copyright 2024-2025 Lie Yan

public struct CommandCharSyntax: Syntax {
  public var prefix: String { "\\" }
  public let char: Character

  public init?(char: Character) {
    guard CommandCharSyntax.validate(char: char) else { return nil }
    self.char = char
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      string.count == 2,
      let character = string.last
    else { return nil }
    self.char = character
  }

  public static func validate(char: Character) -> Bool {
    CommandNameSyntax.validate(string: String(char)) == false
  }
}
