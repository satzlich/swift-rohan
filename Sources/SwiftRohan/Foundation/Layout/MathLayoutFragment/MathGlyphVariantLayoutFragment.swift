// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

final class MathGlyphVariantLayoutFragment: MathLayoutFragment {
  let glyphVariant: MathFragment
  private let shiftDown: CGFloat

  init(_ glyphVariant: MathFragment, _ layoutLength: Int) {
    self.glyphVariant = glyphVariant
    self.layoutLength = layoutLength
    self.glyphOrigin = .zero
    self.shiftDown = 0
  }

  fileprivate init(
    _ glyphVariant: MathFragment, _ layoutLength: Int, _ shiftDown: CGFloat
  ) {
    self.glyphVariant = glyphVariant
    self.layoutLength = layoutLength
    self.glyphOrigin = .zero
    self.shiftDown = shiftDown
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  var width: Double { glyphVariant.width }
  var ascent: Double { glyphVariant.ascent - shiftDown }
  var descent: Double { glyphVariant.descent + shiftDown }
  var height: Double { glyphVariant.height }
  var italicsCorrection: Double { glyphVariant.italicsCorrection }
  var accentAttachment: Double { glyphVariant.accentAttachment }

  var clazz: MathClass { glyphVariant.clazz }
  var limits: Limits { glyphVariant.limits }

  var isSpaced: Bool { glyphVariant.isSpaced }
  var isTextLike: Bool { glyphVariant.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    glyphVariant.draw(at: point.with(yDelta: shiftDown), in: context)
  }

  let layoutLength: Int

  func fixLayout(_ mathContext: MathContext) { /* no-op */  }

  func debugPrint(_ name: String) -> Array<String> {
    [
      "\(name): MathGlyphVariantLayoutFragment"
    ]
  }
}

extension MathGlyphVariantLayoutFragment {
  static func createCentered(
    _ fragment: MathFragment, _ layoutLength: Int, axisHeight: CGFloat
  ) -> MathGlyphVariantLayoutFragment {
    let shiftDown = fragment.ascent - fragment.height / 2 - axisHeight
    return MathGlyphVariantLayoutFragment(fragment, layoutLength, shiftDown)
  }
}
