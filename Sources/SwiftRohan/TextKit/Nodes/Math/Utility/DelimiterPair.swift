// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

enum Delimiter: Codable {
  case char(Character)
  case symbol(MathSymbol)
  case empty

  var value: Optional<Character> {
    switch self {
    case .char(let character): character
    case .symbol(let mathSymbol): mathSymbol.symbol.getOnlyElement()
    case .empty: nil
    }
  }

  init() { self = .empty }

  init?(_ char: Character) {
    guard Delimiter.validate(char) else { return nil }
    self = .char(char)
  }

  init?(_ symbol: MathSymbol) {
    guard let char = symbol.symbol.getOnlyElement(),
      Delimiter.validate(char)
    else { return nil }
    self = .symbol(symbol)
  }

  /// Returns the matching delimiter for the current one.
  func matchingDelimiter() -> Delimiter? {
    switch value {
    case .none: return nil
    case .some("["): return Delimiter("]")
    case .some("]"): return Delimiter("[")
    case .some("{"): return Delimiter("}")
    case .some("}"): return Delimiter("{")
    case .some(let char):
      let unicodeScalar = char.unicodeScalars.first!
      switch unicodeScalar.mathClass {
      case .Opening:
        let value = unicodeScalar.value + 1
        return Delimiter(Character(UnicodeScalar(value)!))
      case .Closing:
        let value = unicodeScalar.value - 1
        return Delimiter(Character(UnicodeScalar(value)!))
      default:
        return self
      }
    }
  }

  static func validate(_ character: Character) -> Bool {
    let clazz = character.unicodeScalars.first!.mathClass
    return [.Opening, .Closing, .Fence].contains(clazz)
  }

  func store() -> JSONValue {
    switch self {
    case .char(let char):
      return JSONValue.string(String(char))
    case .symbol(let symbol):
      return JSONValue.string(symbol.command)
    case .empty:
      return JSONValue.null
    }
  }

  /// Load a delimiter from JSON. The JSON can be either a string or null.
  /// - Returns: An `Either` with the delimiter or an error.
  static func load(from json: JSONValue) -> Optional<Delimiter> {
    switch json {
    case .string(let str):
      if str.count == 1 {
        let char = str.first!
        return Delimiter(char)
      }
      else {
        return MathSymbol.lookup(str).flatMap { Delimiter($0) }
      }
    case .null:
      return Delimiter()
    default:
      return nil
    }
  }
}

/// A pair of delimiters (one closing, one opening) used for matrices, vectors
/// and cases.
struct DelimiterPair: Codable {
  let open: Delimiter
  let close: Delimiter

  init(_ open: Delimiter, _ close: Delimiter) {
    self.open = open
    self.close = close
  }

  init?(_ open: MathSymbol, _ close: MathSymbol) {
    guard let open = Delimiter(open),
      let close = Delimiter(close)
    else { return nil }

    self.open = open
    self.close = close
  }

  init?(_ open: Character, _ close: Character) {
    guard let open = Delimiter(open),
      let close = Delimiter(close)
    else { return nil }

    self.open = open
    self.close = close
  }

  func store() -> JSONValue {
    let open = open.store()
    let close = close.store()
    return JSONValue.array([open, close])
  }

  static func load(from json: JSONValue) -> Optional<DelimiterPair> {
    guard case .array(let array) = json,
      array.count == 2,
      let open = Delimiter.load(from: array[0]),
      let close = Delimiter.load(from: array[1])
    else { return nil }
    return DelimiterPair(open, close)
  }
}

extension DelimiterPair {
  static let NONE = DelimiterPair(Delimiter(), Delimiter())
  static let LBRACE = DelimiterPair(Delimiter("{")!, Delimiter())
  static let PAREN = DelimiterPair("(", ")")!
  static let BRACE = DelimiterPair("{", "}")!
  static let BRACKET = DelimiterPair("[", "]")!
  static let VERT = DelimiterPair("|", "|")!
  static let DOUBLE_VERT = DelimiterPair("\u{2016}", "\u{2016}")!
}
