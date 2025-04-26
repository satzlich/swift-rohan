// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

struct Delimiter: Codable {
  let value: Optional<Character>

  init() { value = nil }

  init?(_ char: Character) {
    guard Delimiter.validate(char) else { return nil }
    self.value = char
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)

    if string.count == 1, let char = string.first {
      self.value = char
    }
    else {
      assert(string.isEmpty)
      self.value = nil
    }
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    if let value = value {
      try container.encode(String(value))
    }
    else {
      try container.encode("")
    }
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

  init?(_ open: Character, _ close: Character) {
    guard let open = Delimiter(open),
      let close = Delimiter(close)
    else { return nil }

    self.open = open
    self.close = close
  }
}

extension DelimiterPair {
  static let PAREN = DelimiterPair("(", ")")!
  static let BRACE = DelimiterPair("{", "}")!
  static let BRACKET = DelimiterPair("[", "]")!
  static let VERT = DelimiterPair("|", "|")!
  static let DOUBLE_VERT = DelimiterPair("\u{2016}", "\u{2016}")!
}
