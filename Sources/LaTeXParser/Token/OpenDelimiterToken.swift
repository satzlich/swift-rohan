// Copyright 2024-2025 Lie Yan

import Foundation

/// Open delimiter for a group.
public struct OpenDelimiterToken: Token {
  public let char: Character

  public init?(char: Character) {
    guard OpenDelimiterToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public func isPaired(with rhs: CloseDelimiterToken) -> Bool {
    switch (self.char, rhs.char) {
    case ("{", "}"), ("[", "]"): return true
    default: return false
    }
  }

  internal static func validate(char: Character) -> Bool {
    char == "{" || char == "["
  }
}
