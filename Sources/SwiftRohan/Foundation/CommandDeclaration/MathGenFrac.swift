// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathGenFrac: Codable, CommandDeclarationProtocol {
  let command: String
  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }

  let delimiters: DelimiterPair
  /// true if the fraction has a ruler.
  let ruler: Bool
  /// The style to enforce for this fraction. Nil means to use the default style.
  let style: MathStyle?

  init(_ command: String, _ delimiters: DelimiterPair, _ ruler: Bool, _ style: MathStyle?)
  {
    self.command = command
    self.delimiters = delimiters
    self.ruler = ruler
    self.style = style
  }
}

extension MathGenFrac {
  static let allCommands: Array<MathGenFrac> = [
    frac,
    cfrac,
    dfrac,
    tfrac,
    binom,
    dbinom,
    tbinom,
    atop,
  ]

  private static let _dictionary: Dictionary<String, MathGenFrac> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathGenFrac? {
    _dictionary[command]
  }

  static let frac = MathGenFrac("frac", DelimiterPair.NONE, true, nil)
  static let cfrac = MathGenFrac("cfrac", DelimiterPair.NONE, true, .display)
  static let dfrac = MathGenFrac("dfrac", DelimiterPair.NONE, true, .display)
  static let tfrac = MathGenFrac("tfrac", DelimiterPair.NONE, true, .text)
  static let binom = MathGenFrac("binom", DelimiterPair.PAREN, false, nil)
  static let dbinom = MathGenFrac("dbinom", DelimiterPair.PAREN, false, .display)
  static let tbinom = MathGenFrac("tbinom", DelimiterPair.PAREN, false, .text)
  static let atop = MathGenFrac("atop", DelimiterPair.NONE, false, nil)
}
