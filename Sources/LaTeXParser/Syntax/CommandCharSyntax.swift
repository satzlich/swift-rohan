// Copyright 2024-2025 Lie Yan

public struct CommandCharSyntax: Syntax {
  public var prefix: String { "\\" }
  public let char: CharSyntax

  public init(char: CharSyntax) {
    self.char = char
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      let character = CharSyntax(string: string.dropFirst())
    else { return nil }
    self.char = character
  }
}
