// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

/// Fragment that is translated by a given amount.
struct TranslatedFragment<T: MathFragment>: MathFragment {
  /// The fragment to translate.
  private let source: T
  /// The amount to shift down.
  private let shiftDown: Double

  init(source: T, shiftDown: Double) {
    precondition(shiftDown >= 0)
    self.source = source
    self.shiftDown = shiftDown
  }

  var width: Double { source.width }
  var height: Double { ascent + descent }
  var ascent: Double { source.ascent - shiftDown }
  var descent: Double { source.descent + shiftDown }

  var italicsCorrection: Double { source.italicsCorrection }
  var accentAttachment: Double { source.accentAttachment }

  var clazz: MathClass { source.clazz }
  var limits: Limits { source.limits }

  var isSpaced: Bool { source.isSpaced }
  var isTextLike: Bool { source.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    source.draw(at: point.with(yDelta: shiftDown), in: context)
  }
}
