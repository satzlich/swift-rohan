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

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  var glyphFrame: CGRect {
    let size = CGSize(width: glyphVariant.width, height: glyphVariant.height)
    return CGRect(origin: glyphOrigin, size: size)
  }

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Metrics

  var width: Double { glyphVariant.width }
  var ascent: Double { glyphVariant.ascent }
  var descent: Double { glyphVariant.descent }
  var height: Double { glyphVariant.height }
  var italicsCorrection: Double { glyphVariant.italicsCorrection }
  var accentAttachment: Double { glyphVariant.accentAttachment }

  // MARK: - Categories

  var clazz: MathClass { glyphVariant.clazz }
  var limits: Limits { glyphVariant.limits }

  // MARK: - Flags

  var isSpaced: Bool { glyphVariant.isSpaced }
  var isTextLike: Bool { glyphVariant.isTextLike }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    glyphVariant.draw(at: point, in: context)
  }

  // MARK: - Length

  let layoutLength: Int

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  // MARK: - Debug Description

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "glyph variant"
    return ["\(name) \(boxDescription)"]
  }
}
