// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

typealias Font = CTFont

extension CTFont {
    var unitsPerEm: UInt32 { CTFontGetUnitsPerEm(self) }
    var size: CGFloat { CTFontGetSize(self) }

    func convertToEm(_ designUnits: UInt32) -> CGFloat {
        CGFloat(designUnits) / CGFloat(unitsPerEm)
    }

    func convertToPoints(_ designUnits: UInt32) -> CGFloat {
        convertToEm(designUnits) * size
    }

    /**

     - Returns:
        `true` if the font could encode all Unicode characters; otherwise `false`.
     */
    func getGlyphs(for characters: [UniChar], _ glyphs: inout [CGGlyph]) -> Bool {
        precondition(characters.count <= glyphs.count)
        return CTFontGetGlyphsForCharacters(self, characters, &glyphs, characters.count)
    }

    func getGlyph(for character: Character) -> CGGlyph? {
        var glyphs: [CGGlyph] = [0, 0] // we need two slots
        let okay = getGlyphs(for: character.utf16.map { $0 }, &glyphs)
        return okay ? glyphs[0] : nil
    }

    func getBoundingRect(for glyph: GlyphId) -> CGRect {
        withUnsafePointer(to: glyph) {
            CTFontGetBoundingRectsForGlyphs(self, .default, $0, nil, 1)
        }
    }

    func getBoundingRects(for glyphs: [GlyphId], _ rects: inout [CGRect]) -> CGRect {
        precondition(glyphs.count <= rects.count)
        return CTFontGetBoundingRectsForGlyphs(self, .default, glyphs, &rects, glyphs.count)
    }

    func copyMathTable() -> MathTable? {
        // `CTFontCopyTable` only makes a shallow copy
        CTFontCopyTable(self,
                        CTFontTableTag(kCTFontTableMATH),
                        CTFontTableOptions())
            .flatMap { MathTable($0) }
    }
}
