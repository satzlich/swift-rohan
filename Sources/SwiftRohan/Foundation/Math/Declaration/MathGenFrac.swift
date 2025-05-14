// Copyright 2024-2025 Lie Yan

import Foundation

struct MathGenFrac: Codable {
  let command: String
  let delimiters: DelimiterPair
  let ruler: Bool
  /// The style to enforce for this fraction.
  let enforceStyle: MathStyle?

  init(
    _ command: String, _ delimiters: DelimiterPair, _ ruler: Bool,
    _ enforceStyle: MathStyle?
  ) {
    self.command = command
    self.delimiters = delimiters
    self.ruler = ruler
    self.enforceStyle = enforceStyle
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
