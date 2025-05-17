// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

final class MathGlyphVariantLayoutFragment: MathLayoutFragment {
  let glyphVariant: MathFragment

  init(_ glyphVariant: MathFragment, _ layoutLength: Int) {
    self.glyphVariant = glyphVariant
    self.layoutLength = layoutLength
    self.glyphOrigin = .zero
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  var width: Double { glyphVariant.width }
  var ascent: Double { glyphVariant.ascent }
  var descent: Double { glyphVariant.descent }
  var height: Double { glyphVariant.height }
  var italicsCorrection: Double { glyphVariant.italicsCorrection }
  var accentAttachment: Double { glyphVariant.accentAttachment }

  var clazz: MathClass { glyphVariant.clazz }
  var limits: Limits { glyphVariant.limits }

  var isSpaced: Bool { glyphVariant.isSpaced }
  var isTextLike: Bool { glyphVariant.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    glyphVariant.draw(at: point, in: context)
  }

  let layoutLength: Int

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "variant \(boxDescription)"
    return PrintUtils.compose([description], [])
  }
}
