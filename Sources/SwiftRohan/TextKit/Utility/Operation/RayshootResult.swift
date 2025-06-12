// Copyright 2024-2025 Lie Yan

import CoreGraphics

struct RayshootResult {
  var position: CGPoint
  let isResolved: Bool

  init(_ position: CGPoint, _ resolved: Bool) {
    self.position = position
    self.isResolved = resolved
  }

  func with(position: CGPoint) -> RayshootResult {
    return RayshootResult(position, isResolved)
  }
}
