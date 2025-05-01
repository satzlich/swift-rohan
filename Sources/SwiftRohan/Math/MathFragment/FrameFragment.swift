// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

struct FrameFragment: MathFragment {
  private let composition: MathComposition

  init(_ composition: MathComposition) {
    self.composition = composition
  }

  // MARK: - Metrics

  var width: Double { composition.width }
  var height: Double { composition.height }
  var ascent: Double { composition.ascent }
  var descent: Double { composition.descent }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  // MARK: - Categories

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  // MARK: - Flags

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    composition.draw(at: point, in: context)
  }
}
