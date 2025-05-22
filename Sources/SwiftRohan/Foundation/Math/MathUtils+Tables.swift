// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

extension MathUtils {
  // overriding table for math classes
  static let MCLS: [UnicodeScalar: MathClass] = [
    "\u{002E}": .Normal,  // FULL STOP used as a decimal point.
    "\u{002F}": .Normal,  // SOLIDUS used as division slash.
    "\u{003A}": .Relation,  // COLON used as ratio mark. (Use \colon instead for punctuation.)
    "\u{03F6}": .Binary,  // \backepsilon
    "\u{2020}": .Normal,  // \dag (Use \dagger instead for binary operator.)
    "\u{2021}": .Normal,  // \ddag (User \ddagger instead for binary operator.)
    "\u{2026}": .Binary,  // \ldots
    "\u{2216}": .Binary,  // SET MINUS
    "\u{25EF}": .Binary,  // LARGE CIRCLE
  ]

  // substitution table for characters
  static let SUBS: [Character: Character] = [
    "-": "\u{2212}",  // MINUS SIGN
    "*": "\u{2217}",  // ASTERISK OPERATOR
  ]
}
