import CoreGraphics
import Foundation
import UnicodeMathClass

final class MathFragmentWrapper<T: MathFragment>: MathLayoutFragment {
  let fragment: T

  init(_ fragment: T, _ layoutLength: Int) {
    self.fragment = fragment
    self.layoutLength = layoutLength
    self.glyphOrigin = .zero
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  var width: Double { fragment.width }
  var ascent: Double { fragment.ascent }
  var descent: Double { fragment.descent }
  var height: Double { fragment.height }
  var italicsCorrection: Double { fragment.italicsCorrection }
  var accentAttachment: Double { fragment.accentAttachment }

  var clazz: MathClass { fragment.clazz }
  var limits: Limits { fragment.limits }

  var isSpaced: Bool { fragment.isSpaced }
  var isTextLike: Bool { fragment.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    fragment.draw(at: point, in: context)
  }

  let layoutLength: Int

  func fixLayout(_ mathContext: MathContext) { /* no-op */  }

  func debugPrint(_ name: String) -> Array<String> {
    [
      "\(name): MathFragmentWrapper"
    ]
  }
}
