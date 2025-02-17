// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

final class MathGlyphLayoutFragment: MathLayoutFragment {
  private let glyph: GlyphFragment

  init(_ glyph: GlyphFragment, _ layoutLength: Int) {
    self.glyph = glyph
    self.layoutLength = layoutLength
    self.glyphOrigin = .zero
  }

  convenience init?(
    _ char: UnicodeScalar,
    _ font: Font,
    _ table: MathTable,
    _ layoutLength: Int
  ) {
    guard let glyph = GlyphFragment(char, font, table) else { return nil }
    self.init(glyph, layoutLength)
  }

  // MARK: - Frame

  private var glyphOrigin: CGPoint

  var glyphFrame: CGRect {
    let size = CGSize(width: glyph.width, height: glyph.height)
    return CGRect(origin: glyphOrigin, size: size)
  }

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Metrics

  var width: Double { glyph.width }
  var ascent: Double { glyph.ascent }
  var descent: Double { glyph.descent }
  var height: Double { glyph.height }
  var italicsCorrection: Double { glyph.italicsCorrection }
  var accentAttachment: Double { glyph.accentAttachment }

  // MARK: - Categories

  var clazz: MathClass { glyph.clazz }
  var limits: Limits { glyph.limits }

  // MARK: - Flags

  var isSpaced: Bool { glyph.isSpaced }
  var isTextLike: Bool { glyph.isTextLike }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    glyph.draw(at: point, in: context)
  }

  // MARK: - Length

  let layoutLength: Int

  // MARK: - Debug Description

  func debugPrint() -> Array<String> {
    debugPrint("glyph")
  }

  func debugPrint(_ customName: String) -> Array<String> {
    let char = Character(glyph.char)
    let origin = glyphOrigin.formatted(2)
    let width = glyph.width.formatted(2)
    let ascent = glyph.ascent.formatted(2)
    let descent = glyph.descent.formatted(2)
    return [
      """
      \(customName)('\(char)'): \(origin) \(width)x(\(ascent)+\(descent))
      """
    ]
  }
}
