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

    func toEm(_ designUnits: UInt32) -> CGFloat {
        CGFloat(designUnits) / CGFloat(unitsPerEm)
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
