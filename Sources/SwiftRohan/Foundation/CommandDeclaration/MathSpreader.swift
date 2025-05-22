// Copyright 2024-2025 Lie Yan

import Foundation

struct MathSpreader: Codable, CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    case over
    case under
  }

  let subtype: Subtype
  let command: String
  let spreader: Character

  init(_ subtype: Subtype, _ command: String, _ spreader: Character) {
    self.subtype = subtype
    self.command = command
    self.spreader = spreader
  }

  static let predefinedCases: [MathSpreader] = underCases + overCases

  static let underCases: [MathSpreader] = [
    .underbrace,
    .underbracket,
    .underparen,
  ]

  static let overCases: [MathSpreader] = [
    .overbrace,
    .overbracket,
    .overparen,
  ]

  static let overbrace = MathSpreader(.over, "overbrace", "⏞")
  static let underbrace = MathSpreader(.under, "underbrace", "⏟")
  static let overbracket = MathSpreader(.over, "overbracket", "⎴")
  static let underbracket = MathSpreader(.under, "underbracket", "⎵")
  static let overparen = MathSpreader(.over, "overparen", "⏜")
  static let underparen = MathSpreader(.under, "underparen", "⏝")

  // internal commands
  static let _underleftarrow = MathSpreader(.under, "_underleftarrow", "\u{2190}")
  static let _underrightarrow = MathSpreader(.under, "_underrightarrow", "\u{2192}")
  static let _lowline = MathSpreader(.under, "_lowline", "\u{0332}")
  static let _overline = MathSpreader(.over, "_overline", "\u{0305}")

  private static let _dictionary: [String: MathSpreader] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathSpreader? {
    _dictionary[command]
  }
}
