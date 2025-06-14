// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

final class MathGlyphLayoutFragment: MathLayoutFragment {
  let glyph: GlyphFragment

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

  convenience init?(
    char: Character,
    _ font: Font,
    _ table: MathTable,
    _ layoutLength: Int
  ) {
    guard let glyph = GlyphFragment(char: char, font, table) else { return nil }
    self.init(glyph, layoutLength)
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  var width: Double { glyph.width }
  var ascent: Double { glyph.ascent }
  var descent: Double { glyph.descent }
  var height: Double { glyph.height }
  var italicsCorrection: Double { glyph.italicsCorrection }
  var accentAttachment: Double { glyph.accentAttachment }

  var clazz: MathClass { glyph.clazz }
  var limits: Limits { glyph.limits }

  var isSpaced: Bool { glyph.isSpaced }
  var isTextLike: Bool { glyph.isTextLike }

  func draw(at point: CGPoint, in context: CGContext) {
    glyph.draw(at: point, in: context)
  }

  let layoutLength: Int

  func fixLayout(_ mathContext: MathContext) { /* no-op */  }

  func debugPrint(_ name: String) -> Array<String> {
    [
      "\(name): MathGlyphLayoutFragment '\(glyph.char)'"
    ]
  }
}
