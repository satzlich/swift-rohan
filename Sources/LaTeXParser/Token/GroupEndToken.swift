// Copyright 2024-2025 Lie Yan

import Foundation

/// Close delimiter for a group.
public struct GroupEndToken: TokenProtocol {
  public let char: Character

  public init?(_ char: Character) {
    guard GroupEndToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public func isPaired(with lhs: GroupBeginningToken) -> Bool {
    lhs.isPaired(with: self)
  }

  internal static func validate(char: Character) -> Bool {
    char == "}" || char == "]"
  }
}
