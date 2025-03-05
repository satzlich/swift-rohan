// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

extension MathUtils {
  // overriding table for math classes
  static let MCLS: [UnicodeScalar: MathClass] = [
    "/": .Normal
  ]

  // substitution table for characters
  static let SUBS: [Character: Character] = [
    "-": "\u{2212}"
  ]
}
