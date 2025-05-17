// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

/// Override stored fragment with specified math classs.
struct MathClassLayoutFragment<T: MathLayoutFragment>: MathLayoutFragment {

  let fragment: T

  init(_ clazz: MathClass, _ fragment: T) {
    self.clazz = clazz
    self.fragment = fragment
  }

  init(_ kind: MathKind, _ fragment: T) {
    self.clazz = kind.mathClass
    self.fragment = fragment
  }

  var glyphOrigin: CGPoint { fragment.glyphOrigin }

  func setGlyphOrigin(_ origin: CGPoint) {
    fragment.setGlyphOrigin(origin)
  }

  var layoutLength: Int { fragment.layoutLength }

  func fixLayout(_ mathContext: MathContext) {
    fragment.fixLayout(mathContext)
  }

  var width: Double { fragment.width }
  var height: Double { fragment.height }
  var ascent: Double { fragment.ascent }
  var descent: Double { fragment.descent }

  var italicsCorrection: Double { fragment.italicsCorrection }
  var accentAttachment: Double { fragment.accentAttachment }

  let clazz: MathClass
  var limits: Limits { fragment.limits }
  var isSpaced: Bool { fragment.isSpaced }
  var isTextLike: Bool { fragment.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    fragment.draw(at: point, in: context)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = name ?? "MathClassLayoutFragment(\(clazz))"
    let fragmentDescription = fragment.debugPrint(nil)
    return PrintUtils.compose([description], [fragmentDescription])
  }
}
