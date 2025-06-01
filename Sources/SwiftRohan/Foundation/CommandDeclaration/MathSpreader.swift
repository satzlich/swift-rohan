// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

enum RelVerticalPosition: String, Codable {
  case over
  case under
}

struct MathSpreader: Codable, CommandDeclarationProtocol {
  typealias Subtype = RelVerticalPosition

  let subtype: Subtype
  let command: String
  var tag: CommandTag { .other }
  var source: CommandSource { .preBuilt }
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
    //
    underline,
  ]

  static let overCases: [MathSpreader] = [
    overbrace,
    overbracket,
    overparen,
    //
    overline,
  ]

  //
  static let overbrace = MathSpreader(.over, "overbrace", "⏞")
  static let overbracket = MathSpreader(.over, "overbracket", "⎴")
  static let overparen = MathSpreader(.over, "overparen", "⏜")
  static let overline = MathSpreader(.over, "overline", "\u{0000}")
  //
  static let underbrace = MathSpreader(.under, "underbrace", "⏟")
  static let underbracket = MathSpreader(.under, "underbracket", "⎵")
  static let underparen = MathSpreader(.under, "underparen", "⏝")
  static let underline = MathSpreader(.under, "underline", "\u{0000}")

  // internal commands for implementation purpose. There are accent commands
  // named `underleftarrow` and `underrightarrow`
  static let _underleftarrow = MathSpreader(.under, "_underleftarrow", "\u{2190}")
  static let _underrightarrow = MathSpreader(.under, "_underrightarrow", "\u{2192}")

  private static let _dictionary: [String: MathSpreader] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathSpreader? {
    _dictionary[command]
  }
}
