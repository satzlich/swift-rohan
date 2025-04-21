// Copyright 2024-2025 Lie Yan

import Foundation

/// Location resolved from coordinates
struct AffineLocation {
  let value: TextLocation
  let affinity: RhTextSelection.Affinity

  init(_ value: TextLocation, _ affinity: RhTextSelection.Affinity) {
    self.value = value
    self.affinity = affinity
  }
}
