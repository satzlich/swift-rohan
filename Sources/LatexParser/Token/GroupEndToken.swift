import Foundation

/// Close delimiter for a group.
public enum GroupEndToken: TokenProtocol {
  case closeBrace
  case closeBracket

  public var char: Character {
    switch self {
    case .closeBrace: return "}"
    case .closeBracket: return "]"
    }
  }

  public init?(_ char: Character) {
    switch char {
    case "}": self = .closeBrace
    case "]": self = .closeBracket
    default: return nil
    }
  }

  public func isPaired(with lhs: GroupBeginningToken) -> Bool {
    lhs.isPaired(with: self)
  }

  internal static func validate(char: Character) -> Bool {
    char == "}" || char == "]"
  }
}

extension GroupEndToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension GroupEndToken {
  public func untokenize() -> String {
    switch self {
    case .closeBrace: return "}"
    case .closeBracket: return "]"
    }
  }
}
