// Copyright 2024-2025 Lie Yan

import Foundation

struct MathMatrix: Codable, MathDeclarationProtocol {
  let command: String
  let delimiters: DelimiterPair

  init(_ command: String, _ delimiters: DelimiterPair) {
    self.command = command
    self.delimiters = delimiters
  }
}

extension MathMatrix {
  static let predefinedCases: [MathMatrix] = [
    .matrix,
    .pmatrix,
    .bmatrix,
    .Bmatrix,
    .vmatrix,
    .Vmatrix,
  ]

  private static let _dictionary: [String: MathMatrix] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathMatrix? {
    _dictionary[command]
  }

  static let matrix = MathMatrix("matrix", DelimiterPair.NONE)
  static let pmatrix = MathMatrix("pmatrix", DelimiterPair.PAREN)
  static let bmatrix = MathMatrix("bmatrix", DelimiterPair.BRACKET)
  static let Bmatrix = MathMatrix("Bmatrix", DelimiterPair.BRACE)
  static let vmatrix = MathMatrix("vmatrix", DelimiterPair.VERT)
  static let Vmatrix = MathMatrix("Vmatrix", DelimiterPair.DOUBLE_VERT)
}
