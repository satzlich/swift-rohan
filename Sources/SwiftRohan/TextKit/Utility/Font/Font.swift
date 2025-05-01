// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

public typealias GlyphId = UInt16

public struct Font {  // Cannot be sendable due to CTFont
  let ctFont: CTFont
  let isFlipped: Bool

  internal init(ctFont: CTFont, isFlipped: Bool) {
    self.ctFont = ctFont
    self.isFlipped = isFlipped
  }

  public static func createWithName(
    _ name: String, _ size: CGFloat, isFlipped: Bool = false
  ) -> Font {
    let ctFont = CTFont.createWithName(name, size, isFlipped: isFlipped)
    return Font(ctFont: ctFont, isFlipped: isFlipped)
  }

  /// Create a copy of the font with the given size.
  public func createCopy(_ size: CGFloat) -> Font {
    var matrix = CTFontGetMatrix(ctFont)
    let ctFont = CTFontCreateCopyWithAttributes(ctFont, size, &matrix, nil)
    return Font(ctFont: ctFont, isFlipped: isFlipped)
  }

  // MARK: - Conversion

  func convertToPoints<T: BinaryInteger>(_ designUnits: T) -> CGFloat {
    CGFloat(designUnits) / CGFloat(unitsPerEm) * size
  }

  func convertToPoints(fromUnits designUnits: Double) -> Double {
    designUnits / CGFloat(unitsPerEm) * size
  }

  func convertToPoints(_ em: Em) -> Double { em.floatValue * size }

  func convertToDesignUnits(_ points: CGFloat) -> Int32 {
    Int32(points / size * CGFloat(unitsPerEm))
  }

  // MARK: - Global

  public var unitsPerEm: UInt32 { CTFontGetUnitsPerEm(ctFont) }
  public var size: CGFloat { CTFontGetSize(ctFont) }
  public var ascent: CGFloat { CTFontGetAscent(ctFont) }
  public var descent: CGFloat { CTFontGetDescent(ctFont) }

  public func copyFamilyName() -> CFString {
    CTFontCopyFamilyName(ctFont)
  }

  public func copyMathTable() -> MathTable? {
    // `CTFontCopyTable` only makes a shallow copy
    CTFontCopyTable(ctFont, CTFontTableTag(kCTFontTableMATH), CTFontTableOptions())
      .flatMap(MathTable.init(_:))
  }

  // MARK: - Character/Glyph

  public func getBoxMetrics(
    for glyph: GlyphId
  ) -> (width: CGFloat, ascent: CGFloat, descent: CGFloat) {
    func getAscentDescent(_ rect: CGRect) -> (ascent: CGFloat, descent: CGFloat) {
      if !isFlipped {
        let descent = -rect.origin.y
        return (rect.height - descent, descent)
      }
      else {
        let ascent = -rect.origin.y
        return (ascent, rect.height - ascent)
      }
    }

    let rect = getBoundingRect(for: glyph)
    let (ascent, descent) = getAscentDescent(rect)
    return (rect.width, ascent, descent)
  }

  public func getGlyph(for character: Character) -> GlyphId? {
    var glyphs: [GlyphId] = [0, 0]  // we need two slots
    let okay = getGlyphs(for: character.utf16.map { $0 }, &glyphs)
    return okay ? glyphs[0] : nil
  }

  public func getGlyph(for unicodeScalar: UnicodeScalar) -> GlyphId? {
    var glyphs: [GlyphId] = [0, 0]  // we need two slots
    let okay = getGlyphs(for: unicodeScalar.utf16.map { $0 }, &glyphs)
    return okay ? glyphs[0] : nil
  }

  public func getGlyphs(for characters: [UniChar], _ glyphs: inout [GlyphId]) -> Bool {
    precondition(characters.count <= glyphs.count)
    return CTFontGetGlyphsForCharacters(ctFont, characters, &glyphs, characters.count)
  }

  public func getBoundingRect(for glyph: GlyphId) -> CGRect {
    withUnsafePointer(to: glyph) {
      CTFontGetBoundingRectsForGlyphs(ctFont, .default, $0, nil, 1)
    }
  }

  public func getBoundingRects(for glyphs: [GlyphId], _ rects: inout [CGRect]) -> CGRect {
    precondition(glyphs.count <= rects.count)
    return CTFontGetBoundingRectsForGlyphs(
      ctFont, CTFontOrientation.default, glyphs, &rects, glyphs.count)
  }

  public func getAdvance(for glyph: GlyphId, _ orientation: CTFontOrientation) -> CGFloat
  {
    withUnsafePointer(to: glyph) {
      CTFontGetAdvancesForGlyphs(ctFont, orientation, $0, nil, 1)
    }
  }

  public func getAdvances(
    for glyphs: [GlyphId], _ orientation: CTFontOrientation, _ advances: inout [CGSize]
  ) -> CGFloat {
    precondition(glyphs.count <= advances.count)
    return CTFontGetAdvancesForGlyphs(
      ctFont, orientation, glyphs, &advances, glyphs.count)
  }

  public func drawGlyph(_ glyph: GlyphId, _ position: CGPoint, _ context: CGContext) {
    withUnsafePointer(to: glyph) { glyph in
      withUnsafePointer(to: position) { position in
        CTFontDrawGlyphs(ctFont, glyph, position, 1, context)
      }
    }
  }

  public func drawGlyphs(
    _ glyphs: [GlyphId], _ positions: [CGPoint], _ context: CGContext
  ) {
    precondition(glyphs.count == positions.count)
    CTFontDrawGlyphs(ctFont, glyphs, positions, glyphs.count, context)
  }
}
