// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

/// Override stored fragment with specified math classs.
final class MathClassLayoutFragment<T: MathLayoutFragment>: MathLayoutFragment {
  let nucleus: T

  init(_ clazz: MathClass, _ fragment: T) {
    self.clazz = clazz
    self.limits = Limits.defaultValue(forMathClass: clazz)
    self.nucleus = fragment
    self.glyphOrigin = .zero
  }

  convenience init(_ kind: MathKind, _ fragment: T) {
    self.init(kind.mathClass, fragment)
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { nucleus.layoutLength }

  func fixLayout(_ mathContext: MathContext) {
    nucleus.fixLayout(mathContext)
  }

  var width: Double { nucleus.width }
  var height: Double { nucleus.height }
  var ascent: Double { nucleus.ascent }
  var descent: Double { nucleus.descent }

  var italicsCorrection: Double { nucleus.italicsCorrection }
  var accentAttachment: Double { nucleus.accentAttachment }

  let clazz: MathClass
  let limits: Limits
  var isSpaced: Bool { nucleus.isSpaced }
  var isTextLike: Bool { nucleus.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    nucleus.draw(at: point, in: context)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "class \(boxDescription)"
    let wrapped = nucleus.debugPrint("wrapped")
    return PrintUtils.compose([description], [wrapped])
  }
}
