// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

/// Fragment with bottom part clipped.
struct ClippedFragment<T: MathFragment>: MathFragment {
  /// The fragment to be clipped.
  private let source: T
  /// The height of the clipped part.
  private let cutoff: Double

  init(source: T, cutoff: Double) {
    precondition(cutoff >= 0)
    self.source = source
    self.cutoff = cutoff
  }

  var width: Double { source.width }
  var height: Double { source.height - cutoff }
  var ascent: Double { source.ascent }
  var descent: Double { source.descent - cutoff }

  var italicsCorrection: Double { source.italicsCorrection }
  var accentAttachment: Double { source.accentAttachment }

  var clazz: MathClass { source.clazz }
  var limits: Limits { source.limits }

  var isSpaced: Bool { source.isSpaced }
  var isTextLike: Bool { source.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y + cutoff)
    source.draw(at: .zero, in: context)
    context.restoreGState()
  }
}
