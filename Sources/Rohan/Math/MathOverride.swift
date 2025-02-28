// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

enum MathOverride {
  // overriding table for math classes
  static let mathClass: [UnicodeScalar: MathClass] = [
    "/": .Normal
  ]

  // substitution table for characters
  static let SUBS: [UnicodeScalar: UnicodeScalar] = [
    "-": "\u{2212}"
  ]
}
