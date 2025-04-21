// Copyright 2024-2025 Lie Yan

import Foundation

struct Affine<T> {
  let value: T
  let affinity: RhTextSelection.Affinity

  init(_ value: T, _ affinity: RhTextSelection.Affinity) {
    self.value = value
    self.affinity = affinity
  }
}

typealias AffineLocation = Affine<TextLocation>
typealias AffineOffset = Affine<Int>
