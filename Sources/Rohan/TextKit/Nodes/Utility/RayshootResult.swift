// Copyright 2024-2025 Lie Yan

import CoreGraphics

struct RayshootResult {
  let position: CGPoint
  let hit: Bool

  init(_ position: CGPoint, _ hit: Bool) {
    self.position = position
    self.hit = hit
  }
  
  func with(position: CGPoint) -> RayshootResult {
    return RayshootResult(position, hit)
  }
}
