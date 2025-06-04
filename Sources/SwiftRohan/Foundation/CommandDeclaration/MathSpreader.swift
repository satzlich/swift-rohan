// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathSpreader: Codable, CommandDeclarationProtocol {
  enum Subtype: Codable {
    case overline
    case overspreader(Character)
    case underline
    case underspreader(Character)
    /// Example: `\xleftarrow` and `\xrightarrow`
    case xarrow(Character)
  }

  let subtype: Subtype
  let command: String
  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }

  init(_ subtype: Subtype, _ command: String) {
    self.subtype = subtype
    self.command = command
  }

  static let allCommands: [MathSpreader] =
    [
      //
      underline,
      //
      underbrace,
      underbracket,
      underparen,
      //
      overline,
      //
      overbrace,
      overbracket,
      overparen,
      //
      xleftarrow,
      xrightarrow,
    ]

  private static let _dictionary: [String: MathSpreader] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathSpreader? {
    _dictionary[command]
  }

  //
  static let overbrace = MathSpreader(.overspreader("⏞"), "overbrace")
  static let overbracket = MathSpreader(.overspreader("⎴"), "overbracket")
  static let overparen = MathSpreader(.overspreader("⏜"), "overparen")
  static let overline = MathSpreader(.overline, "overline")
  //
  static let underbrace = MathSpreader(.underspreader("⏟"), "underbrace")
  static let underbracket = MathSpreader(.underspreader("⎵"), "underbracket")
  static let underparen = MathSpreader(.underspreader("⏝"), "underparen")
  static let underline = MathSpreader(.underline, "underline")

  // internal commands for implementation purpose. There are accent commands
  // named `underleftarrow` and `underrightarrow`
  static let _underleftarrow = MathSpreader(.underspreader("\u{2190}"), "_underleftarrow")
  static let _underrightarrow =
    MathSpreader(.underspreader("\u{2192}"), "_underrightarrow")

  //
  static let xleftarrow = MathSpreader(.xarrow("\u{2190}"), "xleftarrow")
  static let xrightarrow = MathSpreader(.xarrow("\u{2192}"), "xrightarrow")

}
