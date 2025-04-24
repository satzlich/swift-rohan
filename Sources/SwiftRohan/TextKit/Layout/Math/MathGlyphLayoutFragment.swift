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
    _ char: Character, _ font: Font, _ table: MathTable, _ layoutLength: Int
  ) {
    guard char.unicodeScalars.count == 1 else { return nil }
    let unicodeScalar = char.unicodeScalars.first!
    self.init(unicodeScalar, font, table, layoutLength)
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint
  
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

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "glyph"
    let char = Character(glyph.char)
    return ["\(name)(\(char)) \(boxDescription)"]
  }
}
