// Copyright 2024 Lie Yan

import CoreText
import Foundation
import TTFParser

typealias Font = CTFont

extension CTFont {
    var unitsPerEm: UInt32 {
        CTFontGetUnitsPerEm(self)
    }

    var size: CGFloat {
        CTFontGetSize(self)
    }

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
    func getGlyphs(for characters: [UniChar], glyphs: inout [CGGlyph]) -> Bool {
        precondition(characters.count <= glyphs.count)
        return CTFontGetGlyphsForCharacters(self, characters, &glyphs, characters.count)
    }

    /**

     - Returns:
        `(glyphs, okay)` where `okay` is `true` if the font could encode all
        Unicode characters; otherwise `false`.
     */

    func getGlyphs(for characters: [UniChar]) -> (glyphs: [CGGlyph], okay: Bool) {
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        let okay = getGlyphs(for: characters, glyphs: &glyphs)
        return (glyphs, okay)
    }

    /**

     - Returns: The glyph or `nil`
     */
    func getGlyph(for character: Character) -> CGGlyph? {
        let glyph = getGlyphs(for: character.utf16.map { $0 }).glyphs[0]
        return glyph == 0 ? nil : glyph
    }

    func copyMathTable() -> MathTable? {
        // `CTFontCopyTable` only makes a shallow copy
        CTFontCopyTable(self,
                        CTFontTableTag(kCTFontTableMATH),
                        CTFontTableOptions())
            .flatMap { MathTable($0) }
    }
}
