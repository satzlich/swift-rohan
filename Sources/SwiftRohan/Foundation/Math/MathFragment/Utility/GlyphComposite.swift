import CoreGraphics

struct GlyphComposite {
  typealias Item = (fragment: SuccinctGlyph, position: CGPoint)

  private let glyphs: Array<GlyphId>
  private let positions: Array<CGPoint>
  private let font: Font

  let width: Double
  var height: Double { ascent + descent }
  let ascent: Double
  let descent: Double

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    font.drawGlyphs(glyphs, positions, context)
    context.restoreGState()
  }

  init<S: Sequence<Item>>(
    width: Double, ascent: Double, descent: Double, font: Font, items: S
  ) {
    self.init(
      width: width, ascent: ascent, descent: descent, font: font,
      glyphs: items.map(\.fragment.glyph), positions: items.map(\.position))
  }

  init(
    width: Double, ascent: Double, descent: Double, font: Font, glyphs: Array<GlyphId>,
    positions: Array<CGPoint>
  ) {
    precondition(glyphs.count == positions.count)
    self.width = width
    self.ascent = ascent
    self.descent = descent
    self.font = font
    self.glyphs = glyphs
    self.positions = positions
  }
}
