// Copyright 2024-2025 Lie Yan

import Foundation

struct MathGenFrac: Codable, MathDeclarationProtocol {
  let command: String

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
  static let predefinedCases: [MathGenFrac] = [
    frac,
    dfrac,
    tfrac,
    binom,
    atop,
  ]

  private static let _dictionary: [String: MathGenFrac] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathGenFrac? {
    _dictionary[command]
  }

  static let frac = MathGenFrac("frac", DelimiterPair.NONE, true, nil)
  static let dfrac = MathGenFrac("dfrac", DelimiterPair.NONE, true, .display)
  static let tfrac = MathGenFrac("tfrac", DelimiterPair.NONE, true, .text)
  static let binom = MathGenFrac("binom", DelimiterPair.PAREN, false, nil)
  static let atop = MathGenFrac("atop", DelimiterPair.NONE, false, nil)
}
