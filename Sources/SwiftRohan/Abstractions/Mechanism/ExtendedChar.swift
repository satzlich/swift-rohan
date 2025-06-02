// Copyright 2024-2025 Lie Yan

enum ExtendedChar: Equatable, Hashable, Comparable {
  case char(Character)
  case symbol(NamedSymbol)

  static func < (lhs: ExtendedChar, rhs: ExtendedChar) -> Bool {
    switch (lhs, rhs) {
    case (.char(let l), .char(let r)):
      return l < r
    case (.symbol(let l), .symbol(let r)):
      return l < r
    case (.char, .symbol):
      return true
    case (.symbol, .char):
      return false
    }
  }
}

typealias ExtendedString = Array<ExtendedChar>

extension ExtendedString {
  init(_ string: String) {
    self = string.map { ExtendedChar.char($0) }
  }
}
