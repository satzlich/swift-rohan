// Copyright 2024-2025 Lie Yan

public struct MathShiftToken: TokenProtocol {
  public enum Subtype {
    case inline
    case display
  }

  public let string: String

  public init(_ string: String) {
    self.string = string
  }

  public static func validate(string: String) -> Bool {
    ["$", "$$", "\\[", "\\]"].contains(string)
  }
}

extension MathShiftToken {
  func isPaired(with rhs: MathShiftToken) -> Bool {
    switch (self.string, rhs.string) {
    case ("$", "$"), ("$$", "$$"), ("\\[", "\\]"):
      return true
    default:
      return false
    }
  }

  var subtype: Subtype {
    switch string {
    case "$":
      return .inline
    case "$$", "\\[", "\\]":
      return .display
    case _:
      preconditionFailure("Invalid MathShiftToken: \(string)")
    }
  }
}
