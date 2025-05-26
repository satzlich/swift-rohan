// Copyright 2024-2025 Lie Yan

import Foundation

/// Open delimiter for a group.
public struct GroupBeginningToken: TokenProtocol {
  public let char: Character

  public init?(_ char: Character) {
    guard GroupBeginningToken.validate(char: char)
    else { return nil }
    self.char = char
  }

  public func isPaired(with rhs: GroupEndToken) -> Bool {
    switch (self.char, rhs.char) {
    case ("{", "}"), ("[", "]"): return true
    default: return false
    }
  }

  internal static func validate(char: Character) -> Bool {
    char == "{" || char == "["
  }
}

extension GroupBeginningToken {
  static let lbrace: GroupBeginningToken = GroupBeginningToken("{")!
  static let lbracket: GroupBeginningToken = GroupBeginningToken("[")!
}
