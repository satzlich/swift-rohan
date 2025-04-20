// Copyright 2024-2025 Lie Yan

import Foundation

/// Location resolved from coordinates
struct ResolvedLocation {
  let location: TextLocation
  let affinity: RhTextSelection.Affinity

  init(_ location: TextLocation, affinity: RhTextSelection.Affinity) {
    self.location = location
    self.affinity = affinity
  }
}
