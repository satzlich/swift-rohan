// Copyright 2024-2025 Lie Yan

import Foundation

struct MathSpreader: Codable, MathDeclarationProtocol {
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

  private static let _dictionary: [String: MathSpreader] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathSpreader? {
    _dictionary[command]
  }
}
