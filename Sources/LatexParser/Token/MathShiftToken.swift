// Copyright 2024-2025 Lie Yan

public enum MathShiftToken: TokenProtocol {
  case dollar
  case ddollar
  case lbracket
  case rbracket

  public var string: String {
    switch self {
    case .dollar: "$"
    case .ddollar: "$$"
    case .lbracket: "\\["
    case .rbracket: "\\]"
    }
  }

  public init?(_ string: String) {
    switch string {
    case "$":
      self = .dollar
    case "$$":
      self = .ddollar
    case "\\[":
      self = .lbracket
    case "\\]":
      self = .rbracket
    default:
      return nil
    }
  }

  public static func validate(string: String) -> Bool {
    ["$", "$$", "\\[", "\\]"].contains(string)
  }
}

extension MathShiftToken {
  public func isPaired(with rhs: MathShiftToken) -> Bool {
    switch (self, rhs) {
    case (.dollar, .dollar), (.ddollar, .ddollar):
      return true
    case (.lbracket, .rbracket):
      return true
    default:
      return false
    }
  }
}

extension MathShiftToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension MathShiftToken {
  public func untokenize() -> String {
    switch self {
    case .dollar: return "$"
    case .ddollar: return "$$"
    case .lbracket: return "\\["
    case .rbracket: return "\\]"
    }
  }
}
