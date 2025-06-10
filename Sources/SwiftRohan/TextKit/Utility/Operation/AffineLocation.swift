// Copyright 2024-2025 Lie Yan

import Foundation

/// Location resolved from coordinates
struct AffineLocation {
  let value: TextLocation
  let affinity: TextAffinity

  init(_ value: TextLocation, _ affinity: TextAffinity) {
    self.value = value
    self.affinity = affinity
  }
}
