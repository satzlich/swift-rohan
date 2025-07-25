internal struct FragmentFactory {
  // MARK: - Interface

  internal let mathContext: MathContext

  init(_ mathContext: MathContext) {
    self.mathContext = mathContext
    self.font = mathContext.getFont()
  }

  /// Resolve a character to a styled character
  mutating func resolveCharacter(
    _ char: Character, _ property: MathProperty
  ) -> (Character, original: Character) {
    let substituted = MathUtils.SUBS[char] ?? char
    let styled = MathUtils.styledChar(
      for: substituted, variant: property.variant, bold: property.bold,
      italic: property.italic, autoItalic: true)
    return (styled, char)
  }

  mutating func makeFragments<S: Collection<Character>>(
    from string: S, _ property: MathProperty
  ) -> Array<any MathLayoutFragment> {
    string.map { char in
      let styled = MathUtils.resolveCharacter(char, property)
      return makeFragment(for: styled, char.length)
    }
  }

  /// Replacement glyph for invalid character
  mutating func replacementGlyph(_ layoutLength: Int) -> MathGlyphLayoutFragment {
    let glyph = _fallbackGlyph(for: Chars.replacementChar)!
    return MathGlyphLayoutFragment(glyph, layoutLength)
  }

  // MARK: - Implementation

  // save font for efficiency
  private let font: Font

  private lazy var _fallbackContext: MathContext = {
    MathUtils.fallbackMathContext(for: mathContext)
  }()

  /// Glyph from fallback context
  private mutating func _fallbackGlyph(for char: Character) -> GlyphFragment? {
    let font = _fallbackContext.getFont()
    let table = _fallbackContext.table
    return GlyphFragment(char: char, font, table)
  }

  private mutating func makeFragment(
    for char: Character, _ layoutLength: Int
  ) -> MathLayoutFragment {

    if Chars.isPrime(char) {
      if let fragment =
        primeFragment(char, mathContext) ?? primeFragment(char, _fallbackContext)
      {
        return MathGlyphVariantLayoutFragment(fragment, layoutLength)
      }
      else {
        return replacementGlyph(layoutLength)
      }
    }
    else {
      let table = mathContext.table
      guard
        let glyph = GlyphFragment(char: char, font, table) ?? _fallbackGlyph(for: char)
      else {
        return replacementGlyph(layoutLength)
      }
      if glyph.clazz == .Large && mathContext.mathStyle == .display {
        let constants = mathContext.constants
        let minHeight = font.convertToPoints(constants.displayOperatorMinHeight)
        let axisHeight = font.convertToPoints(constants.axisHeight)
        let height = max(minHeight, glyph.height * 2.squareRoot())
        let variant =
          glyph.stretch(orientation: .vertical, target: height, shortfall: 0, mathContext)
        return
          MathGlyphVariantLayoutFragment
          .createCentered(variant, layoutLength, axisHeight: axisHeight)
      }
      else {
        return MathGlyphLayoutFragment(glyph, layoutLength)
      }
    }
  }

  /// Fragment for prime character
  private mutating func primeFragment(
    _ char: Character, _ mathContext: MathContext
  ) -> MathFragment? {
    precondition(Chars.isPrime(char))

    let table = mathContext.table
    if let scaledUp = mathContext.mathStyle.scaleUp() {
      let font = mathContext.getFont(for: scaledUp)

      // xHeight may be negative
      // 0.8 works well for Latin Modern, Libertinus, STIX Two
      let shiftDown = Swift.abs(font.xHeight) * 0.8
      return GlyphFragment(char: char, font, table)
        .map { glyph in TranslatedFragment(source: glyph, shiftDown: shiftDown) }
    }
    else {
      return GlyphFragment(char: char, font, table)
    }
  }
}
