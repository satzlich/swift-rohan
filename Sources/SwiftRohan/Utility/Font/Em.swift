// Copyright 2024-2025 Lie Yan

import Foundation

struct Em: Equatable, Hashable, Sendable {
  let floatValue: Double

  init(_ floatValue: Double) {
    precondition(floatValue.isFinite)
    self.floatValue = floatValue
  }

  static var zero: Em { Em(0.0) }

  // spacing
  static var thin: Em { Em(1.0 / 6.0) }
  static var medium: Em { Em(2.0 / 9.0) }
  static var thick: Em { Em(5.0 / 18.0) }
  static var quad: Em { Em(1.0) }
  static var wide: Em { Em(2.0) }
}

extension Em: Comparable {
  static func < (lhs: Em, rhs: Em) -> Bool {
    lhs.floatValue < rhs.floatValue
  }
}
