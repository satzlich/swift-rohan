// Copyright 2024-2025 Lie Yan

import Foundation

public struct GroupDelimiterSyntax: Syntax {
  public let char: Character

  public init?(char: Character) {
    guard GroupDelimiterSyntax.charSet.contains(char)
    else { return nil }
    self.char = char
  }

  public var isLeft: Bool {
    return char == "{" || char == "["
  }

  public var isRight: Bool {
    return char == "}" || char == "]"
  }

  public func isPaired(with rhs: GroupDelimiterSyntax) -> Bool {
    return (self.char == "{" && rhs.char == "}")
      || (self.char == "[" && rhs.char == "]")
  }

  internal static let charSet: Set<Character> =
    [
      "{", "}", "[", "]",
    ]
}
