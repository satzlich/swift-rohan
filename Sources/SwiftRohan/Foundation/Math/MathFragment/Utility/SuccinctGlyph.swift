// Copyright 2024-2025 Lie Yan

/// A succinct representation of a glyph whose contextual font is implicitly known.
struct SuccinctGlyph {
  let glyph: GlyphId

  let width: Double
  let ascent: Double
  let descent: Double

  init(_ glyph: GlyphId, _ font: Font) {
    let width = font.getAdvance(for: glyph, .horizontal)
    let (ascent, descent) = font.getAscentDescent(for: glyph)

    self.glyph = glyph
    self.width = width
    self.ascent = ascent
    self.descent = descent
  }
}
