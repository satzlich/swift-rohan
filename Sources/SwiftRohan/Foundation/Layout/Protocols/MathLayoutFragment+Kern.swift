import TTFParser

extension MathLayoutFragment {
  func kernAtHeight(
    _ context: MathContext, _ corner: Corner, _ height: Double
  ) -> Double { 0 }
}

extension MathListLayoutFragment {
  func kernAtHeight(
    _ context: MathContext, _ corner: Corner, _ height: Double
  ) -> Double {
    if self.count == 1,
      let glyph = self.get(0) as? MathGlyphLayoutFragment
    {
      return glyph.kernAtHeight(context, corner, height)
    }
    return 0
  }
}

extension MathGlyphLayoutFragment {
  func kernAtHeight(
    _ context: MathContext, _ corner: Corner, _ height: Double
  ) -> Double {
    return Self.kernAtHeight(context, glyph.glyph, corner, height) ?? 0
  }

  /// Look up a kerning value at given corner and height
  private static func kernAtHeight(
    _ context: MathContext, _ id: GlyphId, _ corner: Corner, _ height: Double
  ) -> Double? {
    guard let kerns = context.table.glyphInfo?.kerns?.get(id),
      let kern: MathKernTable =
        switch corner {
        case .topLeft: kerns.topLeft
        case .topRight: kerns.topRight
        case .bottomLeft: kerns.bottomLeft
        case .bottomRight: kerns.bottomRight
        }
    else { return nil }

    let font = context.getFont()
    let heightInUnits = Int16(font.convertToDesignUnits(height))
    let value = kern.get(heightInUnits)
    return font.convertToPoints(value)
  }
}
