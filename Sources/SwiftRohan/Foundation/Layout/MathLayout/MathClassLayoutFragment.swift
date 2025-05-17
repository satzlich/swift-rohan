// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

/// Override stored fragment with specified math classs.
final class MathClassLayoutFragment<T: MathLayoutFragment>: MathLayoutFragment {
  let wrapped: T

  init(_ clazz: MathClass, _ fragment: T) {
    self.clazz = clazz
    self.wrapped = fragment
    self.glyphOrigin = .zero
  }

  init(_ kind: MathKind, _ fragment: T) {
    self.clazz = kind.mathClass
    self.wrapped = fragment
    self.glyphOrigin = .zero
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { wrapped.layoutLength }

  func fixLayout(_ mathContext: MathContext) {
    wrapped.fixLayout(mathContext)
  }

  var width: Double { wrapped.width }
  var height: Double { wrapped.height }
  var ascent: Double { wrapped.ascent }
  var descent: Double { wrapped.descent }

  var italicsCorrection: Double { wrapped.italicsCorrection }
  var accentAttachment: Double { wrapped.accentAttachment }

  let clazz: MathClass
  var limits: Limits { wrapped.limits }
  var isSpaced: Bool { wrapped.isSpaced }
  var isTextLike: Bool { wrapped.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    wrapped.draw(at: point, in: context)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "class \(boxDescription)"
    let wrapped = wrapped.debugPrint("wrapped")
    return PrintUtils.compose([description], [wrapped])
  }
}
