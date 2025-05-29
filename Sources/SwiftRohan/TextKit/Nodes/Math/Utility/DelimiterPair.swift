// Copyright 2024-2025 Lie Yan

import Foundation
import LaTeXParser
import UnicodeMathClass

/// A pair of delimiters (one closing, one opening) used for matrices, vectors
/// and cases.
struct DelimiterPair: Codable {
  let open: Delimiter
  let close: Delimiter

  init(_ open: Delimiter, _ close: Delimiter) {
    self.open = open
    self.close = close
  }

  init?(_ open: NamedSymbol, _ close: NamedSymbol) {
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
  static let NONE = DelimiterPair(Delimiter.null, Delimiter.null)
  static let LBRACE = DelimiterPair(Delimiter("{")!, Delimiter.null)
  static let PAREN = DelimiterPair("(", ")")!
  static let BRACE = DelimiterPair("{", "}")!
  static let BRACKET = DelimiterPair("[", "]")!
  static let VERT = DelimiterPair(Delimiter.lvert, Delimiter.rvert)
  static let DOUBLE_VERT = DelimiterPair(Delimiter.lVert, Delimiter.rVert)
}
