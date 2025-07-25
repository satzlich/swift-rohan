import CoreGraphics
import Foundation
import UnicodeMathClass

struct ColoredFragment<T: MathFragment>: MathFragment {
  let color: Color
  let wrapped: T

  init(color: Color, wrapped: T) {
    self.color = color
    self.wrapped = wrapped
  }

  var width: Double { wrapped.width }
  var height: Double { wrapped.height }
  var ascent: Double { wrapped.ascent }
  var descent: Double { wrapped.descent }

  var italicsCorrection: Double { wrapped.italicsCorrection }
  var accentAttachment: Double { wrapped.accentAttachment }

  var clazz: MathClass { wrapped.clazz }
  var limits: Limits { wrapped.limits }

  var isSpaced: Bool { wrapped.isSpaced }
  var isTextLike: Bool { wrapped.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.setFillColor(color.cgColor)
    wrapped.draw(at: point, in: context)
    context.restoreGState()
  }
}
