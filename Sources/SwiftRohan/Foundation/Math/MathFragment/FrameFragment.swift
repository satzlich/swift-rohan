import CoreGraphics
import Foundation
import UnicodeMathClass

struct FrameFragment: MathFragment {
  private let _composition: MathComposition

  init(_ composition: MathComposition) {
    self._composition = composition
  }

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }
}
