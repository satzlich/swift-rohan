// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

public typealias GlyphId = UInt16
public typealias Font = CTFont

extension CTFont {
    @inlinable
    public var unitsPerEm: UInt32 { CTFontGetUnitsPerEm(self) }

    @inlinable
    public var size: CGFloat { CTFontGetSize(self) }

    @inlinable
    public func convertToEm(_ designUnits: UInt32) -> CGFloat {
        CGFloat(designUnits) / CGFloat(unitsPerEm)
    }

    @inlinable
    public func convertToPoints(_ designUnits: UInt32) -> CGFloat {
        convertToEm(designUnits) * size
    }

    /**

     - Returns:
        `true` if the font could encode all Unicode characters; otherwise `false`.
     */
    @inlinable
    public func getGlyphs(for characters: [UniChar], _ glyphs: inout [GlyphId]) -> Bool {
        precondition(characters.count <= glyphs.count)
        return CTFontGetGlyphsForCharacters(self, characters, &glyphs, characters.count)
    }

    @inlinable
    public func getGlyph(for character: Character) -> GlyphId? {
        var glyphs: [GlyphId] = [0, 0] // we need two slots
        let okay = getGlyphs(for: character.utf16.map { $0 }, &glyphs)
        return okay ? glyphs[0] : nil
    }

    @inlinable
    public func getBoundingRect(for glyph: GlyphId) -> CGRect {
        withUnsafePointer(to: glyph) {
            CTFontGetBoundingRectsForGlyphs(self, .default, $0, nil, 1)
        }
    }

    @inlinable
    public func getBoundingRects(for glyphs: [GlyphId], _ rects: inout [CGRect]) -> CGRect {
        precondition(glyphs.count <= rects.count)
        return CTFontGetBoundingRectsForGlyphs(self, .default, glyphs, &rects, glyphs.count)
    }

    @inlinable
    public func copyMathTable() -> MathTable? {
        // `CTFontCopyTable` only makes a shallow copy
        CTFontCopyTable(self,
                        CTFontTableTag(kCTFontTableMATH),
                        CTFontTableOptions())
            .flatMap(MathTable.init(_:))
    }
}
