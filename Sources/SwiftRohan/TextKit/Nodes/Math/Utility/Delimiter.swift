// Copyright 2024-2025 Lie Yan

import Foundation
import LaTeXParser
import UnicodeMathClass

enum Delimiter: Codable {
  case char(Character)
  case symbol(NamedSymbol)
  case null

  var value: Optional<Character> {
    switch self {
    case .char(let character): character
    case .symbol(let mathSymbol): mathSymbol.string.getOnlyElement()
    case .null: nil
    }
  }

  init() { self = .null }

  init?(_ char: Character) {
    guard Delimiter.validate(char) else { return nil }
    self = .char(char)
  }

  init?(_ symbol: NamedSymbol) {
    guard let char = symbol.string.getOnlyElement(),
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
    case .null:
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
        return NamedSymbol.lookup(str).flatMap { Delimiter($0) }
      }
    case .null:
      return Delimiter()
    default:
      return nil
    }
  }

  static let lvert: Delimiter = .symbol(NamedSymbol.lookup("lvert")!)
  static let rvert: Delimiter = .symbol(NamedSymbol.lookup("rvert")!)
  static let lVert: Delimiter = .symbol(NamedSymbol.lookup("lVert")!)
  static let rVert: Delimiter = .symbol(NamedSymbol.lookup("rVert")!)
}

extension Delimiter {
  /// Converts the delimiter to a `ComponentSyntax`.
  func getComponentSyntax() -> SatzResult<ComponentSyntax> {
    switch self {
    case .char(let char):
      let syntax =
        EscapedCharSyntax.isEscapeable(char)
        ? ComponentSyntax(EscapedCharSyntax(char: char)!)
        : ComponentSyntax(CharSyntax(char, mode: .mathMode))
      return .success(syntax)
    case .null:
      return .success(ComponentSyntax(CharSyntax(".", mode: .mathMode)))
    case .symbol(let name):
      guard let nameToken = NameToken(name.command)
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      let controlSeq = ControlSeqToken(name: nameToken)
      return .success(ComponentSyntax(ControlSeqSyntax(command: controlSeq)))
    }
  }
}
