// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

extension MathUtils {
  // overriding table for math classes
  static let MCLS: [UnicodeScalar: MathClass] = [
    "\u{002F}": .Normal,  // /
    "\u{003A}": .Relation,  // :
    "\u{2020}": .Normal,  // Dagger
    "\u{2021}": .Normal,  // Double Dagger
    "\u{2216}": .Binary,  // SET MINUS
    "\u{22EF}": .Normal,  // ldots
  ]

  // substitution table for characters
  static let SUBS: [Character: Character] = [
    "-": "\u{2212}",  // MINUS SIGN
    "*": "\u{2217}",  // ASTERISK OPERATOR
  ]
}
