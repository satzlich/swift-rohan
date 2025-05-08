// Copyright 2024-2025 Lie Yan

import Foundation

enum FixedAlignment: CaseIterable {
  case start
  case center
  case end

  /// Returns the position of this alignment in a container with the given
  /// extent.
  func position(_ extent: Double) -> Double {
    switch self {
    case .start: return 0
    case .center: return extent / 2
    case .end: return extent
    }
  }
}
