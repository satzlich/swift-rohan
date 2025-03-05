// Copyright 2024-2025 Lie Yan

import CoreGraphics

struct RayshootResult {
  let position: CGPoint
  let resolved: Bool

  init(_ position: CGPoint, _ resolved: Bool) {
    self.position = position
    self.resolved = resolved
  }

  func with(position: CGPoint) -> RayshootResult {
    return RayshootResult(position, resolved)
  }
}
