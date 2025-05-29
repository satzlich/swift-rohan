// Copyright 2024-2025 Lie Yan

import Foundation

enum RelVerticalPosition: String, Codable {
  case over
  case under
}

struct MathSpreader: Codable, CommandDeclarationProtocol {
  typealias Subtype = RelVerticalPosition

  let subtype: Subtype
  let command: String
  let spreader: Character

  /// For spreader = "\u{0000}", the command degenerate to a over/under-line.
  init(_ subtype: Subtype, _ command: String, _ spreader: Character) {
    self.subtype = subtype
    self.command = command
    self.spreader = spreader
  }

  static let allCommands: [MathSpreader] = underCases + overCases

  static let underCases: [MathSpreader] = [
    underbrace,
    underbracket,
    underparen,
  ]

  static let overCases: [MathSpreader] = [
    overbrace,
    overbracket,
    overparen,
  ]

  static let overbrace = MathSpreader(.over, "overbrace", "⏞")
  static let underbrace = MathSpreader(.under, "underbrace", "⏟")
  static let overbracket = MathSpreader(.over, "overbracket", "⎴")
  static let underbracket = MathSpreader(.under, "underbracket", "⎵")
  static let overparen = MathSpreader(.over, "overparen", "⏜")
  static let underparen = MathSpreader(.under, "underparen", "⏝")

  // internal commands (should not exported)
  static let _underleftarrow = MathSpreader(.under, "_underleftarrow", "\u{2190}")
  static let _underrightarrow = MathSpreader(.under, "_underrightarrow", "\u{2192}")
  static let _underline = MathSpreader(.under, "_underline", "\u{0000}")
  static let _overline = MathSpreader(.over, "_overline", "\u{0000}")

  private static let _dictionary: [String: MathSpreader] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathSpreader? {
    _dictionary[command]
  }
}
