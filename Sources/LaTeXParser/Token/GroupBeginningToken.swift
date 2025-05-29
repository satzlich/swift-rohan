// Copyright 2024-2025 Lie Yan

import Foundation

/// Open delimiter for a group.
public enum GroupBeginningToken: TokenProtocol {
  case openBrace
  case openBracket

  public var char: Character {
    switch self {
    case .openBrace: return "{"
    case .openBracket: return "["
    }
  }

  public init?(_ char: Character) {
    switch char {
    case "{": self = .openBrace
    case "[": self = .openBracket
    default: return nil
    }
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
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension GroupBeginningToken {
  public func untokenize() -> String {
    switch self {
    case .openBrace: return "{"
    case .openBracket: return "["
    }
  }
}
