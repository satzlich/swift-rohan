// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

public typealias GlyphId = UInt16

public struct Font {
    @usableFromInline let ctFont: CTFont
    @usableFromInline let isFlipped: Bool

    @inlinable
    internal init(ctFont: CTFont, isFlipped: Bool) {
        self.ctFont = ctFont
        self.isFlipped = isFlipped
    }

    @inlinable
    public static func createWithName(_ name: String, _ size: CGFloat,
                                      isFlipped: Bool = false) -> Font
    {
        let ctFont = CTFont.createWithName(name, size, isFlipped: isFlipped)
        return Font(ctFont: ctFont, isFlipped: isFlipped)
    }

    @inlinable public var unitsPerEm: UInt32 { ctFont.unitsPerEm }
    @inlinable public var size: CGFloat { ctFont.size }
    @inlinable public var glyphCount: Int { ctFont.glyphCount }

    @inlinable
    public func convertToEm<T>(_ designUnits: T) -> CGFloat where T: BinaryInteger {
        ctFont.convertToEm(designUnits)
    }

    @inlinable
    public func convertToPoints<T>(_ designUnits: T) -> CGFloat where T: BinaryInteger {
        ctFont.convertToPoints(designUnits)
    }

    @inlinable
    public func getBoxMetrics(for glyph: GlyphId)
    -> (width: CGFloat, ascent: CGFloat, descent: CGFloat) {
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

    @inlinable
    public func getGlyph(for character: Character) -> GlyphId? {
        ctFont.getGlyph(for: character)
    }

    @inlinable
    public func getGlyph(for unicodeScalar: UnicodeScalar) -> GlyphId? {
        ctFont.getGlyph(for: unicodeScalar)
    }

    @inlinable
    public func getGlyphs(for characters: [UniChar], _ glyphs: inout [GlyphId]) -> Bool {
        ctFont.getGlyphs(for: characters, &glyphs)
    }

    @inlinable
    public func getBoundingRect(for glyph: GlyphId) -> CGRect {
        ctFont.getBoundingRect(for: glyph)
    }

    @inlinable
    public func getBoundingRects(for glyphs: [GlyphId],
                                 _ rects: inout [CGRect]) -> CGRect
    {
        ctFont.getBoundingRects(for: glyphs, &rects)
    }

    @inlinable
    public func getAdvance(for glyph: GlyphId,
                           _ orientation: CTFontOrientation) -> CGFloat
    {
        ctFont.getAdvance(for: glyph, orientation)
    }

    @inlinable
    public func getAdvances(for glyphs: [GlyphId],
                            _ orientation: CTFontOrientation,
                            _ advances: inout [CGSize]) -> CGFloat
    {
        ctFont.getAdvances(for: glyphs, orientation, &advances)
    }

    @inlinable
    public func drawGlyph(_ glyph: GlyphId, _ point: CGPoint, _ context: CGContext) {
        ctFont.drawGlyph(glyph, point, context)
    }

    @inlinable
    public func drawGlyphs(_ glyphs: [GlyphId], _ points: [CGPoint],
                           _ context: CGContext)
    {
        ctFont.drawGlyphs(glyphs, points, context)
    }

    @inlinable
    public func copyMathTable() -> MathTable? {
        ctFont.copyMathTable()
    }
}

extension CTFont {
    @inlinable
    static func createWithName(_ name: String, _ size: CGFloat,
                               isFlipped: Bool = false) -> CTFont
    {
        guard isFlipped else { return CTFontCreateWithName(name as CFString, size, nil) }
        var invY = CGAffineTransform(scaleX: 1, y: -1)
        return CTFontCreateWithName(name as CFString, size, &invY)
    }

    @inlinable
    var unitsPerEm: UInt32 { CTFontGetUnitsPerEm(self) }

    @inlinable
    var size: CGFloat { CTFontGetSize(self) }

    @inlinable
    var glyphCount: Int { CTFontGetGlyphCount(self) }

    @inlinable
    func convertToEm<T>(_ designUnits: T) -> CGFloat
    where T: BinaryInteger {
        CGFloat(designUnits) / CGFloat(unitsPerEm)
    }

    @inlinable
    func convertToPoints<T>(_ designUnits: T) -> CGFloat
    where T: BinaryInteger {
        convertToEm(designUnits) * size
    }

    /**

     - Returns:
        `true` if the font could encode all Unicode characters; otherwise `false`.
     */
    @inlinable
    func getGlyphs(for characters: [UniChar], _ glyphs: inout [GlyphId]) -> Bool {
        precondition(characters.count <= glyphs.count)
        return CTFontGetGlyphsForCharacters(self, characters, &glyphs, characters.count)
    }

    @inlinable
    func getGlyph(for character: Character) -> GlyphId? {
        var glyphs: [GlyphId] = [0, 0] // we need two slots
        let okay = getGlyphs(for: character.utf16.map { $0 }, &glyphs)
        return okay ? glyphs[0] : nil
    }

    @inlinable
    func getGlyph(for character: UnicodeScalar) -> GlyphId? {
        var glyphs: [GlyphId] = [0, 0] // we need two slots
        let okay = getGlyphs(for: character.utf16.map { $0 }, &glyphs)
        return okay ? glyphs[0] : nil
    }

    @inlinable
    func getBoundingRect(for glyph: GlyphId) -> CGRect {
        withUnsafePointer(to: glyph) {
            CTFontGetBoundingRectsForGlyphs(self, .default, $0, nil, 1)
        }
    }

    @inlinable
    func getBoundingRects(for glyphs: [GlyphId],
                          _ rects: inout [CGRect]) -> CGRect
    {
        precondition(glyphs.count <= rects.count)
        return CTFontGetBoundingRectsForGlyphs(
            self, CTFontOrientation.default, glyphs, &rects, glyphs.count
        )
    }

    @inlinable
    func getAdvance(for glyph: GlyphId,
                    _ orientation: CTFontOrientation) -> CGFloat
    {
        withUnsafePointer(to: glyph) {
            CTFontGetAdvancesForGlyphs(self, orientation, $0, nil, 1)
        }
    }

    @inlinable
    func getAdvances(for glyphs: [GlyphId],
                     _ orientation: CTFontOrientation,
                     _ advances: inout [CGSize]) -> CGFloat
    {
        precondition(glyphs.count <= advances.count)
        return CTFontGetAdvancesForGlyphs(self, orientation,
                                          glyphs, &advances, glyphs.count)
    }

    @inlinable
    func drawGlyphs(_ glyphs: [GlyphId],
                    _ positions: [CGPoint],
                    _ context: CGContext)
    {
        precondition(glyphs.count == positions.count)
        CTFontDrawGlyphs(self, glyphs, positions, glyphs.count, context)
    }

    @inlinable
    func drawGlyph(_ glyph: GlyphId,
                   _ position: CGPoint,
                   _ context: CGContext)
    {
        withUnsafePointer(to: glyph) { glyph in
            withUnsafePointer(to: position) { position in
                CTFontDrawGlyphs(self, glyph, position, 1, context)
            }
        }
    }

    @inlinable
    func copyMathTable() -> MathTable? {
        // `CTFontCopyTable` only makes a shallow copy
        CTFontCopyTable(self,
                        CTFontTableTag(kCTFontTableMATH),
                        CTFontTableOptions())
            .flatMap(MathTable.init(_:))
    }
}
