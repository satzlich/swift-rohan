// Copyright 2024-2025 Lie Yan

import Foundation

/// Close delimiter for a group.
public struct CloseDelimiterToken: Token {
  public let char: Character

  public init?(char: Character) {
    guard CloseDelimiterToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public func isPaired(with lhs: OpenDelimiterToken) -> Bool {
    lhs.isPaired(with: self)
  }

  internal static func validate(char: Character) -> Bool {
    char == "}" || char == "]"
  }
}
