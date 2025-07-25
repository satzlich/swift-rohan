enum ExtendedChar: Equatable, Hashable, Comparable {
  case char(Character)
  case symbol(NamedSymbol)

  @inlinable @inline(__always)
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

  func preview() -> String {
    switch self {
    case let .char(c): return String(c)
    case let .symbol(symbol): return symbol.string
    }
  }
}

extension ExtendedChar {
  func toDelimiter() -> Optional<Delimiter> {
    switch self {
    case let .char(c): return Delimiter(c)
    case let .symbol(symbol): return Delimiter(symbol)
    }
  }
}

typealias ExtendedString = Array<ExtendedChar>
typealias ExtendedSubstring = ArraySlice<ExtendedChar>

extension ExtendedString {
  init(_ string: String) {
    self = string.map { ExtendedChar.char($0) }
  }
}
