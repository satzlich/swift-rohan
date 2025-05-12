// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

struct RuleFragment: MathFragment {
  init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }

  let width: Double
  let height: Double
  var ascent: Double { height / 2 }
  var descent: Double { height / 2 }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func draw(at point: CGPoint, in context: CGContext) {
    let size = CGSize(width: width, height: height)
    let rect = CGRect(origin: point.with(yDelta: -height / 2), size: size)
    context.fill(rect)
  }
}
