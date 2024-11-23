// Copyright 2024 Lie Yan

import CoreText
import Foundation
import TTFParser

struct Font {
    let ctFont: CTFont

    init(_ ctFont: CTFont) {
        self.ctFont = ctFont
    }

    var unitsPerEm: UInt32 {
        CTFontGetUnitsPerEm(ctFont)
    }

    var size: CGFloat {
        CTFontGetSize(ctFont)
    }

    func toEm(_ designUnits: UInt32) -> CGFloat {
        CGFloat(designUnits) / CGFloat(unitsPerEm)
    }

    func toPoints(_ designUnits: UInt32) -> CGFloat {
        toEm(designUnits) * size
    }

    func getGlyphs(for chars: [UniChar], glyphs: inout [CGGlyph]) {
        precondition(chars.count <= glyphs.count)
        CTFontGetGlyphsForCharacters(ctFont, chars, &glyphs, chars.count)
    }

    func getGlyphs(for chars: [UniChar]) -> [CGGlyph] {
        var glyphs = [CGGlyph](repeating: 0, count: chars.count)
        getGlyphs(for: chars, glyphs: &glyphs)
        return glyphs
    }

    func getGlyph(_ char: Character) -> CGGlyph {
        getGlyphs(for: char.utf16.map { $0 })[0]
    }

    /**
     Returns a copy of the math table.
     */
    func copyMathTable() -> MathTable? {
        // `CTFontCopyTable` makes a shallow copy
        guard let data = CTFontCopyTable(ctFont,
                                         CTFontTableTag(kCTFontTableMATH),
                                         CTFontTableOptions())
        else {
            return nil
        }
        return MathTable(data)
    }
}
