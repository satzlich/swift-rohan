// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

struct VariantFragment: MathFragment {
  /// base character of the variant
  let char: UnicodeScalar

  let compositeGlyph: CompositeGlyph

  var width: Double { compositeGlyph.width }
  var height: Double { compositeGlyph.height }
  var ascent: Double { compositeGlyph.ascent }
  var descent: Double { compositeGlyph.descent }

  let italicsCorrection: Double
  let accentAttachment: Double

  let clazz: MathClass
  let limits: Limits

  var isSpaced: Bool { clazz == .Fence }
  var isTextLike: Bool { isExtendedShape == true }

  let isExtendedShape: Bool

  /// Returns true if the variant is a __middle stretched__ symbol within a
  /// surrounding `\left` and `\right` pair.
  /// - Example: `\mid`
  let isMiddleStretched: Optional<Bool>

  func draw(at point: CGPoint, in context: CGContext) {
    compositeGlyph.draw(at: point, in: context)
  }

  init(
    char: UnicodeScalar,
    compositeGlyph: CompositeGlyph,
    italicsCorrection: Double,
    accentAttachment: Double,
    clazz: MathClass,
    limits: Limits,
    isExtendedShape: Bool,
    isMiddleStretched: Optional<Bool>
  ) {
    self.char = char
    self.compositeGlyph = compositeGlyph
    self.italicsCorrection = italicsCorrection
    self.accentAttachment = accentAttachment
    self.clazz = clazz
    self.limits = limits
    self.isExtendedShape = isExtendedShape
    self.isMiddleStretched = isMiddleStretched
  }
}
