// Copyright 2024-2025 Lie Yan

import Foundation

struct MathArray: Codable, MathDeclarationProtocol {
  enum Subtype: String, Codable {
    case align
    case cases
    case matrix
  }

  let command: String
  let subtype: Subtype
  let delimiters: DelimiterPair

  init(_ command: String, _ subtype: Subtype, _ delimiters: DelimiterPair) {
    self.command = command
    self.subtype = subtype
    self.delimiters = delimiters
  }
}

extension MathArray {
  static let predefinedCases: [MathArray] = [
    .aligned,
    .cases,
    .matrix,
    .pmatrix,
    .bmatrix,
    .Bmatrix,
    .vmatrix,
    .Vmatrix,
  ]

  private static let _dictionary: [String: MathArray] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathArray? {
    _dictionary[command]
  }

  static let aligned = MathArray("aligned", .align, DelimiterPair.NONE)
  static let cases = MathArray("cases", .cases, DelimiterPair.LBRACE)
  //
  static let matrix = MathArray("matrix", .matrix, DelimiterPair.NONE)
  static let pmatrix = MathArray("pmatrix", .matrix, DelimiterPair.PAREN)
  static let bmatrix = MathArray("bmatrix", .matrix, DelimiterPair.BRACKET)
  static let Bmatrix = MathArray("Bmatrix", .matrix, DelimiterPair.BRACE)
  static let vmatrix = MathArray("vmatrix", .matrix, DelimiterPair.VERT)
  static let Vmatrix = MathArray("Vmatrix", .matrix, DelimiterPair.DOUBLE_VERT)
}
